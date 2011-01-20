
require 'slackware/package'
require 'slackware/changelog'
require 'slackware/system'
require 'net/http'
require 'net/ftp'
require 'rbconfig'

module Slackware

	# Stub
	class Repo
		RE_PACKAGE_NAME		= Regexp.new(/^PACKAGE NAME:\s+(.*)\.t[gbx]z\s*/)
		RE_PACKAGE_LOCATION	= Regexp.new(/^PACKAGE LOCATION:\s+(.*)$/)
		RE_COMPRESSED_SIZE	= Regexp.new(/^PACKAGE SIZE \(compressed\):\s+(.*)$/)
		RE_UNCOMPRESSED_SIZE	= Regexp.new(/^PACKAGE SIZE \(uncompressed\):\s+(.*)$/)

		attr_accessor :proto, :mirror, :path, :version, :arch, :changelog, :packages

		def initialize(repo = nil)
			@packages = nil
			if (repo.nil?)
				self.proto	= "ftp://"
				self.mirror	= "ftp.osuosl.org"
				self.path	= "/pub/slackware/"
				self.version	= begin 
							  v = Slackware::System.version
							  if v =~ /(\d+)\.(\d+)\.\d+/
								  v = $1 + "." + $2
							  end
							  v
						  end
				self.arch	= begin
							  a = RbConfig::CONFIG["arch"]
							  if a =~ /x86_64/
								  a = "64"
							  else
								  a = ""
							  end
							  a
						  end
			else
				## do some hot parsing of repo
			end
		end

		def fetch(file = nil)
			#if file.nil?
				#url = URI.parse(self.proto + self.mirror + self.path)
			#else
				#url = URI.parse(self.proto + self.mirror + self.path + file)
			#end
			if self.proto =~ /ftp/
				ftp = Net::FTP.open(self.mirror)
				ftp.login
				ftp.chdir(self.path + "slackware" + self.arch + "-" + self.version)
				if (file.nil?)
					data = ftp.list('*')
				else
					data = ftp.gettextfile(file, nil)
				end
				ftp.close
				return data
			elsif self.proto =~ /http/
				# XXX this is not working yet
				req = Net::HTTP::Get.new(url.path)
				res = Net::HTTP.start(url.host, url.port) {|http| http.request(req) }
				return res
			elsif self.proto =~ /file/
				if (file.nil?)
					return Dir.glob(self.path + "slackware" + self.arch + "-" + self.version + "/*")
				else
					return File.read(self.path + "slackware" + self.arch + "-" + self.version + "/" + file)
				end
			else
				return nil
			end
		end

		# Pkg count that _should_ be removed
		# pkgs = Slackware::System.installed_packages
		# sr = Slackware::Repo.new
		# sr.version = "current"
		# c = get_changelog
		#(pkgs.map {|p| p.fullname } & c[:removed].map {|p| p.fullname }).count
		def get_changelog
			if (@changelog.nil?)
				changelog = {}
				changelog_date = fetch("ChangeLog.txt").split(/\n/)
				actions = %w{removed added upgraded rebuilt}
				actions.each {|action|
					changelog[:"#{action}"] = changelog_date.map {|line|
						if line =~ /^(\w+)\/(.*)\.t[gx]z:\s+#{action}\.?$/i
							s = Slackware::Package.parse($2)
							s.path = $1
							if (self.mirror.nil?)
								base_path= self.path
							else
								base_path= self.mirror + self.path
							end
							s.package_location = self.proto +
								base_path +
								"slackware" +
								self.arch +
								"-" +
								self.version +
								"/" 
							s
						end
					}.compact
				}
				return changelog
			else
				return @changelog
			end
		end

		def set_changelog
			@changelog = get_changelog
			return nil
		end

		def get_packages
			if (@packages.nil?)
				pkgs = []
				fetch("PACKAGES.TXT").split(/\n\n/).each {|p_block|
					p_block = p_block.split(/\n/).reject {|cell| cell if cell == "" }
					if (p_block.shift =~ RE_PACKAGE_NAME)
						pkg = Slackware::Package.parse($1)

						p_block.shift =~ RE_PACKAGE_LOCATION
						pkg.package_location = $1

						p_block.shift =~ RE_COMPRESSED_SIZE
						pkg.compressed_size = $1

						p_block.shift =~ RE_UNCOMPRESSED_SIZE
						pkg.uncompressed_size = $1

						# This is the empty PACKAGE DESCRIPTON: tag
						p_block.shift

						pkg.package_description = p_block.map {|cell|
							cell.sub(/^#{pkg.name}:\s*/, '')
						}

						pkgs << pkg
					end
				}
				return pkgs
			else
				return @packages
			end
		end

		def set_packages
			@packages = get_packages
			return nil
		end

	end


end

