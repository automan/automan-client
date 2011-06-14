require File.dirname(__FILE__) + "/../../test_helper"
require 'active_support'
class NotPatchedMockElement
	def	method_1
	end
end

class PatchedMockElement
	attr_accessor :how,:what
	def initialize
		@how = :ole_object
		@what = true
	end
	
	def locate
		return false
	end
end


class NotOlePatchedMockElement
	attr_accessor :how,:what
	def initialize
		@how = :xpath
		@what = true
	end
	
	def locate
		return false
	end
end

class PatchTest < Test::Unit::TestCase
	def test_patch_if
		assert_equal WatirPatches::LocatePatch.patch_if(NotPatchedMockElement), false
		assert WatirPatches::LocatePatch.patch_if(PatchedMockElement), true
		assert WatirPatches::LocatePatch.patch_if(NotOlePatchedMockElement), true
  end
  
  def test_patch
		assert_equal PatchedMockElement.new.locate, false
  	WatirPatches::LocatePatch.patch_if(PatchedMockElement)
  	assert_equal PatchedMockElement.new.locate, true
  end

	def test_not_ole
		assert_equal NotOlePatchedMockElement.new.locate, false
  	WatirPatches::LocatePatch.patch_if(NotOlePatchedMockElement)
		assert_equal NotOlePatchedMockElement.new.locate, false
	end

end
