require File.dirname(__FILE__) + "/setup"
require 'automan/baseline'

class CaptureDataDrivenTest < Automan::DataDrivenTestcase
  def process
    captureDesktopJPG
  end
end