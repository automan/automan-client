module AWatir
  class Logger
    def self.log_operation_success(element, value=nil)
      operation =  caller(1)[0].to_s.match(/in `(.+)'/)[1]
      puts "[成功]#{HtmlHelper.generate_step_from_element(element)}.#{operation}(#{value})操作"
    end
    def self.log_operation_fail(element, value=nil)
      operation =  caller(1)[0].to_s.match(/in `(.+)'/)[1]
      puts "[警告]#{HtmlHelper.generate_step_from_element(element)}.#{operation}(#{value})操作，失败！" +
        "\n\t#{HtmlHelper.generate_jquery_from_selector_history(element)}"
      Check.add_op_fail
    end
    def self.log_element_empty(element, value=nil)
      operation =  caller(1)[0].to_s.match(/in `(.+)'/)[1]
      puts "[警告]#{HtmlHelper.generate_step_from_element(element)}.#{operation}(#{value})操作，找不到元素！" +
        "\n\t#{HtmlHelper.generate_empty_detail_info(element)}"
      Check.add_op_fail
    end
    def self.log_model_success(model)
      operation =  caller(1)[0].to_s.match(/in `(.+)'/)[1]
      puts "[成功]页面模型操作，#{operation}(#{model.class})"
    end
    def self.log_find_model_array_fail(model, index, length)    
      if(index.is_a? Fixnum)
        string1 = "[#{index}]查找操作，数组取值越界！共#{length}个元素。"
      else
        string1 = "[#{index}]查找操作，找不到匹配的项！共#{length}个元素。"
      end
      puts "[提示]#{HtmlHelper.generate_step_from_element(model.current)}#{string1}" +
        "\n\t#{HtmlHelper.generate_jquery_from_selector_history(model.current)}"
    end
    def self.log_find_element_array_fail(element, index, length)
      if(index.is_a? Fixnum)
        string1 = "[#{index}]查找操作，数组取值越界！共#{length}个元素。"
      else
        string1 = "[#{index}]查找操作，找不到匹配的项！共#{length}个元素。"
      end
      puts "[提示]#{HtmlHelper.generate_step_from_element(element)}#{string1}" +
        "\n\t#{HtmlHelper.generate_jquery_from_selector_history(element)}"
    end
    def self.log_ie_success(value=nil, ieModel = nil)
      operation =  caller(1)[0].to_s.match(/in `(.+)'/)[1]
      output =  "[成功]IE操作，#{operation}(#{value})"
      if(ieModel)
        output = output + "[标题]=>" + ieModel.current.title
      end
      puts output
    end
  end

  #用于将页面模型标出在页面上
  class PageMarker
    def initialize
      @name_list = []
    end

    def self.mark_model(model)      
      lighter = WebHighlighter.new
      marker = PageMarker.new
      marker.mark_html_model_instance(model, lighter)
      marker.write_name_final
    end
    
    def self.mark_page(url,page_type)
      lighter = WebHighlighter.new
      marker = PageMarker.new
      p = IEModel.attach(url).cast(page_type)
      #      body = p.find_element(AElement, "body>*")
      marker.mark_html_model_instance(p, lighter)
      marker.write_name_final
    end

    def get_children(model_instance)
      model_instance_arr = Array(model_instance)
      return [] unless(model_instance_arr[0].is_a?(HtmlModel))
      arr_ins = model_instance_arr[0].class.instance_methods
      arr_html = HtmlModel.instance_methods
      methods = arr_ins-arr_html
      arr = []
      methods.each{|m|
        arr_method = []
        model_instance_arr.each{|model_ins|
          ins = eval("model_ins." + m)
          if(ins.is_a?Array)
            if(arr_method.empty?)
              arr_method = ins.class.new
            end
            arr_method.concat ins
          else
            arr_method.concat(Array(ins))
          end          
        }
        arr << arr_method
      }
      return arr
    end

    def mark_html_model_instance(instance, lighter)
      queue = get_children(instance)

      while(current = queue.pop)
        #处理current
        found = false
        if(current.is_a?(Array) && current[0].is_a?(HtmlModel))
          current.each{|m|
            lighter.highlight(m.current, current.is_a?(ModelArray), color)
            unless(m.current.empty? || found)
              write_name(m.current,color)
              found=true
              #              break #这里决定要不要全部框出来
            end
          }
          unless(found)
            puts "无法找到"+ get_full_name(current[0].current)
          end
        elsif(current.is_a?(Array) && current[0].is_a?(AElement))
          current.each{|e|
            lighter.highlight(e,current.is_a?(ElementArray) )
            unless(e.empty? || found)
              write_name(e)
              found=true
              #              break #这里决定要不要全部框出来
            end
          }
          unless(found)
            puts "无法找到"+ get_full_name(current[0])
          end
        else
          raise "not_supported"
        end

        queue.concat(get_children(current))
      end
   
    end

    def write_name_final()
      list = []
      @name_list.each{|cache|
        ele = cache[:ele]        
        method = cache[:method]
        color = cache[:color]

        ole = ele.element.element
        body = ole.document.body
        name = method #TODO，还可以添加中文注释，selector等信息。
        hash = get_absolute_offset(ole)
        top = hash[:top]
        left = hash[:left]
        list << {:body=>body, :name=>name, :left=>left, :top=>top, :color=>color }
      }
      @name_list.clear
      list = list.sort_by{|u| u[:top]}
      list = list.reverse
      last_left = 60000 #屏幕应当 > 60000px
      last_top = 60000 #屏幕应当 > 60000px
      list.each{|l|
        body = l[:body]
        name = l[:name]
        left = l[:left]
        top = l[:top]
        color = l[:color]
        while( -20<(last_left-left) && (last_left-left)<20 && (last_top-top)<15)
          top = last_top - 15
        end
        body.insertAdjacentHtml("AfterBegin", get_name_html(name, left, top, color))
        last_left = left
        last_top = top
      }
      list.clear
    end
    
    private
    def get_name_html(name, left, top, color="red")
      #Todo，可以将element和model在样式上分开，有所区别
      return "<Strong style='color:#{color};font:arial;font-size:12px;background:yellow;z-index:900000;position:absolute;top:#{top-15}px;left:#{left}px;'>#{name}</Strong>"
    end

    def get_absolute_offset(ole)
      parent = ole
      top = 0
      left = 0
      while parent.tagName.downcase !="body" && parent.tagName.downcase !="html" && parent.offsetParent.tagName.downcase!="html"
        top += parent.offsetTop
        left += parent.offsetLeft
        parent = parent.offsetParent
      end
      top += parent.offsetTop
      left += parent.offsetLeft        
      return {:top=>top, :left=>left}
    end

    def get_full_name(ele)
      arr=[]
      last = ""
      ele.log_info.action_history.each{|a|
        if(a.has_key?(:name) && a[:name]!=last)
          arr<< "#{a[:name]}(#{a[:description]})"
          last = a[:name]
        end
      }
      return arr*"."
    end
    def get_name(ele)
      return ele.log_info.action_history[-1][:name]
    end

    def write_name(ele, color="red")
      method = get_name(ele)
      @name_list << {:ele=>ele, :method=>method, :color=>color}
    end

    def color
      return "purple"
    end

  end

  #各式的html帮助方法
  class HtmlHelper
    def self.get_html_from_document(docu)
      html = docu.body.parentElement
      while(html.nodeName.downcase != "html")
        html = html.parentElement #ie6 bug
      end
      return html
    end

    def self.get_path_array_from_element(aelement)
      current = aelement
      result = []
      while current        
        result = get_current_tag_and_index(current).concat(result)
        current = current.parent
      end
      return result
    end

    def self.get_current_tag_and_index(aelement)
      result = []
      tag = aelement.control
      index = 0
      head = aelement.element.element
      while (head = head.previousSibling)
        index=index+1 if(head.nodeName == tag)
      end      
      result << tag
      result << index
      return result
    end

    def self.get_document_in_frame(frame)
      begin
        return frame.document
      rescue => e
        #        puts e
        #具体做法遇到问题时再看
        #        return frame.window.document
        return nil
      end
    end

    def self.click_in_spawned_process(element)      
      ruby_code = "require 'rubygems'; "
      ruby_code << "require 'automan/mini'; "
      ruby_code << generate_script_from_selector_history(element)
      ruby_code << "m.click_wait;"
      exec_string = "ruby -e #{ruby_code.inspect}"

      CommonChildProcess.system(exec_string)
    end

    class CommonChildProcess
      require 'childprocess'
      @list = []
      def self.loaded?
        return !@list.empty?
      end
      def self.system(cmd_string) #开始运行后就不管了
        p = ChildProcess.build(cmd_string)
        p.io.stdout = STDOUT
        p.io.stderr = STDERR
        p.start
      end

      #TODO
      def self.pop
        p, io_out, io_err = @list.last
        return nil if p.nil?
        timeout = 120 #超时120秒

        pos = 0
        end_time = Time.now + timeout
        until (ok = p.exited?) || Time.now > end_time
          io_out.pos = pos
          puts io_out.readlines
          pos = io_out.pos
          sleep 5 #间隔时间5秒
        end

        unless ok
          p.stop
          raise TimeoutError, "process still alive after #{timeout} seconds"
        end

        io_out.pos = pos
        puts io_out.readlines
        
        if(p.crashed?)
          io_err.rewind
          puts io_err.readlines
        end

        @list.pop
        return p
      end
      #TODO
      def self.push(cmd_string)
        p = ChildProcess.build(cmd_string)
        io_out = File.open(File.join(Automan.config.root_path,"process-io-out_#{@list.length}.tmp"),"w+")
        io_err = File.open(File.join(Automan.config.root_path,"process-io-err_#{@list.length}.tmp"),"w+")
        p.io.stdout = io_out
        p.io.stderr = io_err
        p.start
        @list.push([p,io_out,io_err])
      end
    end

    def self.close_ie_in_spawned_process(ie_model)
      load_path_code = ''
      ruby_code = "require 'rubygems'; "
      ruby_code << "require 'automan/mini'; "
      
      hwnd = ie_model.current.hwnd
      ruby_code << "ie = AWatir::IEModel.get_all_ies.delete_if{|ie| ie.current.hwnd!=#{hwnd}}.first;"
      
      ruby_code << "ie.close"
      exec_string = "start ruby -e #{(load_path_code + '; ' + ruby_code).inspect}"
      system(exec_string)
    end

    def self.generate_full_path(element)
      arr = get_path_array_from_element(element)
      result = ""
      arr.each { |a|
        if a.is_a? String
          result = result + ">#{a}"
        else
          result = result + ":eq(#{a})"
        end
      }
      result = result.gsub(/^>HTML:eq\(0\)/,"")
      return result
    end

    def self.generate_step_from_element(element)
      action_info = element.log_info.action_history
      step=""
      action_info.each{|action_hash|
        step += "." if(!step.empty? && (action_hash.has_key?(:name)||action_hash.has_key?(:description)))
        step += "#{action_hash[:name]}" if(action_hash.has_key?(:name))
        step += "(#{action_hash[:description]})" if(action_hash.has_key?(:description))
      }
      return step
    end

    def self.generate_empty_detail_info(element)
      log_info = element.log_info
      empty_history = log_info.empty_history
      action_history = log_info.action_history
      selector_history = log_info.selector_history
      assert(empty_history.length == action_history.length)
      assert(empty_history.length == selector_history.length)
      result = ""
      for i in (0...empty_history.length)
        result += "."
        action_hash = action_history[i]
        result += "#{action_hash[:name]}" if(action_hash.has_key?(:name))
        result += "(#{action_hash[:description]})" if(action_hash.has_key?(:description))
        result += "[#{selector_history[i]}]"
        empty_string = empty_history[i]?"找不到":"找到"
        result += "《#{empty_string}》"
      end
      return result
    end

    def self.generate_jquery_from_selector_history(element)
      ruby_code = ""
      type = element.class
      selector_history = element.log_info.selector_history
      selector = ""
      0.upto(selector_history.length-1) do |index|
        single_selector = selector_history[index]
        if(single_selector.match(/^\[.+\]$/))
          if(index == selector_history.length-1)
            ruby_code << "m = m.find_elements(#{type}, '#{selector}')#{single_selector};"
            selector = ""
            break
          else
            ruby_code << "m = m.find_models(AWatir::HtmlModel, '#{selector}')#{single_selector};"
            selector = ""
          end
        else
          #select的叠加要加空格，第一个不用
          if(selector.empty?)
            selector = single_selector
          else
            selector += " " + single_selector
          end

          ruby_code << "m = m.find_element(#{type}, '#{selector}');" if(index == selector_history.length-1)
        end
      end
      return ruby_code
    end

    def self.find_elements_from_ie(url_regexp, selector, type=AWatir::AElement)
      ie = IEModel.attach(url_regexp)._internal_cast(HtmlModel)
      elements = ie.find_elements(type, selector)
      return elements
    end

    def self.find_element_from_ie(url_regexp, selector, type=AWatir::AElement)
      ie = IEModel.attach(url_regexp)._internal_cast(HtmlModel)
      element = ie.find_element(type, selector)
      return element
    end

    def self.generate_script_from_selector_history(element)
      hwnd = element.element.ie.hwnd
      ruby_code = "ie = AWatir::IEModel.get_all_ies.delete_if{|ie| ie.current.hwnd!=#{hwnd}}.first;"
      ruby_code << "m = ie.cast(AWatir::HtmlModel);"
      ruby_code <<  generate_jquery_from_selector_history(element)
      return ruby_code
    end
  end
  
  #给html加高亮
  class WebHighlighter
    def initialize
      @highlight_list = []
    end
    def self.highlight_elements(elements)
      wh = WebHighlighter.new
      elements.each{ |ele| wh.highlight(ele) }
      sleep 2
      wh.clear
    end
    def highlight(a_element, is_array = false, color = "red")
      return if a_element.empty?
      return unless a_element.is_element
      element_d = a_element.element.element
      @highlight_list << [element_d, element_d.style.cssText]
      element_d.style.borderStyle = is_array ? "dashed" : "solid";
      element_d.style.borderWidth = is_array ? "2px" : "1px";
      element_d.style.borderColor = color;
      return
    end
    def clear
      @highlight_list = @highlight_list.reverse
      @highlight_list.each { |arr|
        begin
          arr[0].style.cssText = arr[1]
        rescue => err
          puts err
        end
      }
      @highlight_list.clear
    end
  end

  class Win32Helper
    #供automan console方便给出弹出框里button的列表
    def self.get_window_buttons(win_title, first_step=10)
      buttons_info=Win32Helper._list_window_buttons(win_title)
      buttons_list = []
      for i in 0..buttons_info.length-1
        arr=buttons_info[i].split(":")
        buttons_list <<  "#{arr[0]}:[#{arr[1]}]"
      end
      puts buttons_list
      return nil
    end

    private
    def self._list_window_buttons(win_title, first_step=10)
      autoit = WIN32OLE.new("AutoItX3.Control")
      if(autoit.winexists(win_title)==0)
        puts "窗口不存在"
      end
      title = autoit.WinGetTitle(win_title)
      result = []
      result << "Title:#{title}"
      scope_step = scope = first_step
      index = 1
      while(true)
        b = autoit.ControlGetText(win_title,'',"Button#{index}")
        unless(b.empty?)
          result << "Button#{index}:#{b}"
        end
        index = index+1
        #为防止出现中间出现空的没有被使用的控件，如button1、2有而button3没有，加以下逻辑
        #当取值范围为取出元素的2倍时，停止搜索，否则就将范围加一个步进值。
        if(index>=scope)
          if((result.length * 2) > scope)
            scope = scope + scope_step
          else
            break
          end
        end
      end
      return result
    end
  end
end


