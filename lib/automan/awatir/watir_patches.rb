module WatirPatches
	module LocatePatch
		
		def self.included(base)
			base.class_eval do
				alias_method_chain :locate, :ole_object
			end
		end
		
		def self.patch_if(clazz)
			methods = clazz.instance_methods
			if methods.include?("locate") && !methods.include?("locate_without_ole_object") 
				clazz.send :include, WatirPatches::LocatePatch
				true
			else
				false
			end
			
		end
		
		def locate_with_ole_object
			@o = if @how == :ole_object
				@what
			else
				locate_without_ole_object
			end
		end
	end
end
