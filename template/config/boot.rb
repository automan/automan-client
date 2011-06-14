AUTOMAN_ROOT = File.expand_path(File.dirname(__FILE__)+"/../") unless defined?(AUTOMAN_ROOT)
require "automan"
require "#{AUTOMAN_ROOT}/config/automan_config"
Automan.require_folder "#{AUTOMAN_ROOT}/share", :donot_raise_error => true
include Share