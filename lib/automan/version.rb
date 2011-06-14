module Automan
	def self.version
		detail = version_detail
    #只要是以 .1 结尾的，就是正式版，其它的都是内测版。
    if(detail =~ /\.1$/)
      result = "0.8 正式版 (version: #{detail})"
    else
      result = "0.8 内测版 (version: #{detail})"
    end
    return result
	end
  def self.version_detail
    return "0.8.3.0"
  end
end