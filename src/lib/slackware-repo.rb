
require 'slackware'
require 'net/http'
require 'net/ftp'
require 'rbconfig'

module Slackware

	# Stub
	class Repo
		attr_accessor :proto, :mirror, :path, :version, :arch, :changelog, :packages
		def initialize(repo = nil)
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
			end
		end

		def fetch(file = nil)
			if file.nil?
				url = URI.parse(self.proto + self.mirror + self.path)
			else
				url = URI.parse(self.proto + self.mirror + self.path + file)
			end
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
			else
				return nil
			end
		end

		def get_changelog
			if (self.changelog.nil?)
				## Eventually this should parse it in to a hash of sorts.
				#self.changlog.each {|line|
				#	if (d = Date.parse(line))
				#	else
				#		
				#}
				return fetch("ChangeLog.txt").split(/\n/)
			else
				return self.changelog
			end
		end

		def set_changelog
			self.changelog = get_changelog
			return nil
		end

		def get_packages
			if (self.packages.nil?)
				return fetch("PACKAGES.TXT").split(/\n/)
			else
				return self.packages
			end
		end

		def set_packages
			self.packages = get_packages
			return nil
		end

	end


end

