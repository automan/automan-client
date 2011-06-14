unless defined?(TOPDIR)
  TOPDIR = File.join(File.dirname(__FILE__), '..')
  $LOAD_PATH.unshift TOPDIR
end
$:.unshift File.join(TOPDIR, "lib")

unless defined?(HTMLDIR)
  HTMLDIR = File.join(File.dirname(__FILE__), 'htmls')
end

require File.dirname(__FILE__)+'/capture_stdout'

require 'automan/load_vendor'