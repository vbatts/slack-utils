
module Slackware
	VERSION = "13.1"
	class Package
		attr_accessor :name, :time, :path, :file, :pkgname, :version, :arch, :build
		def initialize(name = nil, path = '/var/log/packages/', time = Time.now())
			self.name = name
			self.path = path
			self.time = time
		end

		def parse(name)
		    self.name = name
		    arr = name.split('-').reverse
		    self.build = arr.shift
		    self.arch = arr.shift
		    self.version = arr.shift
		    self.pkgname = arr.reverse.join('-')
		end
	end
end

