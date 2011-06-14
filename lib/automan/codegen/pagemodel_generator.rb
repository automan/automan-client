require 'automan/codegen/model_container'     
require 'automan/codegen/generate_helper'
require 'automan/ext'
require 'ostruct'        
require 'erb'
require 'active_support'
module Codegen  

  class PageModelGenerator
     attr_reader :xml,:model_container, :options
     include GenerateHelper
     def initialize(xml_file_path, options={})
     		begin
     			@model_container = ModelContainerRender.new(ModelContainer.new(File.read(xml_file_path)))
     		rescue REXML::ParseException => e
     			raise "xml 解析异常，文件:#{xml_file_path}， 请确保xml编码是GBK, 并且格式正确"
     		end   		
        
        @options = options
     end           
     
     def write(dest_path, file_options={})
        file(self.run, dest_path,file_options)
     end
     
     def run
        rhtml = ERB.new(File.read(File.dirname(__FILE__)+"/pagemodel_template.erb"))
        rhtml.result(@model_container.get_binding).to_gbk
     end
     
   end  
   
   class ModelContainerRender
     attr_reader :container
     def initialize(container)
       @container = container
     end 
     
     def namespace_start                                       
         result = ""
         raise ArgumentError.new("The model namespace can't be nil, please check the format of your xml.") if container.modelNamespace.nil?
         container.modelNamespace.split("::").each_with_index do |e,i|
           result<<"#{"\t"*i}module #{e}\n"
         end
         result
     end

    def base_root_model
      return container.base.gsub(/Model$/,"RootModel")
    end

    def base_model
      return container.base
    end
    
     def namespace_end
       result = ""
       size = container.modelNamespace.split("::").size
       (1..size).to_a.reverse.each do|e|
         result<<"#{"\t"*(e-1)}end\n"
       end
       result
     end         

     def get_binding
       binding
     end
   end
    
end
