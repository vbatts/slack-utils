module Slackware
	class PackageBundle < Package
		def initialize
			super
		end
		def self::get_list(pkg)
			e_flag = ""
			if pkg =~ /txz$/
				e_flag = "J"
			elsif pkg =~ /tgz$/
				e_flag = "z"
			elsif pkg =~ /tbz$/
				e_flag = "j"
			end
			IO.popen("tar #{e_flag}wtf #{pkg}") {|f|
				f.readlines.map {|l| l.chomp }
			} 
		end
		def get_slack_desc(pkg,file)
			e_flag = ""
			if pkg =~ /txz$/
				e_flag = "J"
			elsif pkg =~ /tgz$/
				e_flag = "z"
			elsif pkg =~ /tbz$/
				e_flag = "j"
			end
			IO.popen("tar #{e_flag}xOf #{pkg} #{file}") {|f| f.readlines.map {|l| l.chomp } }
		end
	end
end
