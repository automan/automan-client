module Codegen                
	class XmlViewer

		attr_reader :container, :builder

		def initialize(container)
			@container = container
			@builder = Builder::XmlMarkup.new(:indent=>2, :margin=>4)
		end

		def to_xml
			builder.models(sorted_attr(@container)){
				@container.models.each do|m|
           write_model(m)
				end
			}
		end  
		
		def write_model(m)
      builder.model(sorted_attr(m)){
			  m.elements.each do|e|
  				builder.element(sorted_attr(e))
  			end
  			m.sub_models.each do|sub_m|
  				builder.subModel(sorted_attr(sub_m)){
            if refered = sub_m.refered_model 
               raise "StackOverFlow, #{refered} refered to his father:#{m}" if refered == m
               write_model(refered)
            end
  				}
  			end   
		 }
		end

		def sorted_attr(obj, method="attributes")
			return {} if obj.attributes.nil?
			obj.attributes.to_a.sort{|a,b|a.first <=> b.first}.build_ordered_hash
		end
	end
end
