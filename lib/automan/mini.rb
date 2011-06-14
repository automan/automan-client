require 'rubygems'         
require 'automan/ext'
require 'automan/load_vendor'
require "active_support"

require "watir"
require "watir/ie"   
require 'win32ole'
require 'automan/aengine/aengine'
require 'automan/aengine/selector'
require 'automan/aengine/structure'
require 'automan/awatir/models'
require 'automan/awatir/html_helper'
require 'automan/awatir/awatir_element'
require 'automan/awatir/special_element'

require 'automan/awatir/win_element' #这里是为后续的WinModel做的兼容

require 'automan/awatir/watir_patches'

require 'automan/autility/Loginfo'
require 'automan/autility/VerifyData'

require "automan/initializer" #所有要读的配置项的默认值都在这里
require 'automan/version'	
Watir::Element.subclasses.each do|e|
	WatirPatches::LocatePatch.patch_if(e.constantize)
end

WIN32OLE.codepage = WIN32OLE::CP_ACP
require 'jcode'
$KCODE = 'e'