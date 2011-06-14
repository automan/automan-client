module Assert
	class AssertionError < RuntimeError
		
	end
	
	def silence_require(file)
		begin
 		 require file
		rescue LoadError		  
		end
	end
	
	def assert(cond, message = "Asserion Failed")
		raise AssertionError.new(message) unless cond
	end
	
	def assert_equal(a,b)
		raise AssertionError.new("#{a.inspect} and #{b.inspect} not equal") if a!=b
	end
end


class Object
	include Assert
	extend Assert
end