require File.dirname(__FILE__)+"/setup"
require 'childprocess'

$all_tests=[]

Dir.chdir TOPDIR do
  $all_tests += Dir["unittests/utility/*_test_sp.rb"]
end

Dir.chdir TOPDIR do
  $all_tests.each {|x|
    path = File.expand_path(x)
    p = ChildProcess.build("ruby",path)
    io = File.open("c:/automan/process-io.tmp","w+")
    p.io.stdout = io
    p.start
    p.poll_for_exit(60)
    io.rewind
    puts io.readlines
  }
end