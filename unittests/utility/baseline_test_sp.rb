require File.dirname(__FILE__) + "/setup"

class TestFileList < Test::Unit::TestCase
  def test_baseline()
    out = capture_stdout{      
      require 'automan/baseline'
    }
    this_file = File.expand_path __FILE__
    assert_equal("引用baseline的文件为：#{this_file}",  out.split("\n")[0])
  end
end
