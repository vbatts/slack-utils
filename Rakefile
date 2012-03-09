# To build the gem, from this directory run
# rake gem


require 'rake/clean'
require 'rake/testtask'
#require RUBY_VERSION > '1.9.1' ? 'rubygems/package_task' : 'rake/packagetask'

def source_version
  @source_version ||= begin
                        $LOAD_PATH.insert(0,File.expand_path('../lib',__FILE__))
                        require 'slackware/version'
                        Slackware::UTILS_VERSION
                      end
end

task :test do
  ENV['LANG'] = 'C'
  ENV.delete 'LC_CTYPE'
  #ENV['ROOT'] = File.expand_path('test/samples',__FILE__)
end

Rake::TestTask.new do |t|
	t.libs << "test"
	t.test_files = FileList['test/test*.rb']
	t.verbose = true
end

# PACKAGING ============================================================

if defined?(Gem)
  # Load the gemspec using the same limitations as github
  def spec
    require 'rubygems' unless defined? Gem::Specification
    @spec ||= eval(File.read('slack-utils.gemspec'))
  end

  def package(ext='')
    "pkg/slack-utils-#{spec.version}" + ext
  end

  def slackpkg()
    sh "sudo OUTPUT=#{Dir.pwd}/pkg " +
       "VERSION=#{spec.version} " +
       "sh slack-utils.SlackBuild"
  end

  desc 'Build slackware package'
  task :slackpkg => package('.tar.gz') do
    slackpkg()
  end

  desc 'Build packages'
  task :package => %w[.gem .tar.gz].map {|e| package(e)}

  desc 'Build gem'
  task :gem => package('.gem')

  desc 'Build and install as local gem'
  task :install => package('.gem') do
    sh "gem install #{package('.gem')}"
  end

  directory 'pkg/'
  CLOBBER.include('pkg')

  file package('.gem') => %w[pkg/ slack-utils.gemspec] + spec.files do |f|
    sh "gem build slack-utils.gemspec"
    mv File.basename(f.name), f.name
  end

  file package('.tar.gz') => %w[pkg/] + spec.files do |f|
    sh <<-SH
      git archive \
        --prefix=slack-utils-#{source_version}/ \
        --format=tar \
        HEAD | gzip > #{f.name}
    SH
  end

  desc 'Do magic release stuffs'
  task 'release' => ['test', package('.gem')] do
    if File.read("CHANGES") =~ /= \d\.\d\.\d . not yet released$/i
      fail 'please update changes first'
    end

    sh <<-SH
      gem install #{package('.gem')} --local &&
      gem push #{package('.gem')}  &&
      git commit --allow-empty -a -m '#{source_version} release'  &&
      git tag -s v#{source_version} -m '#{source_version} release'  &&
      git tag -s #{source_version} -m '#{source_version} release'  &&
      git push && (git push slack-utils || true) &&
      git push --tags && (git push slack-utils --tags || true)
    SH
  end
end
