require File.dirname(__FILE__) + "/setup"
require 'automan/baseline'

class CaptureTest < Test::Unit::TestCase
  def test_capture
    captureDesktopJPG
  end
end