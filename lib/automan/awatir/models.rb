module AWatir
  include AEngine

  class HtmlModel < Model
    #将当前IE转换成html_model_type，功能与cast类似
    def convert(html_model_type)
      result = IEModel.new(IEElement.new(ie))._internal_cast(html_model_type)
      Logger.log_model_success(result)
      DebugInfo.save_cast(html_model_type)
      return result
    end
    
    def automan_methods
      return self.class.instance_methods-HtmlModel.instance_methods
    end

    #这个是给irb用的，调试出的信息。
    def inspect
      element = self.current
      return "\r\n#{self.class}\r\n#{element.inspect}"
    end
    
    def close
      IEModel.new(IEElement.new(ie)).close
    end
    def ie
      #current.ie
      current.element.ie
    end
    def exist?
      current.exist?
    end
    def empty?
      current.empty?
    end
    #获取模块的文本inner_text属性。
    #@return [String] 返回inner_text属性值
    #@example  page.sub_model.text
    def text
      current.text
    end
    #模块的截图方法，能将模块精确地截下来。
    #@return [String] 返回截图之后的图片存放位置
    #@example  page.sub_model.capture
    def capture
      current.capture
    end
    def find_element(type, selector, options={})
      result = nil
      if /^\:/=~selector  #进行一次分选，选择用旧的查找方法还是新的
        #旧的查找方式不再支持
        raise "不支持key value对！请使用selector方式定位元素！"
      else
        result = super
      end
      
      return result
    end
  end

  class HtmlRootModel < HtmlModel

  end
  
  class IEModel < Model
    def initialize(ie_element)
      super(ie_element, nil, nil)
    end
    #打开一个新的IE窗口
    #@param [String] url 新IE的url链接
    #@return [IEModel] 返回一个IEModel的实例
    #@IEModel.start("www.google.com")
    def self.start(url)
      result = self.new(IEElement.create(Watir::IE.start(url)))
      if Automan.config.ie_max
        result.maximize
      end
      Logger.log_ie_success(url)
      return result
    end
    #当前打开多个IE时，需要挂摘（绑定）到特定的IE下进行操作
    #@param [String] url 需要被绑定的IE的url,支持正则表达式
    #@return [IEModel]返回一个IEModel的实例
    #@example ie=IEModel.attach(/msn/)
    def self.attach(url)
      result = self.new(IEElement.create(Watir::IE.attach(:url, url)))
      if Automan.config.ie_max
        result.maximize
      end
      Logger.log_ie_success(url, result)
      return result
    end
    #对当前的IE下进行刷新
    #@example ie.refresh
    def refresh
      ie = @current.element
      ie.refresh
      Logger.log_ie_success
    end
    #获取当前所有打开的ie
    #@return [Array] 返回Array包含IEModel的实例
    #@example  IEModel.get_all_ies
    def self.get_all_ies
      list = []
      Watir::IE.each { |ie| list << self.new(IEElement.new(ie)) }
      return list
    end
    #获取用户操作的所有ie,包括IEModel.start和IEModel.attach
    #@return [Array] 返回Array包含IEModel的实例
    #@example  IEModel.get_ies
    def self.get_ies
      list = []
      IEElement.get_internal_ies.each { |ie| list << self.new(ie) }
      return list
    end
    #将当前IE转到指定的url
    #@param [String] url 需要定向的url
    #@example  ie.goto("www.google.com")
    def goto(url)
      ie = @current.element
      ie.goto(url)
      Logger.log_ie_success(url)
    end
    # Watir的bug，close的时候不支持IE8的多tab模式
    #关闭当前ie
    #@example  ie.close
    def close      
      @current.close # Watir的bug，close的时候不支持IE8的多tab模式
      Logger.log_ie_success
    end
    #返回最后开启的IE，并自动将last_open的IE加入IE hash
    #@return [IEModel] 返回IEModel的实例
    #@example IEModel.last_ie
    def self.last_ie
      result = get_all_ies.last
      if(result)
        IEHash.instance.store(result.current)
        if Automan.config.ie_max
          result.maximize #增加对last_ie的自动最大化，与attach相同的效果。
        end
        result.current.element.wait #last_ie也要确保加载完成。与watir的attach和start逻辑相同
        Logger.log_ie_success(nil, result)
        return result
      else
        return nil
      end
    end
    #将当前IE转换成html_model_type
    #@param [HtmlModel] html_model_type 定义在对象库里的Page
    #@return [HtmlModel] 返回具体Page类型（html_model_type）的实例
    #@example page=ie.cast(HtmlModel)
    def cast(html_model_type)
      result = _internal_cast(html_model_type)
      Logger.log_model_success(result)
      DebugInfo.save_cast(html_model_type)
      return result
    end
    def _internal_cast(html_model_type)
      ie=@current.element
      ie.wait #按钮已经在点击后加了wait了，这里的wait是为了click_no_wait那种点击后出现页面刷新的情况
      #指定ie的直接child是谁
      html = HtmlHelper.get_html_from_document(ie.document)      
      a_ole_element=AOleElement.new(ie, nil, html) #根节点的container是nil
      return html_model_type.new(AElement.new(a_ole_element), self, nil)
    end
    #将当前IE最大化
    #@example ie.maximize
    def maximize
      ie = @current.element
      ie.maximize
    end
    #当前打开多个IE时，需要特定的IE放到最前面
    #@return [Boolean] true
    #@example ie.bring_to_front = > true
    def bring_to_front
      hwnd = @current.hwnd
      win_object = WinObject.new
      win_object.makeWindowActive(hwnd)
      win_object.setWindowTop(hwnd)
      return true
    end
    #获取当前ie的url
    #@return [String] 返回ie的url
    #@example ie.url
    def url
      return @current.url
    end
    #获取当前model的inner_text信息
    #@return [String] 返回model的inner_text信息
    #@example ie.submodel.text
    def text
      #      ie = @current.element
      #      return ie.document.body.innerText
      return self._internal_cast(HtmlModel).current._text
    end
    #获取当前ie的title
    #@return [String] 返回ie的title
    #@example ie.title
    def title
      return @current.title
    end

  end

  class IEHash < Hash
    include Singleton	
    
    def store(ie_element)
      unless(has_key?(ie_element.hwnd)) #防止attach重复的。
        super(ie_element.hwnd, ie_element)
        @array << ie_element.hwnd
      end
    end
    def delete(ie_element)
      if(has_key?(ie_element.hwnd))
        super(ie_element.hwnd)
        @array.delete(ie_element.hwnd)
      else
        TestRunLogger.instance.log_debug_message("[Debug]这个IE不是start或attach的，不参与内部IE表的维护操作。")
      end
    end
    def last
      if(has_key?(@array.last))
        return fetch(@array.last)
      else
        return nil
      end
    end
    private
    def initialize
      @array = []
    end
  end

  class IEElement < BaseElement
    @operator=nil
    def initialize(watir_ie)
      #      @operator = Watir::IE.new(watir_ie)
      @operator = watir_ie
    end
    def self.create(watir_ie)
      result = new(watir_ie)
      IEHash.instance.store result
      return result
    end
    #元数据，对应的是Watir::IE
    def element
      return @operator
    end
    def hwnd
      return @operator.hwnd
    end
    #获取当前的实例IE的title
    #@return [String] 返回当前的实例IE的title
    #@example ie.title
    def title
      return @operator.title
    end
    #关闭当前的实例IE操作
    #@example ie.close
    def close
      IEHash.instance.delete self
      @operator.close #bug，可能关闭ie失败？
    end
    def self.last_ie
      return IEHash.instance.last
    end
    def self.get_internal_ies
      return IEHash.instance.values
    end
    #获取当前的实例IE的url
    #@return [String] 返回当前的实例IE的url
    #@example ie.url
    def url
      return @operator.url
    end
  end

  class AOleElement
    #对应的ie
    @_ie = nil
    #一般情况下是ie，iframe/frame下是frame
    @_container = nil
    #元数据，对应的是ole_object
    @elementT = nil
    def initialize(ie, container, ole_object, empty = false)
      @_ie=ie
      #表示父亲的a_ole_element
      @_container=container
      @elementT=ole_object
      @empty = empty
    end
    #对应的ie
    def ie
      return @_ie
    end
    #一般情况下是ie，iframe/frame下是frame
    def container
      return @_container
    end
    #元数据，对应的是ole_object
    def element
      return @elementT
    end

    def empty?
      return @empty
    end

    @@empty_instance = self.new(nil, nil, nil, true);
    def self.empty
      return @@empty_instance
    end
  end

  #AutoMan框架定义的控件基类
  class AElement < BaseElement
    #元数据，对应的是AOleElement
    @elementAoe = nil
    #里面是dom element
    @elementD = nil
    #里面放AElement
    attr_accessor :operator;

    #这里的初始化方法是为了实在不能确定类型了，就用FindElement(AElement,"selector")
    def initialize(a_ole_element)
      assert a_ole_element
      @elementAoe = a_ole_element
      @elementD = @elementAoe.element
      @ie = @elementAoe.ie
      #      @operator = Watir::Element.new(a_ole_element.element)
    end

    @@empty_instance = self.new(AOleElement.empty)
    def self.empty
      return @@empty_instance
    end
    #判断控件是否为空
    #@return [Boolean] true:控件为空；false:控件不为空
    #@example page.dft_login.empty? => true
    def empty?
      return self.element.equal?(self.class.empty.element)
    end
    #判断控件是否存在
    #@return [Boolean] true:控件存在；false:控件不存在
    #@example page.dft_login.exist? => false
    def exist?
      return !empty?
    end

    #以下是查找方法
    #元数据，对应的是AOleElement
    def element
      return @elementAoe
    end
    # Tag
    def control
      @elementD.nodeName
    end

    #判断控件是否可见
    #@return [Boolean] true 可见 false:不可见
    #@example page.dft_buy.visible
    def visible
      # Now iterate up the DOM element tree and return false if any
      # parent element isn't visible or is disabled.
      object = @elementD
      while object
        begin
          if object.currentstyle.invoke('visibility') =~ /^hidden$/i
            return false
          end
          if object.currentstyle.invoke('display') =~ /^none$/i
            return false
          end
          if object.invoke('isDisabled')
            return false
          end
        rescue WIN32OLERuntimeError
        end
        object = object.parentElement
      end
      true
    end
      
    # Children
    def children
      arr=[]
      first = @elementD.firstChild
      if(first)
        while first
          # @elementD.childNodes.each{|e| 的话会慢一倍
          arr << AElement.new(AOleElement.new(@elementAoe.ie, @elementAoe.container, first)) 
          first = first.nextSibling
        end
      else
        d_name = control.downcase
        if d_name == "iframe" || d_name == "frame"
          frame =  @elementD.contentWindow
          docu = HtmlHelper.get_document_in_frame(frame)
          if(docu)
            html = HtmlHelper.get_html_from_document(docu)
            #TODO 谁是container
            container = @elementAoe
            arr << AElement.new(AOleElement.new(@elementAoe.ie, container, html))
          end
        end
      end
      return arr
    end

    #aoe_element当前同层节点aoe
    #ole当前节点ole
    def get_element_by_tag_in_frame(name, ole, aoe_element)
      arr = []
      if(ole.nodename && ole.nodename.to_s.downcase =~ /^i?frame$/)        
        iframe = [ole]
      else
        iframe = ole.getElementsByTagName("iframe")
        frame = ole.getElementsByTagName("frame")
        i_frame = frame.length
      end
      i_iframe = iframe.length
      if(i_iframe==0 && i_frame==0)
        return arr
      else
        if(i_iframe==0)
          iframe = frame #只统计一种
        end
        iframe.each{|f|
          fr = f.contentWindow
          docu = HtmlHelper.get_document_in_frame(fr)
          c = AOleElement.new(aoe_element.ie, aoe_element.container, f)
          if(docu)
            html = HtmlHelper.get_html_from_document(docu)
            #TODO 谁是container
            oles = html.getElementsByTagName(name)
            oles.each{|o|
              arr << AElement.new(AOleElement.new(aoe_element.ie, c, o))
            }
            arr.concat get_element_by_tag_in_frame(name,html,AOleElement.new(aoe_element.ie, c, html))
          end
        }
        return arr
      end
    end
    
    def get_element_by_control_name(name, scope)
      if(scope.eql?(:Descendant))
        begin
          ole = self.element.element
          oles = ole.getElementsByTagName(name)
          arr = []
          oles.each{|o|
            #还没有加进去iframe下的同tag
            arr << AElement.new(AOleElement.new(@elementAoe.ie, @elementAoe.container, o))
          }
          frame_arr = get_element_by_tag_in_frame(name,ole,@elementAoe)
          return arr.concat(frame_arr)
        rescue => e
          TestRunLogger.instance.log_debug_message("[DEBUG]抓取getElementsByTagName失败，#{e}")
        end
      end
      collection = get_scope_element(scope)
      self.class.filter_collection(collection, name, :ControlName)
      return collection
    end

    def parent
      pnode = @elementD.parentNode
      if(pnode)
        if(pnode.nodeName.downcase != "#document") #遇到不是#document就直接返回parentNode
          return AElement.new(AOleElement.new(@elementAoe.ie, @elementAoe.container, pnode))
        end        
      end
      container = @elementAoe.container
      if(container)
        #回到container
        return AElement.new(AOleElement.new(@elementAoe.ie, container.container, container.element))
      else
        return nil
      end
      
    end

    def _text
      if(is_element)
        result = inner_text
      else
        result = get_attribute("NodeValue")
      end
      return result
    end
    #获取控件的inner_text属性值
    #@return [String]
    #@example page.dft_buy.text
    def text
      if empty?
        Logger.log_element_empty(self)
        return nil
      end
      result = _text
      Logger.log_operation_success(self)
      return result
    end
    #获取控件的inner_text属性值
    #@return [String]
    #@example page.dft_buy.inner_text
    def inner_text
      return nil if empty?
      @elementD.innerText
    end
    #获取控件的inner_html属性值
    #@return [String]
    #@example page.dft_buy.inner_html
    def inner_html
      return nil if empty?
      @elementD.innerHtml
    end
    #获取控件的outer_html属性值
    #@return [String]
    #@example page.dft_buy.outer_html
    def outer_html
      return nil if empty?
      begin
        #        Iconv.conv("GBK//IGNORE","UTF-8//IGNORE", @elementD.outerHtml)
        @elementD.outerHtml
      rescue
        #TODO 记log
        return nil
      end
    end

    def get_attribute(name)
      return nil if empty?
      #增加一个style，做为对style的支持
      if(name.downcase == "style")
        begin
          style = @elementD.invoke("style")
          result = style.csstext
          return result
        rescue
          #TODO: 记log
          return nil
        end
      else
        #让class和classname都代表html里的class
        if(name.downcase == "class") #ISSUE 假设classname这个属性在html里不存在
          name = "classname"
        end

        begin
          result = @elementD.invoke(name)
          return result
        rescue
          #TODO: 记log
          return nil
        end
      end
    end

    #这个页面拿id时会有bug，返回的id不是string而是win32ole对象，http://favorite.daily.taobao.net/popup/add_collection.htm?id=1600052554&itemtype=1&scjjc=1&nekot=1279180794088
    #采用这种方式绕开。
    def get_attribute_from_list(name)
      atts = @elementD.attributes
      atts.each{|e|
        if(e.nodeName==name)
          return e.nodeValue
        end
      }
      return nil
    end

    #取控件的属性，包括text, inner_test, inner_html等
    #@param  [String] name 控件属性名称
    #@return [String] 控件属性名称对应的值
    #@example property = page.dft_buy.get("class")=> "btn"
    def get(name)
      #劫持，假设html里没有text这个属性
      if(name.downcase == "text")
        return text #Known issue: 会导致log信息不精确，可以接受？
      end
      if empty?
        Logger.log_element_empty(self, name)
        return nil
      else
        result = get_attribute(name)
        if(result.nil?)
          Logger.log_operation_fail(self, name)
          return nil
        else
          Logger.log_operation_success(self, name)
          return result
        end
      end
    end

    def eql?(element)
      return super unless(element)
      is_e = is_element
      unless(is_e^(element.is_element))
        if(is_e)
          return @elementD.sourceIndex == element.element.element.sourceIndex
        else
          if(HtmlHelper.get_current_tag_and_index(self) == HtmlHelper.get_current_tag_and_index(element))
            return parent.eql?(element.parent)
          else
            return false
          end
        end
      else
        return false
      end
    end

    alias == eql?
    
    def _class
      begin
        @elementD.classname
      rescue
        #TODO 记log
        return nil
      end
    end

    def _next
      if @elementD.nextSibling
        return AElement.new(AOleElement.new(@elementAoe.ie, @elementAoe.container, @elementD.nextSibling))
      else
        return nil
      end
    end
    #获取控件的id属性值
    #@return [String]
    #@example page.dft_buy.id => "kw"
    def id
      begin
        result = @elementD.Id
        unless (result.is_a? String)
          result = get_attribute_from_list("id")
        end
        return result
      rescue
        #TODO log here
        return nil
      end
    end

    #将一个元素滚动到视窗
    #@param [Boolean]  true 元素会被滚动到视窗的顶部，false 会被滚动到视窗底部，默认为true
    #@example page.rad_addrId.scrollIntoView
    def scrollIntoView(top = true)
      @elementD.scrollIntoView(top)
      sleep 0.1 #等待事件触发
      wait
    end
    #将焦点定位到当前控件
    #@example  page.dft_buy. focus
    def focus
      if empty?
        Logger.log_element_empty(self)
      else
        @elementD.focus
        Logger.log_operation_success(self)
      end
    end
    #模拟鼠标动作，触发控件的事件
    #@param [String] name 鼠标事件
    #@example page.dft_buy. fire_event("onmouseover")
    def fire_event(name)
      if empty?
        Logger.log_element_empty(self)
      else
        @elementD.fireEvent(name)
        Logger.log_operation_success(self, name)
      end
    end
    #等待IE加载
    #@example ie.wait
    def wait
      @ie.wait
    end
    # 取控件的长度
    # @return [Fixnum] 控件的长度
    # @example page.dft_buy.height => 28
    def height
      return @elementD.offsetHeight
    end
    # 取控件的宽度
    # @return [Fixnum] 控件的宽度
    # @example page.dft_buy.width => 12
    def width
      return @elementD.offsetWidth
    end
    # 获取控件的中心点位置
    # @return [Point] 控件中心点，供鼠标点击使用
    # 如果控件在窗口外，自动将控件移动到窗口内
    #@example page.dft_login.center_point=> #<struct AWatir::Point x=568, y=161>

    def center_point
      p = offset_point
      x = p.x + width/2
      y = p.y + height/2

      return Point.new(x, y)
    end
    #获取控件的左上顶点的值
    # @return [Point] 控件左上顶点的值，供鼠标点击、截图使用
    # 如果控件在窗口外，自动将控件移动到窗口内
    #@example page.dft_login.offset_point=> #<struct AWatir::Point x=568, y=161>
    def offset_point
      if @elementD.offsetWidth.to_i ==0 || @elementD.offsetHeight.to_i ==0
        raise "需要显示的元素在界面上不可见，元素的html为:#{@elementD.outerHTML}"
      end

      top = @elementD.offsetTop
      left = @elementD.offsetLeft

      parent_ole_obj = @elementD.offsetParent
      while parent_ole_obj.tagName.downcase !="body" && parent_ole_obj.tagName.downcase !="html"
        top += parent_ole_obj.offsetTop
        left += parent_ole_obj.offsetLeft
        parent_ole_obj = parent_ole_obj.offsetParent
      end
      body_ole_obj = parent_ole_obj.document.documentElement
      if  body_ole_obj.clientHeight.to_i == 0
        body_ole_obj = parent_ole_obj.document.body
      end
      top +=body_ole_obj.ClientTop
      left += body_ole_obj.ClientLeft

      top -= body_ole_obj.ScrollTop
      left -= body_ole_obj.ScrollLeft

      right = left + width
      bottom = top + height

      current_width = body_ole_obj.ClientLeft + body_ole_obj.ClientWidth
      current_height =  body_ole_obj.ClientTop + body_ole_obj.ClientHeight
      if (right > current_width || bottom > current_height)
        @elementD.scrollIntoView

        top = @elementD.offsetTop
        left = @elementD.offsetLeft

        parent_ole_obj = @elementD.offsetParent
        while parent_ole_obj.tagName.downcase !="body"
          top += parent_ole_obj.offsetTop
          left += parent_ole_obj.offsetLeft
          parent_ole_obj = parent_ole_obj.offsetParent
        end
        body_ole_obj = parent_ole_obj.document.documentElement

        if  body_ole_obj.clientHeight.to_i == 0
          body_ole_obj = parent_ole_obj.document.body
        end
        top +=body_ole_obj.ClientTop
        left += body_ole_obj.ClientLeft

        top -= body_ole_obj.ScrollTop
        left -= body_ole_obj.ScrollLeft
      end
      x= left
      y= top

      x =  x + @ie.document.parentWindow.screenLeft
      y = y + @ie.document.parentWindow.screenTop

      return Point.new(x+2, y+2) # 2,2经验值
    end
    #模拟鼠标的点击操作
    #@example page.dft_login._doclick

    def _doclick
      p = center_point

      hwnd = @ie.hwnd
      win_object = WinObject.new
      win_object.makeWindowActive(hwnd)
      win_object.setWindowTop(hwnd)

      cs=Cursor.new
      cs.pos=p
      cs.click
      sleep 0.1   #等待事件的触发
      @ie.wait
    end
    #控件截图方法，能将控件精确地截下来。
    #@return [String] 返回截图之后的图片存放位置
    #@example  page.dft_login.capture
    def capture
      if empty?
        Logger.log_element_empty(self)
      else
        hwnd = @ie.hwnd
        win_object = WinObject.new
        win_object.makeWindowActive(hwnd)
        win_object.setWindowTop(hwnd)
        sleep 0.2 #等待拿到前台

        path = captureBMP(offset_point.x, offset_point.y, width, height)
        Logger.log_operation_success(self)
        return path
      end
    end

    # 进行控件点击操作
    # @example page.dft_login.click
    def click
      if empty?
        Logger.log_element_empty(self)
      else
        @elementD.click
        wait
        Logger.log_operation_success(self)
      end
    end

    #以下是通用方法
    #这个是给netbeans调试用的
    def to_s
      return string_creator.join(",\r\n")
    end

    #这个是给irb用的，调试出的信息。
    def inspect
      if(self.empty?)
        return "Empty Node"
      else
        return "\r\n" + string_creator.join(",\r\n")
      end
    end

    def array_search_text
      if(self.empty?)
        return "Empty Node"
      else
        return self._text.to_s
      end
    end

    def array_search_html
      if(self.empty?)
        return "Empty Node"
      else
        return self.outer_html.to_s
      end
    end

    # 供console使用
    # @private
    TO_S_SIZE = 15
    # Return an array of current node properties, in a format to be used by the method: to_s
    def string_creator
      n = []
      if(self.empty?)
        n << "Empty Node"
      else
        #      n <<   "type:".ljust(TO_S_SIZE) + self.type.to_s
        n <<   "[控件名]".ljust(TO_S_SIZE) + self.control.to_s

        n << "[文本]".ljust(TO_S_SIZE) + self._text.to_s unless (self.is_element)

        n <<   "[ID]".ljust(TO_S_SIZE) + self.id.to_s if (self.id && !self.id.empty?)
        n <<   "[class]".ljust(TO_S_SIZE) + self._class.to_s if (self._class && !self._class.empty?)

        if (self.outer_html && !self.outer_html.empty?)
          before = "[outerHtml]".ljust(TO_S_SIZE) + self.outer_html.to_s
          max_length = 1000
          ommit = "......"
          if(before.length > max_length)
            before = before.slice(0..max_length) + ommit
          end
          n << before
        end
      end
      return n
    end
    private :string_creator
    def is_element
      return control!="#text"
    end

    #以下用于debug
    def get_properties
      dic = Hash.new
      return dic unless @elementD
      dic.store("TagName", control)
      dic.store("NodeValue", @elementD.nodeValue) if @elementD.nodeValue
      if is_element
        atts = @elementD.attributes
        puts "Retrieving #{atts.length} attributes for current node."
        atts.each do |e|
          if(e.nodeValue && e.nodeValue.to_s!="")
            dic.store(e.nodeName, e.nodeValue)
          end
        end
        style = @elementD.invoke("style")
        if(style)
          csstext = style.csstext
          if(csstext && csstext.to_s!="")
            dic.store("style", csstext)
          end
        end
      end
      return dic
    end
  end

end