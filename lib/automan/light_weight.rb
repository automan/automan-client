require 'automan/mini'

module AWatir
  #提供没有页面模型下，方便使用automan的方式
  class AutomanIE < IEModel
    #查找满足条件的元素，类型为默认
    #@param [String] selector 元素查找方式
    #@return [AWatir::AElement]
    def element(selector)
      return find(AWatir::AElement, selector)
    end
    #查找满足条件的元素集合
    #@return [Array<AWatir::AElement>]
    def elements(selector)
      return finds(AWatir::AElement, selector)
    end
    #查找满足条件的按钮
    #@return [AWatir::AButton]
    def button(selector)
      return find(AWatir::AButton, selector)
    end
    #查找满足条件的链接
    #@return [AWatir::ALink]
    def link(selector)
      return find(AWatir::ALink, selector)
    end
    #查找满足条件的文本框
    #@return [AWatir::ATextField]
    def text_field(selector)
      return find(AWatir::ATextField, selector)
    end
    #查找满足条件的勾选框
    #@return [AWatir::ACheckBox]
    def checkbox(selector)
      return find(AWatir::ACheckBox, selector)
    end
    #查找满足条件的选择按钮
    #@return [AWatir::ARadio]
    def radio(selector)
      return find(AWatir::ARadio, selector)
    end
    #查找满足条件的下拉单
    #@return [AWatir::ASelectList]
    def select_list(selector)
      return find(AWatir::ASelectList, selector)
    end
    #查找满足条件的富文本框，即需要set inner text的控件
    #@return [AWatir::AInnerTextSetElement]
    def rich_text(selector)
      return find(AWatir::AInnerTextSetElement, selector)
    end
    #查找满足条件的带弹出框的控件
    #@return [AWatir::ANoWaitElement]
    def no_wait(selector)
      return find(AWatir::ANoWaitElement, selector)
    end

    #查找满足条件的模型
    #@return [AutomanModel] 返回的模型，用以继续查找
    def model(selector)
      return  _internal_cast(HtmlModel).find_model(AutomanModel, selector)
    end
    #@return [Array<AutomanModel>] 返回的模型的集合
    def models(selector)
      return  _internal_cast(HtmlModel).find_models(AutomanModel, selector)
    end
    
    def find(type, selector)
      return _internal_cast(HtmlModel).find_element(type, selector)
    end
    private :find
    def finds(type, selector)
      return _internal_cast(HtmlModel).find_elements(type, selector)
    end
    private :finds
  end
  class AutomanModel < HtmlModel
    #@see AutomanIE#element
    #@return (see AutomanIE#element)
    def element(selector)
      return find(AWatir::AElement, selector)
    end
    #@see AutomanIE#elements
    #@return (see AutomanIE#elements)
    def elements(selector)
      return finds(AWatir::AElement, selector)
    end
    #@see AutomanIE#button
    #@return (see AutomanIE#button)
    def button(selector)
      return find(AWatir::AButton, selector)
    end
    #@see AutomanIE#link
    #@return (see AutomanIE#link)
    def link(selector)
      return find(AWatir::ALink, selector)
    end
    #@see AutomanIE#text_field
    #@return (see AutomanIE#text_field)
    def text_field(selector)
      return find(AWatir::ATextField, selector)
    end
    #@see AutomanIE#checkbox
    #@return (see AutomanIE#checkbox)
    def checkbox(selector)
      return find(AWatir::ACheckBox, selector)
    end
    #@see AutomanIE#radio
    #@return (see AutomanIE#radio)
    def radio(selector)
      return find(AWatir::ARadio, selector)
    end
    #@see AutomanIE#select_list
    #@return (see AutomanIE#select_list)
    def select_list(selector)
      return find(AWatir::ASelectList, selector)
    end
    #@see AutomanIE#rich_text
    #@return (see AutomanIE#rich_text)
    def rich_text(selector)
      return find(AWatir::AInnerTextSetElement, selector)
    end
    #@see AutomanIE#no_wait
    #@return (see AutomanIE#no_wait)
    def no_wait(selector)
      return find(AWatir::ANoWaitElement, selector)
    end
    
    #@see AutomanIE#model
    def model(selector)
      return  find_model(AutomanModel, selector)
    end
    #@see AutomanIE#models
    def models(selector)
      return  find_models(AutomanModel, selector)
    end

    def find(type, selector)
      return find_element(type, selector)
    end    
    private :find
    def finds(type, selector)
      return find_elements(type, selector)
    end
    private :finds
  end
end
