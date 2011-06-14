$:.unshift("../lib")
require 'test/unit'
require 's4t-utils'


class CapturingGlobalsTests < Test::Unit::TestCase
  include S4tUtils

  def test_capturing_stderr
    result = capturing_stderr do 
      $stderr.puts "hello, world"
    end

    assert_equal("hello, world\n", result)
  end

  def test_with_environment_vars
    ENV["test_test"] = "original"
    result = with_environment_vars({ "test_test" => "replacement" }) {
      ENV["test_test"]
    }
    assert_equal("replacement", result)
    assert_equal("original", ENV["test_test"])
  end

  def test_with_local_config_file
    assert_false(File.exist?("./config"))
    with_local_config_file("config", "contents\nfoo\n") {
      assert_equal(".", ENV['HOME'])
      assert_equal("contents\nfoo\n", IO.read("config"))
    }
    assert_false(File.exist?("./config"))
  end
                 
  def test_with_command_args
    with_command_args("sizzle steak") {
      assert_equal('sizzle', ARGV[0])
      assert_equal('steak', ARGV[1])
    }
  end
  
  def test_with_stdin
    with_stdin("line1\nline2") do
      assert_equal("line1\n", readline)
      assert_equal("line2", readline)
    end
  end
  
  def test_with_nested_stdin
    with_stdin("line1\nline2") do
      assert_equal("line1\n", readline)
      with_stdin("intermediate") do
        assert_equal("intermediate", readline)
      end
      assert_equal("line2", readline)
    end
  end

end
