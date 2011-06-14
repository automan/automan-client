module AWatir
  #输入框控件，继承AElement的所有方法
  class ATextField < AElement
    #这种初始化方法是给Model的Find方法来调的
    def initialize(a_ole_object)
      super
    end    

    #获取输入框控件的readonly属性值
    #@return [Boolean] true/false
    #@example  readonly_value = page.txt_password.readonly  readonly_value=>true
    def readonly
      @elementD.readonly
    end
    # instance.readonly = true
    # instance.readonly = false
    #对输入框控件的readonly属性值赋值
    #@param [Boolean] true/false
    #@example  page.txt_password.readonly=true
    def readonly=value
      @elementD.readonly=value
    end
    # 对输入框输入值
    #@param [String] value 需要输入的内容
    #@example page.txt_password.set("Hello!")
    def set(value)
      if(empty?)
        Logger.log_element_empty(self, value)
      else
        begin
          _set(value)
          Logger.log_operation_success(self, value)
        rescue
          Logger.log_operation_fail(self, value)
        end
      end      
    end

    # settings
    def _type_keys
      return true
    end
    def _typingspeed
      return 0.1
    end

    def _set(value)
      @elementD.scrollIntoView
      if _type_keys
	      @elementD.focus
	      @elementD.select
	      @elementD.fireEvent("onSelect")
	      @elementD.fireEvent("onKeyPress")
	      @elementD.value = ""
	      _type_by_character(value)
	      @elementD.fireEvent("onChange")
	      @elementD.fireEvent("onBlur")
	    else
				@elementD.value = value
      end
    end

    # Type the characters in the specified string (value) one by one.
    # It should not be used externally.
    #   * value - string - The string to enter into the text field
    def _type_by_character(value)
      if @elementD.invoke('type') =~ /textarea/i # text areas don't have maxlength
        maxlength = -1
      else
        maxlength = @elementD.maxlength
      end
      
      _characters_in(value, maxlength) do |c|
        sleep _typingspeed
        @elementD.value = @elementD.value.to_s + c
        @elementD.fireEvent("onKeyDown")
        @elementD.fireEvent("onKeyPress")
        @elementD.fireEvent("onKeyUp")
      end
    end

    # Supports double-byte characters
    # @param [String] maxlength 输入自动截取maxlength的长度，当maxlength<0时，不截取
    def _characters_in(value, maxlength, &blk)
      if RUBY_VERSION =~ /^1\.8/
        index = 0        
        while index < value.length
          len = value[index] > 128 ? 2 : 1
          yield value[index, len]
          maxlength = maxlength - 1
          break if(maxlength==0)
          index += len
        end
      else
        value.each_char{|c|
          yield c
          maxlength = maxlength - 1
          break if(maxlength==0)
        }
      end
    end
  end

  # ATextArea，是ATextField的别名
  ATextArea = ATextField
 
  #继承AElement的所有方法
  class ALink < AElement
    #这种初始化方法是给Model的Find方法来调的
    def initialize(a_ole_object)
      super
      #当empty为true时，@operator=true；当empty为false时，@operator=XXX.new(...)
      @operator = empty? || Watir::Link.new(a_ole_object.ie, :ole_object, a_ole_object.element)
    end

    #这种初始化方法是直接从ie来调的，一期需要实现，以后可以不用了
    def self.create(ie, how, what)
      operator = Watir::Link.new(ie, how, what)
      element_t = AOleElement.new(ie, ie, operator.document)
      instance = self.new(element_t)
      instance.operator = operator
      return instance;
    end

    #点击操作
    #@example page.lnk_standard_login.click
    def click()
      if(empty?)
        Logger.log_element_empty(self)
      else
        @operator.click
        Logger.log_operation_success(self)
      end  
    end
  end
  
  # Button控件，继承AElement的所有方法
  class AButton < AElement
    #这种初始化方法是给Model的Find方法来调的
    def initialize(a_ole_object)
      super
      #当empty为true时，@operator=true；当empty为false时，@operator=XXX.new(...)
      @operator = empty? || Watir::Button.new(a_ole_object.ie, :ole_object, a_ole_object.element)
    end

    #这种初始化方法是直接从ie来调的，一期需要实现，以后可以不用了
    def self.create(ie, how, what)
      operator = Watir::Button.new(ie, how, what)
      element_t = AOleElement.new(ie, ie, operator.ole_object)
      instance = self.new(element_t)
      instance.operator = operator
      return instance;
    end
    #功能：点击控件
    # @example  page.btn_login.click
    def click()
      if(empty?)
        Logger.log_element_empty(self)
      else
        @operator.click
        Logger.log_operation_success(self)
      end
    end

  end
  #checkbox复选框，继承AElement的所有方法
  class ACheckBox < AElement
    #这种初始化方法是给Model的Find方法来调的
    def initialize(a_ole_object)
      super
    end

    #判断控件是否被选中
    #@return [Boolean] true:被选中；false:未被选中
    #@example value = page.chk_order.checked
    def checked
      return @elementD.checked
    end
    
    #点击CheckBox，选中控件
    #@example  page.chk_order.set
    def set
      if(empty?)
        Logger.log_element_empty(self)
      else
        begin
          set_clear_item(true)
          Logger.log_operation_success(self)
        rescue
          Logger.log_operation_fail(self)
        end
      end
    end

    def set_clear_item(set)
      unless @elementD.checked == set
        @elementD.checked = set
        @elementD.fireEvent("onClick")
        if @elementAoe.container
          @elementAoe.container.wait #TODO 这里有bug的。还没有定义@elementAoe.container.wait方法。
        else
          @elementAoe.ie.wait
        end
      end
    end
    private :set_clear_item
    
    #点击CheckBox，取消对CheckBox的选中
    #@example  page.chk_order.clear
    def clear
      if(empty?)
        Logger.log_element_empty(self)
      else
        begin
          set_clear_item(false)
          Logger.log_operation_success(self)
        rescue
          Logger.log_operation_fail(self)
        end
      end
    end
  end
  
  #Radio控件类型，继承AElement的所有方法
  class ARadio < AElement
    #这种初始化方法是给Model的Find方法来调的
    def initialize(a_ole_object)
      super
      #当empty为true时，@operator=true；当empty为false时，@operator=XXX.new(...)
      @operator = empty? || Watir::Radio.new(a_ole_object.ie, :ole_object, a_ole_object.element)
    end

    #这种初始化方法是直接从ie来调的，一期需要实现，以后可以不用了
    def self.create(ie, how, what)
      operator = Watir::Radio.new(ie, how, what)
      element_t = AOleElement.new(ie, ie, operator.ole_object)
      instance = self.new(element_t)
      instance.operator = operator
      return instance;
    end

    #点击Radio，选中Radio
    #@example  page.rad_addrId.set
    def set
      if(empty?)
        Logger.log_element_empty(self)
      else
        begin
          @operator.set
          Logger.log_operation_success(self)
        rescue
          Logger.log_operation_fail(self)
        end
      end
    end
    #点击Radio，取消对Radio的选中
    #@example  page.rad_addrId.clear
    def clear
      if(empty?)
        Logger.log_element_empty(self)
      else        
        begin
          @operator.clear
          Logger.log_operation_success(self)
        rescue
          Logger.log_operation_fail(self)
        end
      end
    end
    #判断控件是否被选中
    #@return [Boolean] true:被选中；false:未被选中
    #@example value =  page.rad_addrId.checked
    # instance.checked => false / true
    def checked
      return @operator.set?
    end
  end
  #SelectList控件类型，继承AElement的所有方法
  class ASelectList < AElement
    #这种初始化方法是给Model的Find方法来调的
    def initialize(a_ole_object)
      super
      #当empty为true时，@operator=true；当empty为false时，@operator=XXX.new(...)
      @operator = empty? || Watir::SelectList.new(a_ole_object.ie, :ole_object, a_ole_object.element)
    end

    #这种初始化方法是直接从ie来调的，一期需要实现，以后可以不用了
    def self.create(ie, how, what)
      operator = Watir::SelectList.new(ie, how, what)
      element_t = AOleElement.new(ie, ie, operator.ole_object)
      instance = self.new(element_t)
      instance.operator = operator
      return instance;
    end
    #对下拉选择框进行选择
    #@param [String] value 输入需要选择的选项内容
    #@example  page.lst_addrId.set ("浙江")
    # instance.set("选项1")
    def set (value)
      if value.is_a? Fixnum
        value=value.to_s
      end
      if(empty?)
        Logger.log_element_empty(self, value)
      else
        begin
          @operator.select value
          Logger.log_operation_success(self, value)
        rescue
          Logger.log_operation_fail(self, value)
        end
      end
    end
    # 返回 第一个被选中的选项
    # @return [String]
    # @example select_value = page.lst_addrId.selected_value
    # select_value => "选项1"
    def selected_value
      if(empty?)
        Logger.log_element_empty(self)
      else
        return @operator.selected_options.first
      end
    end


    #获取ASelectList的所有options
    #@return [Array]
    #@example options_value = page.lst_addrId.options
    # options_value => ['选项1', '选项2', '选项3']
    def options
      return @operator.options
    end
  end

end


