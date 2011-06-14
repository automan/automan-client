require File.dirname(__FILE__)+"/setup"

$all_tests=[]

Dir.chdir TOPDIR do
  $all_tests += Dir["unittests/codegen/*_test.rb"]
  $all_tests += Dir["unittests/engine/*_test.rb"]
  $all_tests += Dir["unittests/page_updater/*_test.rb"]
  $all_tests += Dir["unittests/utility/*_test.rb"]
end

$all_tests.each {|x| require x}