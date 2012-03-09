
$LOAD_PATH.insert(0,File.expand_path('../lib',__FILE__))

require 'slackware/version'

Gem::Specification.new do |s|
  s.name = %q{slack-utils}
  s.version = Slackware::UTILS_VERSION
  s.authors = ["Vincent Batts"]
  s.email = %q{vbatts@hashbangbash.com}
  s.homepage = %q{https://github.com/vbatts/slack-utils/}
  s.summary = %q{Accessing information for the Slackware Linux distribution}
  s.description = %q{ slack-utils is a means by which to access 
package information on the Slackware Linux OS. 
See the examples/ for more information.
  }
  s.files = %w{
    README.rdoc
    bin/slf
    bin/slt
    bin/slp
    bin/slo
    bin/sll
    bin/sli
    bin/slu
    bin/slfindlinked
    examples/list_packages.rb
    examples/repo_difference.rb
    examples/before_then.rb
    examples/repo.rb
    lib/slackware.rb
    lib/slackware/utils.rb
    lib/slackware/args.rb
    lib/slackware/changelog.rb
    lib/slackware/changelog/rss.rb
    lib/slackware/log.rb
    lib/slackware/package.rb
    lib/slackware/package_bundle.rb
    lib/slackware/paths.rb
    lib/slackware/repo.rb
    lib/slackware/version.rb
    lib/slackware/system.rb
  }
  s.executables = %w{ sli slf slo sll slp slt slu slfindlinked }
  s.require_paths = %w{ lib }
  s.has_rdoc = true
  s.extra_rdoc_files = %w{ README.rdoc }
  s.rdoc_options = ["--main=README.rdoc", "--line-numbers", "--inline-source", "--title=Slackware utils (#{s.name}) #{s.version} Documentation"]
  #s.add_dependency("")
  #s.test_files
end
