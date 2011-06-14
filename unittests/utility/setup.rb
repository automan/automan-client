require File.dirname(__FILE__) + "/../setup"
include CaptureStdout

require "active_support"
require 'automan/autility/Loginfo'
require 'automan/autility/VerifyData'
require 'automan/autility/Capture.rb'
include CaptureScreen
require 'automan/autility/PopWin.rb'
include Popwin
require 'automan/autility/Util'
require 'automan/data_process/data_sheet'

require 'test/unit'

require 'automan/mini'
include AWatir