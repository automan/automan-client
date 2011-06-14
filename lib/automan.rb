#Copyright  (C) 2010-2011 Alibaba Group Holding Limited
require File.dirname(__FILE__)+"/automan/mini"
include AWatir
require 'automan/automan_methods'

require 'automan/autility/Capture.rb'
include CaptureScreen

require 'automan/autility/PopWin.rb'
include Popwin

require 'automan/autility/Util'


require 'automan/page_updater'

require 'automan/data_dirven_testcase'
require 'automan/codegen/pagemodel_generator'