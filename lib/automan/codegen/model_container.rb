require 'automan/codegen/xml_simple'
require 'ostruct'
module Codegen                
		class ModelRerferManager 

		end

    class ModelContainer < OpenStruct
      #
      # attributes contains:
      #   ["modelNamespace", "IsWeb", "controltypeNamespace", "base"]
      attr_accessor :models
      attr_accessor :root_models
      attr_accessor :sub_models
      def initialize(xml_str)
         @xml = XmlSimple.xml_in(xml_str)
         @attributes = @xml.except("models")         
         @models =  (@xml["model"] && @xml["model"].map{|e|Model.new(e,self)})||[]
         @root_models = @models.select{|e|e.root=="true"}
         @sub_models = @models.select{|e|e.root!="true"}
         super(@attributes)
      end 
      
      def find_model(key)
      	@model_hash||=self.models.build_hash{|e|[e.type, e]}
      	@model_hash[key]
      end
    end        

		class Base < OpenStruct
      attr_reader :attributes, :parent
      
      def initialize(hash, parent=nil)
      	@attributes = hash
      	@parent = parent
      	super @attributes
      end
      
			def type
        @table[:type].blank? ? (defined?(DEFAULT_TYPE) ? DEFAULT_TYPE : nil): @table[:type]
			end		
			
		  def comment
	  		if self.description
	  			"##{self.description}"
				end
  	  end    
		end
    
    class Model < Base
      #                                    
      # attributes contains:
      #   "Root", "type", "description"
      attr_reader :sub_models,:elements
      
      def initialize(hash,parent)
        @attributes = hash.except("subModel","element")
        @sub_models = hash["subModel"]&&hash["subModel"].map{|e|SubModelMethod.new(e, self)}
        @elements   = hash["element"]&&hash["element"].map{|e|ElementMethod.new(e, self)}   
        @sub_models||=[]
        @elements||=[] 
        super(@attributes, parent)
      end
  
      def root
        @attributes["Root"]
      end

      def class_name
         @attributes["type"]
      end
  
      def methods
         @sub_models + @elements
      end
    end    

    #contains keys:
    # => ["name", "cache", "type", "selector", "collection", "description"]

    class Method < Base
    	DEFAULT_TYPE = "AWatir::AElement"

      def the_type
        @table[:type].blank? ? DEFAULT_TYPE : @table[:type]
      end
  
      def find_method_name
      	single = _find_method_name
    		self.collection=="true" ? single+"s" : single
    	end
    end

    class SubModelMethod < Method
			
			def refered_model
			  @parent.parent.find_model(self.type)
			end

    	def _find_method_name
    		"find_model"
    	end

    end

    class ElementMethod < Method 
    	def _find_method_name
    		"find_element"
    	end

    end
end
