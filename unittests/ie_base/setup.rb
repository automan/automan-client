require File.dirname(__FILE__) + "/../setup"

require 'automan'

#require "active_support"
#require 'automan/autility/Loginfo'
#require 'automan/autility/VerifyData'
#require 'automan/autility/Capture.rb'
#include CaptureScreen
#require 'automan/autility/PopWin.rb'
#include Popwin
#require 'automan/autility/Util'

require 'test/unit'

include AWatir

class Test::Unit::TestCase
  def start(file_name)
    ie = FFModel.start("file:///"+File.expand_path(File.join(HTMLDIR, "#{file_name}.html")))
    return ie.cast(FModel)
  end
end