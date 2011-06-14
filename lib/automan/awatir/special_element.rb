#这里列的是淘宝页面上用到的特殊的Element，测试人员也可以自己添加需要特殊处理的控件类型，以便在页面模型中引用
module AWatir
  #富文本控件，继承AElement的所有方法
  class AInnerTextSetElement < AElement
    #对富文本的输入操作
    #@param [String] value 输入的内容
    #@example  page.dft_editor.set("欢迎到我的世界！")
    def set(value)
      if(empty?)
        Logger.log_element_empty(self, value)
      else
        @elementD.innerText = value
        Logger.log_operation_success(self, value)
      end
    end
  end
  #需要做doclick操作的控件，继承AElement的所有方法
  class ADoClickElement < AElement
    #对需要做doclick操作的控件，进行doclick操作
    #@example  page.btn_editor.click
    def click
      if(empty?)
        Logger.log_element_empty(self)
      else
        self._doclick
        Logger.log_operation_success(self)
      end
    end
  end

  #对点击后会触发弹出框的控件定义的类型，继承AElement的所有方法
  class ANoWaitElement < AElement

    def click_wait
      @elementD.click
    end
    #异步点击
    #@example page.dft_confirm.click
    def click
      if(empty?)
        Logger.log_element_empty(self)
      else
        HtmlHelper.click_in_spawned_process(self)
      end
    end
  end
end
