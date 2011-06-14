# work around the at_exit hook in test/unit, which kills IRB
require File.dirname(__FILE__) + '/../../automan'

#如果启动目录有config文件夹，就加载里面的boot
if File.exists?("config/boot.rb")
	require "config/boot"
else
  #如果没有，则看automan console的启动目录，如果是c:\automan\PROJECT_ID下，就加载PROJECT_ID
  current = (File.expand_path ".").downcase  
  match_data = current.match /^c:\/automan\/(\w+)/
  if match_data
    AUTOMAN_CONSOLE_PROJECT_ID = match_data[1] #用于启动automan console时，与项目进行绑定
    load File.dirname(__FILE__) + '/../baseline.rb' #没有直接使用baseline的逻辑，为的是不要随便哪里automan console都引用base
  end
end
puts "连接到... [#{Automan.config.tam_host}]，对象库[#{Automan.config.project_tam_id}]"

def helper
  @helper ||= AWatir::HtmlHelper
end
private :helper

#查找符合条件的所有控件
#@return [Array<type>] 返回符合条件控件的集合
def find(reg,selector,type=AWatir::AElement)
	helper.find_elements_from_ie(reg,selector,type)
end

#查找符合条件的控件
#@return [type] 返回符合条件的第一个控件
def find_one(reg,selector,type=AWatir::AElement)
	helper.find_element_from_ie(reg,selector,type)
end

#给控件加框高亮
def show(elements)
  if(elements.is_a? ModelArray)
    target = []
    elements.each{|e|target<<e.current}
  elsif(elements.is_a? HtmlModel)
    target = elements.current
  else
    target = elements
  end
	AWatir::WebHighlighter.highlight_elements(Array(target))
  return ElementArray.new(Array(target)).length
end

#列出控件及控件的所有祖先节点，适用于show隐藏的控件。
def show_path(element)
  if(element.empty?)
    return element
  end
  if(element.is_a?Array)
    return "请输入单个控件"
  end
  result = []
  if(element.is_a? HtmlModel)
    target = element.current
  else
    target = element
  end
  current = target
  while current
    result << current
    current = current.parent
  end
  AWatir::WebHighlighter.highlight_elements(result)
  return HtmlHelper.get_path_array_from_element(target)
end

# 在automan console下调试，想要同步线上的页面模型，使用reload命令。
def reload  
  #如果启动目录有config文件夹，就加载里面的boot，否则就加载automan/baseline
  if File.exists?("config/boot.rb")
    load File.expand_path("config/boot.rb")
    load File.expand_path("config/automan_config.rb")
  else
    load File.dirname(__FILE__) + '/../baseline.rb'
  end
  
  if File.exist?(Automan.config.page_path)
    Automan.require_folder Automan.config.page_path, :reload_page => true
  end
end

#用法 mark(/taobao/, Mms::LoginPage)
def mark(url, page_type)
  AWatir::PageMarker.mark_page(url, page_type)
end
