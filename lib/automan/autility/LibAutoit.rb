#LibAutoit主要处理windows弹出的对话框，调用autoit类进行处理
#函数如下：
#- ChooseFileDialog函数：处理选择文件对话框窗口
#- clearSecurityAlert函数：处理安全警告对话框
#- ControlSetText函数：给对话框中的某个控件设置值
#- ControlClick函数：向指定控件发送鼠标点击命令
#- ControlGetText函数：获取指定控件值
#- ControlGetHandle函数：获取指定控件值的句柄
#- ControlFocus函数：设置输入焦点到指定窗口的某个控件上
#- DealDownloadDialog函数：处理文件下载对话框
#- DealPathDialog函数：设置下载文件路径及操作下载，如果文件已存在则覆盖处理
#- DealAlterDialog函数：处理Alter对话框
#- DealConfirmDialog函数：处理Confirm对话框
#- DealPromptDialog函数：处理Prompt对话框
#- DealSecurity函数：点击页面链接，使弹出安全警告对话框
#- GetDialogTitle函数：根据类型获取弹出的窗口标题
#- SendKey函数：模拟键盘输入字符
#- WinExists函数：判断窗口是否存在

module LibAutoit
  class AutoItApi
    include Singleton 
    #功能说明：根据类型获取弹出的窗口标题，因为IE各版本弹出的对话框标题有差异，需要进行特殊处理
    #
    #参数说明：
    #type：窗口类型，具体值如下：
    #- type=1：选择文件窗口标题
    #- type=2：Alter窗口标题
    #- type=3：Prompt窗口标题
    #- type=4：安全警告窗口标题
    #- type=5：文件下载窗口标题
    #- type=6：文件另存为窗口标题
    #
    #调用示例： GetDialogTitle(2)
    #
    #返回值说明：
    #- 成功：返回获取的标题
    #- 失败：返回false    
    def GetDialogTitle(type = 2)
      #$logger.log("调用函数：LibAutoit.rb文件中的GetDialogTitle(#{type})" )

      dialog_title = ListDialogTitle(type)

      dialog_title.each do |title|
        if (WinExists(title,'') == 1)
          puts "获取的窗口：#{title}"
          return  title
        end
      end
      return false
    end

    def ListDialogTitle(type = 2)
      case type
      when 1 #选择文件窗口标题
        dialog_title = ['选择文件', 'Choose file', '选择要加载的文件']
      when 2 #Alter窗口标题
        dialog_title = ['Microsoft Internet Explorer','Windows Internet Explorer', '来自网页的消息']
      when 3 #Prompt窗口标题
        dialog_title = ['Explorer 用户提示','Explorer User Prompt']
      when 4 #安全警告窗口标题
        dialog_title = ['安全警告','Security Alert']
      when 5 #文件下载窗口标题
        dialog_title = ['文件下载 - 安全警告','文件下载','File Download']
      when 6  #文件另存为窗口标题
        dialog_title = ['另存为']
      end
      return dialog_title
    end

    #功能说明：处理文件下载对话框，调用DealPathDialog函数设置路径及下载文件
    #
    #参数说明：
    #- file_path：文件下载后存放的路径，格式如：c:\\test
    #- file_name：文件名，如：test.txt
    #- timeout：对话框处理的超时时间，默认为20秒
    #
    #调用示例： DealDownloadDialog(“c:\\test\test.txt”,15)
    #
    #返回值说明：
    #-  成功：返回ture
    #- 失败：返回false
    def DealDownloadDialog(file_path,file_name,timeout = @DealDownloadDialogTimeOut )
      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #判断处理时间是否超时

          win_title = GetDialogTitle(5) #获取窗口标题

          if (win_title)
            @autoit.WinActivate(win_title,'')
            sleep(1)
            ControlClick(win_title,'','Button2')

            DealPathDialog(file_path,file_name)

            '----------deal with download File dialog end----------'
            "调用函数结束：LibAutoit.rb文件中的DealDownloadDialog()，返回结果：true"
            return true
          end
          sleep 1
        else
          "Deal Download File Dialog Fail!"
          '----------deal with download File dialog end----------'
          "调用函数结束：LibAutoit.rb文件中的DealDownloadDialog()，返回结果：false"
          return false
        end
      end
    end


    #功能说明：设置下载文件路径及操作下载，如果文件已存在则覆盖处理
    #
    #参数说明：
    #- file_path：文件下载后存放的路径，格式如：c:\\test
    #- file_name：文件名，如：test.txt
    #- timeout：对话框处理的超时时间，默认为20秒
    #
    #调用示例：
    #- DealPathDialog(“c:\\test”,"test.txt")
    #
    #返回值说明：
    #-  成功：返回true
    #- 失败：返回false
    def DealPathDialog(file_path,file_name = '',timeout = @DealPathDialogTimeOut )
      "调用函数：LibAutoit.rb文件中的DealPathDialog(#{file_path},#{file_name},#{timeout})"

      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #判断处理时间是否超时
          win_title = GetDialogTitle(6) #获取窗口标题
          if (win_title)
            @autoit.WinActivate(win_title,'')

            if (!FileTest::exist?(file_path))
              FileUtils.makedirs(file_path)
            end

            file_full_path = "#{file_path}\\#{file_name}"
            
            real_file_path = LibAutoit::GetRealPath(file_full_path,'N')
            real_full_path = "#{real_file_path}\\#{file_name}"

            ControlSetText(win_title,'','Edit1',real_full_path)
            SendKey("!S")
            #ControlClick(win_title,'','Button2')

            if (WinExists(win_title,'替换') == 1)
              @autoit.WinActivate(win_title,'替换')
              ControlClick(win_title,'替换','Button1')
            end

            "调用函数结束：LibAutoit.rb文件中的DealPathDialog()"
            return true
          end
          sleep 1
        else
          "Deal File Path Dialog Fail!"
          "调用函数结束：LibAutoit.rb文件中的DealPathDialog()"
          return false
        end
      end
    end

    #功能说明：处理选择文件对话框窗口
    #
    #参数说明：无
    #- file_path：文件下载后存放的路径，格式：目录+文件名，如：c:\\test\\test.txt
    #- timeout：对话框处理的超时时间，默认为20秒
    #
    #调用示例： ChooseFileDialog(“c:\\test\\test.txt”,15)
    #
    #返回值说明：
    #-  成功：返回true
    #- 失败：返回false
    def ChooseFileDialog(file_path,timeout = @ChooseFileDialogTimeOut)
      "调用函数：LibAutoit.rb文件中的ChooseFileDialog(#{file_path},#{timeout})"

      '----------deal with Choose File dialog begin----------'
      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #判断处理时间是否超时
          win_title = GetDialogTitle(1) #获取窗口标题
          if (win_title)
            @autoit.WinActivate(win_title,'')

            if (FileTest::exist?(file_path))
              real_file_path = LibAutoit::GetRealPath(file_path)  #获取真实路径

              ControlSetText(win_title,'','Edit1',real_file_path)
              
              #抄的deal_dialog的代码，后续优化抽象
              buttons_info=Win32Helper._list_window_buttons(win_title)
              buttons_instance = []
              buttons_title = []
              for i in 0..buttons_info.length-1
                arr=buttons_info[i].split(":")
                buttons_instance << arr[0]
                buttons_title <<  arr[1]
              end
              if index = buttons_title.index("打开(&O)")
                ControlClick(win_title,'',buttons_instance[index])
              else
                puts "无法找到按钮：打开(&O)"
              end

              '----------deal with Choose File dialog end----------'
              "调用函数结束：LibAutoit.rb文件中的ChooseFileDialog(#{file_path},#{timeout})"

              return true
            else
              '----------deal with Choose File dialog end----------'
              "调用函数结束：LibAutoit.rb文件中的ChooseFileDialog(#{file_path},#{timeout})"
              puts "上传文件路径不存在，请确认文件路径是否正确（注意:文件路径请用'\\\\'或'/'）！"
              return false
            end
          end
          sleep 1
        else
          "Deal Choose File Dialog Fail!"
          '----------deal with Choose File dialog end----------'
          "调用函数结束：LibAutoit.rb文件中的ChooseFileDialog(#{file_path},#{timeout})"
          return false
        end
      end
    end

    #功能说明：处理Alter对话框
    #
    #参数说明：
    #- timeout：对话框处理的超时时间，默认为20秒
    #
    #调用示例： DealAlterDialog(15)
    #
    #返回值说明：
    #-  成功：返回对话框中的文本提示内容
    #- 失败：返回false
    def DealAlterDialog(timeout = @DealAlterDialogTimeOut )
      "调用函数：LibAutoit.rb文件中的DealAlterDialog(#{timeout})"
      '----------deal with alter dialog begin----------'

      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #判断处理时间是否超时
          win_title = GetDialogTitle(2) #获取窗口标题
          if (win_title)
            @autoit.WinActivate(win_title,'')

            alter_content =  ControlGetText(win_title,'','Static2')
            SendKey('{ENTER}')
            #ControlClick('Windows Internet Explorer','','Button1')
            #puts "alter message:\n #{alter_content}"

            "the content of alter dialog： #{alter_content}"
            '-----------deal with alter dialog end-----------'
            "调用函数结束：LibAutoit.rb文件中的DealAlterDialog(#{timeout})"
            return alter_content
          end
          sleep 1
        else
          "deal with alter dialog fail!"
          '-----------deal with alter dialog end-----------'
          "调用函数结束：LibAutoit.rb文件中的DealAlterDialog(#{timeout})"
          return false
        end
      end
    end

    #功能说明：处理Confirm对话框
    #
    #参数说明：
    #- type：点击确定或取消按钮，Y：确定  N：取消
    #- timeout：对话框处理的超时时间，默认为20秒
    #
    #调用示例： DealConfirmDialog()
    #
    #返回值说明：
    #-  成功：返回对话框中的文本提示内容
    #- 失败：返回false
    def DealConfirmDialog(type="确定",timeout = @DealConfirmDialogTimeOut)
      type="确定" if(type.nil?)
      puts "调用函数：LibAutoit.rb文件中的DealConfirmDialog()"
      puts '----------deal with confirm dialog begin----------'
      start_time = Time.now.to_i
      win_title = ""
      while 1
        if (Time.now.to_i-start_time < timeout)   #判断处理时间是否超时
          win_title = GetDialogTitle(2) #获取窗口标题'
          #win_title = "打印"
          #puts   win_title
          if (win_title)
            @autoit.WinActivate(win_title,'')
            buttons_info=AWatir::Win32Helper._list_window_buttons(win_title)
            buttons_instance = []
            buttons_title = []
            for i in 0..buttons_info.length-1
              arr=buttons_info[i].split(":")
              buttons_instance << arr[0]
              buttons_title <<  arr[1]
            end
            #if type.nil?
            # ControlClick(win_title, "", "[CLASS:Button; TEXT:确定]")
            if type =~ /^Button/
              if  buttons_instance.include?(type)
                ControlClick(win_title,'',type)
              else
                puts "控件：#{type}不存在，请校验输入的Button序号是否正确！"
              end
            elsif index = buttons_title.index(type)
              ControlClick(win_title,'',buttons_instance[index])              
            else
              puts "控件不存在，请校验输入的控件名称是否正确！"
              return false
            end
            puts  '-----------deal with confirm dialog end-----------'
            puts  "调用函数结束：LibAutoit.rb文件中的DealConfirmDialog()"
            return true
          end
          sleep 1
        else
          puts "无法用标题：#{ListDialogTitle(2)}，定位对话框！"
          puts '-----------deal with confirm dialog end-----------'
          puts "调用函数结束：LibAutoit.rb文件中的DealConfirmDialog()"
          return false
        end
      end
    end


    def DealConfirmContent(timeout = @DealConfirmDialogTimeOut)
      puts "调用函数：LibAutoit.DealConfirmContent()"
      puts '----------deal with confirm content begin----------'
      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #判断处理时间是否超时
          win_title = GetDialogTitle(2) #获取窗口标题'
          if (win_title)
            @autoit.WinActivate(win_title,'')

            confirm_content =  ControlGetText(win_title,'','Static2')
            puts "the content of confirm dialog： #{confirm_content} "
            puts  '-----------deal with confirm content end-----------'
            puts  "调用函数结束：LibAutoit.DealConfirmContent()()"

            return confirm_content
          end
          sleep 1
        else
          puts "Failed!!!! deal with confirm content fail!"
          puts '-----------deal with confirm content end-----------'
          puts "调用函数结束：LibAutoit.DealConfirmContent()()"
          return false
        end
      end
    end
    #功能说明：处理Prompt对话框
    #
    #参数说明：
    #- string：输入的文本内容
    #- type：点击确定或取消按钮，Y：确定  N：取消
    #- timeout：对话框处理的超时时间，默认为20秒
    #
    #调用示例： DealPromptDialog('test','Y',15)
    #
    #返回值说明：
    #-  成功：返回true
    #- 失败：返回false
    def DealPromptDialog(string = '',type = 1,timeout = @DealPromptDialogTimeOut )
      "调用函数：LibAutoit.rb文件中的DealPromptDialog(#{string},#{type},#{timeout})"

      puts '----------deal with prompt dialog begin----------'
      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #判断处理时间是否超时
          win_title = GetDialogTitle(3) #获取窗口标题
          if (win_title)
            @autoit.WinActivate(win_title,'')

            ControlSetText(win_title,'','Edit1',string)

            if type == ControlGetText(win_title,'','Button1') || type == 1
              ControlClick(win_title,'','Button1')
            elsif type == ControlGetText(win_title,'','Button2') || type == 2
              ControlClick(win_title,'','Button2')
            else
              puts "can't find the button,pelease check it"
              return false
            end
            '-----------deal with prompt dialog end-----------'
            "调用函数结束：LibAutoit.rb文件中的DealPromptDialog(#{string},#{type},#{timeout})"

            return true
          end
          sleep 1
        else
          "deal with prompt dialog fail!"
          '-----------deal with prompt dialog end-----------'
          "调用函数结束：LibAutoit.rb文件中的DealPromptDialog(#{string},#{type},#{timeout})"

          return false
        end
      end
    end

    #功能说明：点击页面链接，使弹出安全警告对话框
    #
    #参数说明：
    #- win_title：IE页面的标题
    #- timeout：对话框处理的超时时间
    #
    #调用示例： DealSecurity("ie标题",15)
    #
    #返回值说明：
    #-  成功：返回true
    #- 失败：返回false
    def DealSecurity(win_title,timeout = @DealSecurityTimeOut)
      puts "调用函数：LibAutoit.rb文件中的DealSecurity(#{win_title},#{timeout})"

      start_time = Time.now.to_i

      if (Time.now.to_i-start_time < timeout)   #判断处理时间是否超时
        while 1
          @autoit.ControlClick(win_title,'','Button1')
          sleep(1)
          SendKey('{DOWN}')
          SendKey('{ENTER}')
          sleep(1)

          clearSecurityAlert('Y')  #清除安全框窗口
          return true
        end
      else
        'Deal Security Fail!'
        "调用函数结束：LibAutoit.rb文件中的DealSecurity(#{win_title},#{timeout})"

        return false
      end
    end

    #功能说明：处理安全警告对话框
    #
    #参数说明：
    #- type：选择点击哪个按钮，Y：确定  N：取消
    #- timeout：对话框处理的超时时间
    #
    #调用示例： DealSecurity("ie标题",15)
    #
    #返回值说明：
    #-  成功：返回安全警告窗口中的提示信息
    #- 失败：返回false
    def clearSecurityAlert(type = 'Y',timeout = @clearSecurityAlertTimeOut)
      #      $logger.log("调用函数：LibAutoit.rb文件中的clearSecurityAlert(#{type},#{timeout})" ,'N')
      #      $logger.log('----------deal with Security dialog begin----------')
      #处理安全对话框
      start_time = Time.now.to_i

      while 1
        if (Time.now.to_i-start_time < timeout)   #判断处理时间是否超时
          win_title = GetDialogTitle(4) #获取窗口标题
          if (win_title)
            alter_content =  ControlGetText(win_title,'','Static2')

            case type
            when 'Y'
              ControlClick(win_title,'','Button1')
            when 'N'
              ControlClick(win_title,'','Button2')
            end
            #puts "安全警告信息：\n#{alter_content}"

            #            $logger.log("the content of Security dialog： #{alter_content} ")
            #            $logger.log('-----------deal with Security dialog end-----------')
            #            $logger.log("调用函数结束：LibAutoit.rb文件中的clearSecurityAlert(#{type},#{timeout})" ,'N')
            return alter_content
          end
          sleep 1
        else
          #          $logger.log("The Security Alert Windows is not exist!")
          #          $logger.log('-----------deal with Security dialog end-----------')
          #          $logger.log("调用函数结束：LibAutoit.rb文件中的clearSecurityAlert(#{type},#{timeout})",'N' )

          return false
        end
      end
    end

    #功能说明：模拟键盘输入字符
    #
    #参数说明：
    #- string：输入的字符串信息，
    #- timeout：对话框处理的超时时间
    #
    #调用示例：
    #- Send("#r")  将发送 Win+r,这将打开“运行”对话框.
    #- Send("^!a")   发送按键 "CTRL+ALT+a".
    #- Send(" !a")    按下"ALT+a".
    #
    #返回值说明：无
    def SendKey(string = '{ENTER}')
      @autoit.Send(string)
    end

    #功能说明：给对话框中的某个控件设置值
    #
    #参数说明：
    #- win_title：对话框窗口的标题
    #- win_text:对话框窗口中显示的文本
    #- id：对话框窗口中某个控件的ID
    #- string：控件设置的值
    #
    #调用示例： 无
    #
    #返回值说明：无
    def ControlSetText(win_title,win_text,id,string = '',flag = 1)
      #修改指定控件的文本
      @autoit.WinActivate(win_title,win_text)

      if (ControlFocus(win_title,win_text,id) == 1)
        @autoit.ControlSetText(win_title,win_text,id,string)
      end
    end

    #功能说明：向指定控件发送鼠标点击命令
    #
    #参数说明：
    #- win_title：目标窗口标题.
    #- win_text：目标窗口文本.
    #- id：目标控件ID
    #- button_type：按键 [可选参数] 要点击的按钮, 可以是"left", "right", "middle", "main", "menu", "primary", "secondary". 默认为left(左键).
    #- click_time ：要点击鼠标按钮的次数. 默认值为 1.
    #
    #调用示例： 无
    #
    #返回值说明：无
    def ControlClick(win_title,win_text,id,button_type =1,click_time = 1)
      @autoit.AutoItSetOption("WinTitleMatchMode", 3)

      @autoit.WinActivate(win_title,win_text)

      case button_type
      when 1 #点击鼠标左键
        button_type = 'left'
      when 2  #点击鼠标右键
        button_type = 'right'
      when 3 #点击鼠标中间键
        button_type = 'middle'
      end

      @autoit.ControlClick(win_title,win_text,id,button_type,click_time)
    end

    #功能说明：获取指定控件值
    #
    #参数说明：
    #- win_title：目标窗口标题.
    #- win_text：目标窗口文本.
    #- id：目标控件ID
    #
    #调用示例： 无
    #
    #返回值说明：
    #- 返回获取的文本内容
    def ControlGetText(win_title,win_text,id)
      if (ControlGetHandle(win_title,win_text,id) != "")
        control_text =  @autoit.ControlGetText(win_title,win_text,id)

        return control_text
      end
    end

    #功能说明：获取指定控件值的句柄
    #
    #参数说明：
    #- win_title：目标窗口标题.
    #- win_text：目标窗口文本.
    #- id：目标控件ID
    #
    #调用示例： 无
    #
    #返回值说明：
    #- 返回获取的控件句柄
    def ControlGetHandle(win_title,win_text,id)
      ret = @autoit.ControlGetHandle(win_title,win_text,id)
      return ret
    end

    #功能说明：设置输入焦点到指定窗口的某个控件上
    #
    #参数说明：
    #- win_title：目标窗口标题.
    #- win_text：目标窗口文本.
    #- id：目标控件ID
    #
    #调用示例： 无
    #
    #返回值说明：无
    def ControlFocus(win_title,win_text,id)
      #设置输入焦点到指定窗口的某个控件上
      ret = @autoit.ControlFocus(win_title,win_text,id)
      return ret
    end


    #功能说明：判断窗口是否存在
    #
    #参数说明：
    #- win_title：目标窗口标题.
    #- win_text：目标窗口文本，默认为空
    #
    #调用示例： 无
    #
    #返回值说明：返回窗口对象
    def WinExists(win_title,win_text = '')
      #检查指定的窗口是否存在
      ret = @autoit.WinExists(win_title,win_text = '')
      return ret
    end

    private
    def initialize
      require 'win32ole'
      require 'watir/windowhelper'
      WindowHelper.check_autoit_installed
      @autoit = WIN32OLE.new("AutoItX3.Control")

      @DealDownloadDialogTimeOut  = 60
      @DealPathDialogTimeOut        = 60
      @ChooseFileDialogTimeOut      = 60
      @DealAlterDialogTimeOut        = 60
      @DealConfirmDialogTimeOut    = 60       #60秒的等待时间
      @DealPromptDialogTimeOut     = 60
      @DealSecurityTimeOut           = 60
      @clearSecurityAlertTimeOut    = 60
      @getDialogContent           =60
    end #def initialize end   
  end

#
#  def self.RenameFile(from,to =  nil)
#    begin
#      if (FileTest::exist?(from)) and (File.basename(from) =~ /.*\..*/ )
#        if (to == nil)
#          extname = File.extname(from)
#          filename = File.basename(from,extname)
#          new_filename = filename + '.' + Time.now.strftime("%Y%m%d%H%M%S") + extname
#          to = File.dirname(from) + '/'+ new_filename
#        end
#
#        File.rename(from, to)
#        return true
#      else
#        puts "重命名文件失败，原因：文件不存在，路径为#{from}"
#        return false
#      end
#    rescue StandardError => bang
#      puts "Error running script: " + bang
#      return false
#    end
#  end

  #功能说明：
  #- 获取文件的真实路径
  #
  #参数说明：
  #- file_path：原文件路径，如果原文件路径不存在，系统自动创建相应路径
  #- return_file：是否返回路径中的文件名，默认未返回
  #
  #调用示例：
  #- LibAutoit::GetRealPath("#{File.dirname(__FILE__)}/http://www.cnblogs.com/input/data.xls"  )
  #
  #返回值说明：
  #- 成功：返回真实的路径
  #- 失败：返回false
  def self.GetRealPath(file_path,return_file = 'Y')
    begin
      @@file_name = ''
      @@real_dir_row = []

      if (file_path.include?("\\"))
        file_path = file_path.to_s.gsub('\\','/')
      end

      if (file_path.include?("/"))

        file_basename = File.basename(file_path)  #获取文件名
        file_dirname = File.dirname(file_path)

        if (file_basename =~ /.*\..*/)
          file_dirname = File.dirname(file_path)
        else
          file_basename = ''
          file_dirname = file_path
        end

        if (!FileTest::exist?(file_dirname))  #判断目录是否存在，不存在则创建相应目录
          FileUtils.makedirs(file_dirname)
        end

        if (file_dirname[0,2] == './')
          real_dir = Pathname.new(File.dirname(File.dirname(file_dirname[0,2]))).realpath
          real_path = File.join(real_dir,file_dirname[2,file_dirname.length] )
        else
          real_path = file_dirname
        end

        if (real_path.include?(".."))
          temp_row = real_path.split('/')

          temp_row.each do |dir|
            if(dir == "..")
              @@real_dir_row.pop
            else
              @@real_dir_row.push(dir)
            end
          end

          real_path = @@real_dir_row.join('/')
        end

        if (return_file.upcase == 'Y')
          result = File.join(real_path,file_basename)
        else
          result = real_path
        end

        result = result.to_s.gsub('/','\\')
        return  result
      else
        puts "获取文件路径失败，原因：#{real_path}路径格式不正确。"
        return false
      end
    rescue StandardError => bang
      puts "Error running script: " + bang
      return false
    end
  end #def GetRealPath


end
