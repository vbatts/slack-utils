
module Slackware
	VERSION = begin
			  data = File.read("/etc/slackware-version")
			  data =~ /Slackware\s(.*)/
			  $1
		  rescue
			  nil
		  end
	UTILS_VERSION = "0.5.2"
end
