require 'iconv' 
class String	
	GBK = "GBK//IGNORE"
	UTF8 = "UTF-8//IGNORE"
	
	def iconv(from, to)
		str = self
		begin
			Iconv.new(to, from).iconv(str)
		rescue Iconv::InvalidCharacter => e
			puts "InvalidCharacter : #{e.message}"
			str
		end		
	end
	
	def to_unicode		
	  self.scan(/./mu).map{|e|
	  	 	a=e.unpack("U*").first;
				a>128 ? "\\u"+a.to_s(16) : e
			}.join
	end
	
	def to_gbk
		iconv(UTF8,GBK)
	end
	
	def to_utf8
		iconv(GBK, UTF8)
	end
end