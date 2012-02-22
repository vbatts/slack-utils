# encoding: UTF-8

# Copyright 2009,2010  Vincent Batts, http://hashbangbash.com/
# Copyright 2010,2011  Vincent Batts, Vienna, VA, USA
# Copyright 2012  Vincent Batts, Raleigh, NC, USA
# All rights reserved.
#
# Redistribution and use of this source, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this source must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# started - Fri Oct  9 15:48:43 CDT 2009
# updated for args - Tue Mar 23 14:54:19 CDT 2010

require 'slackware'

# Variables
@st = "\033[31;1m"
@en = "\033[0m"
@slog = Slackware::Log.instance

# This is base builder of the packe list
def build_packages(opts = {}, args = [])
  pkgs = Slackware::System.installed_packages
  
  # separated this little thing out, since it adds a little more time
  if (opts[:time])
    pkgs = pkgs.each {|p| p.get_time }
  end

  if (opts[:all])
    if (args.count > 0)
      args.each {|arg|
        # about 0.012s performance improvement,
        # by compiling it here, instead of inside the iteration.
        if (opts[:case_insensitive])
          re = /#{arg}/i
        else
          re = /#{arg}/
        end

        pkgs = pkgs.find_all {|pkg| pkg.fullname =~ re }
      }
    end
    re = nil
  end
  if (opts[:pkg])
    if (opts[:case_insensitive])
      re = /#{opts[:pkg]}/i
    else
      re = /#{opts[:pkg]}/
    end
    pkgs = pkgs.map {|p|
      if p.name =~ re
        if (opts[:color])
          p.name = p.name.gsub(re, "#{@st}\\&#{@en}")
        end
        p
      end
    }.compact
    re = nil
  end
  if (opts[:Version])
    if (opts[:case_insensitive])
      re = Regexp.new(Regexp.escape(opts[:Version]), Regexp::IGNORECASE)
    else
      re = Regexp.new(Regexp.escape(opts[:Version]))
    end
    pkgs = pkgs.map {|p|
      if p.version =~ re
        if (opts[:color])
          p.version = p.version.gsub(re, "#{@st}\\&#{@en}")
        end
        p
      end
    }.compact
    re = nil
  end
  if (opts[:arch])
    if (opts[:case_insensitive])
      re = /#{opts[:arch]}/i
    else
      re = /#{opts[:arch]}/
    end
    pkgs = pkgs.map {|p|
      if p.arch =~ re
        if (opts[:color])
          p.arch = p.arch.gsub(re, "#{@st}\\&#{@en}")
        end
        p
      end
    }.compact
    re = nil
  end
  if (opts[:build])
    if (opts[:case_insensitive])
      re = /#{opts[:build]}/i
    else
      re = /#{opts[:build]}/
    end
    pkgs = pkgs.map {|p|
      if p.build =~ re
        if (opts[:color])
          p.build = p.build.gsub(re, "#{@st}\\&#{@en}")
        end
        p
      end
    }.compact
    re = nil
  end
  if (opts[:tag])
    if (opts[:case_insensitive])
      re = /#{opts[:tag]}/i
    else
      re = /#{opts[:tag]}/
    end
    pkgs = pkgs.map {|p|
      if p.tag =~ re
        if (opts[:color])
          p.tag = p.tag.gsub(re, "#{@st}\\&#{@en}")
        end
        p
      end
    }.compact
    re = nil
  end

  return pkgs
end

def print_upgrades(pkgs)
  count = 1
  p_count = pkgs.count
  pkgs.each do |pkg|
    if (Slackware::System.is_upgraded?(pkg.name))
      puts '"%s" (current version %s build %s%s) has been upgraded before' % [pkg.name,
                                                                        pkg.version,
                                                                        pkg.build,
                                                                        pkg.tag]
      Slackware::System.upgrades(pkg.name).each do |up|
        puts "  %s build %s%s upgraded on  %s" % [up.version,
                                            up.build,
                                            up.tag,
                                            up.upgrade_time]
      end
    else
      puts '"%s" (current version %s build %s%s) has not been upgraded' % [pkg.name,
                                                                     pkg.version,
                                                                     pkg.build,
                                                                     pkg.tag]
    end
    if count < p_count
      puts
    end
    count += 1
  end
end

def print_packages(pkgs)
  if (pkgs.count > 0 && pkgs.first.class == Slackware::Package)
    pkgs.each {|pkg|
      printf("%s\n", pkg.fullname )
    }
  end
end

def print_packages_times(pkgs, epoch = false, reverse = false)
  @slog.debug('print_packages_times') { "epoch: #{epoch} ; reverse: #{reverse}" }
  begin
    if reverse
        pkgs.sort_by {|x| x.time }
    else
        pkgs.sort_by {|x| x.time }.reverse
    end
  end.each {|pkg|
    printf("%s : %s\n", pkg.fullname, epoch ? pkg.time.to_i : pkg.time.to_s )
  }
end

def print_packages_description(pkgs)
  if (pkgs.count > 0 && pkgs.first.class == Slackware::Package)
    pkgs.each {|pkg|
      printf("%s: COMPRESSED SIZE: %s\n", pkg.fullname, pkg.compressed_size )
      printf("%s: UNCOMPRESSED SIZE: %s\n", pkg.fullname, pkg.uncompressed_size )
      pkg.package_description.each {|line|
        printf("%s: %s\n", pkg.fullname, line )
      }
    }
  end
end

# package file listing
def print_package_file_list(pkgs)
  if (pkgs.count > 1)
    pkgs.each {|pkg|
      pkg.get_owned_files.each {|line|
        puts pkg.name + ": " + line
      }
    }
  else
    pkgs.each {|pkg| puts pkg.get_owned_files }
  end
end

# search Array of Slackware::Package's for files
# and print the items found
def print_package_searched_files(pkgs, files)
  found_files = []
  files.each {|file|
    found_files += Slackware::System.owns_file(file)
  }
  found_files.each {|file|
    puts file[0].fullname + ": " + file[1]
  }
end

# find orpaned files from /etc/
#   * build a list of files from removed_packages
#   * check the list to see if they are currently owned by a package
#   * check the unowned members, to see if they still exist on the filesystem
#   * return existing files
def find_orphaned_config_files
  # build a list of config files currently installed
  installed_config_files = Slackware::System.installed_packages.map {|pkg|
    pkg.get_owned_files.map {|file|
      if not(file =~ /\/$/)
        if (file =~ /^etc\//)
          file
        end
      end
    }
  }.flatten.compact

  # this Array is where we'll stash removed packages that have config file to check
  pkgs = Array.new
  Slackware::System.removed_packages.each {|r_pkg|
    # find config files for this removed package
    config = r_pkg.get_owned_files.grep(/^etc\/.*[\w|\d]$/)
    # continue if there are none
    if (config.count > 0)
      # remove config files that are owned by a currently installed package
      config = config.map {|file|
        if not(installed_config_files.include?(file))
          if not(installed_config_files.include?(file + ".new"))
            file
          end
        end
      }.compact
      # check again, and continue if there are no config files left
      if (config.count > 0)
        # otherwise add this package, and its files, to the stack
        pkgs << {:pkg => r_pkg, :files => config}
      end
    end
  }

  # setup list of files to check whether they still exist on the filesystem
  files = []
  pkgs.map {|pkg| files += pkg[:files] }
  files.uniq!

  orphaned_config_files = []
  files.each {|file|
    if (File.exist?(File.join(Slackware::Paths.root_dir(),file)))
      orphaned_config_files << file
    end
  }

  return orphaned_config_files

end

def print_orphaned_files(files)
  puts files
end

# XXX This is a work in progress
# It _works_, but is pretty darn slow ...
# It would be more efficient to break this out to a separate Class,
# and use a sqlite database for caching linked dependencies.
# Categorized by pkg, file, links. based on mtime of the package file, 
# or maybe even mtime of the shared objects themselves.
# That way, those entries alone could be updated if they are newer,
# otherwise it's just a query.
def find_linked(file_to_find)
  require 'find'

  dirs = %w{ /lib /lib64 /usr/lib /usr/lib64 /bin /sbin /usr/bin /usr/sbin }
  re_so = /ELF.*shared object/
  re_exec = /ELF.*executable/

  if File.exist?(file_to_find)
    file_to_find = File.expand_path(file_to_find)
  end
  if not(filemagic(File.dirname(file_to_find) + "/" + File.readlink(file_to_find)) =~ re_so)
    printf("%s is not a shared object\n",file_to_find)
    return nil
  end

  includes_linked = []
  printf("Searching through ... ")
  dirs.each {|dir|
    printf("%s ", dir)
    Find.find(dir) {|file|
      if File.directory?(file)
        next
      end
      file_magic = filemagic(file)
      if (file_magic =~ re_so || file_magic =~ re_exec)
        l = `/usr/bin/ldd #{file} 2>/dev/null `
        if l.include?(file_to_find)
          printf(".")
          l = l.sub(/\t/, '').split(/\n/)
          includes_linked << {:file => file, :links => l}
        end
      end
    }
  }
  printf("\n")
  return includes_linked
end

# This is intended to take the return of the find_linked() method
def packages_of_linked_files(linked_files_arr)
  pkgs = Slackware::System.installed_packages
  owned_pkgs = []
  pkgs.map {|pkg|
    files.each {|file|
      if pkg.owned_files.include?(file)
        owned_pkgs << {:pkg => pkg, :file => file}
      end
    }
  }
  return owned_pkgs
end

# Pretty print the output of find_linked()
def print_find_linked(file_to_find)
  files = find_linked(file_to_find)
  printf("files linked to '%s' include:\n", file_to_find)
  files.each {|file|
    printf("  %s\n", file)
  }
end

private

def filemagic(file)
  return `/usr/bin/file "#{file}"`.chomp
end

# vim:sw=2:sts=2:et:
