require 'pathname'

PACKAGE_ROOT = Pathname.new(__FILE__).parent.parent.to_s
$:.unshift("#{PACKAGE_ROOT}/lib")
require 's4t-utils/load-path-auto-adjuster'
