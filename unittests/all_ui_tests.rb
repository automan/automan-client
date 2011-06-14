require File.dirname(__FILE__)+"/setup"

$all_tests=[]

Dir.chdir TOPDIR do
  $all_tests += Dir["unittests/ie_base/*_test.rb"]
end

$all_tests.each {|x| require x}



