# 存放一些共用的方法
require 'timeout'

module AWatir

  class IEUtil
    

    # 删除IE临时文件
    # 参数描述：cookie存在的目录，默认为C盘路径下
    #@param [String] 临时文件存放位置，默认为dir= ENV['USERPROFILE']+"\\Local Settings\\Temporary Internet Files"
    #@example  IEUtil.kill_all_cookie 或者 IEUtil.kill_all_cookie(url)
    def self.kill_all_cookie (dir= ENV['USERPROFILE']+"\\Local Settings\\Temporary Internet Files")
      require 'fileutils'
      FileUtils.rm_rf dir
    end

    # 删除IE的cookie和cache
    # 参数描述：cookie存在的目录，默认为C盘路径下
    #@example  IEUtil.clear_ie_cookie_and_cache
    def self.clear_ie_cookie_and_cache
      require 'watir/cookiemanager'
      Watir::CookieManager::WatirHelper.deleteSpecialFolderContents(Watir::CookieManager::WatirHelper::COOKIES)
      Watir::CookieManager::WatirHelper.deleteSpecialFolderContents(Watir::CookieManager::WatirHelper::INTERNET_CACHE)
    end

    # 关闭用户通过程序打开的所有IE，当有弹出框时会在10秒后提示关闭失败
    #@example  IEUtil.close_ies
    def self.close_ies
      #[Bug]{TODO}要先把所有popwin都关掉
      begin
        Timeout.timeout(20) do
          IEModel.get_ies.each do |ie|
            ie.close
          end
        end
      rescue Timeout::Error => e
        puts "无法关闭，10秒超时"
      end
      return nil
    end

    # 关闭当前所有的IE
    #@example  IEUtil.close_all_ies

    def self.close_all_ies
      begin
        Timeout.timeout(10) do
          IEModel.get_all_ies.each do |ie|
            ie.close
          end
        end
      rescue Timeout::Error => e
        kill_all_ie      
      end
      return nil
    end

    # 关闭当前所有的IE,请用新的名字：close_all_ies
    #@example  IEUtil.close_all_ies
    def self.close_all_ie
      puts "[警告]请用新的名字：close_all_ies"
      self.close_all_ies
    end

    private
    def self.kill_all_ie
      begin
        mgmt = WIN32OLE.connect('winmgmts:\\\\.')
        getout = false
        while 1
          processes = mgmt.instancesof("win32_process")
          processes.each do |process|
            # puts process
            if  process.name.downcase =="iexplore.exe" then
              process.terminate()
              sleep 1 #预防ie关闭不及时，引起的错误
              getout = false
              break
            end
            getout = true
          end
          return if getout
        end
      rescue ex
        puts ex
      end
    end
  end

  class ExcelUtil
    #列出excel中process表里所有内容
    def self.show_process(path, parser_sym = :ruby)
      case(parser_sym)
      when :ruby
        rows = Automan::WorkbookParser::WorkbookNativeParser.new(path).sheet_rows("process")
      when :ole
        rows = Automan::WorkbookParser::WorkbookOleParser.new(path).sheet_rows("process")
      else
				raise "Automan.config.excel_parser = #{parser_sym}, not valid"
      end
      
      result = []
      rows.each{|r|
        c = []
        r.cells.each{|e|
          c<<e.value
        }
        result << c*"|"
      }
      puts result*"\r\n"
      return nil
    end
  end

  require 'Win32API'

  class Cursor
    MOUSEEVENTF_ABSOLUTE=32768
    MOUSEEVENTF_MOVE=1
    M0USEEVENTF_LEFTDOWN=2
    MOUSEEVENTF_LEFTUP=4
    def initialize
      @getCursorPos=Win32API.new("user32","GetCursorPos",['P'],'V')
      @setCursorPos=Win32API.new("user32","SetCursorPos",['i']*2,'V')
      @mouse_event=Win32API.new("user32","mouse_event",['L']*5,'V')
    end
    def pos
      lpPoint ="\0"*8
      @getCursorPos.Call(lpPoint)
      x, y   =   lpPoint.unpack("LL")
      Point.new(x, y)
    end
    def pos=(p)
      @setCursorPos.Call(p.x, p.y)
    end
    def leftdown
      @mouse_event.Call(M0USEEVENTF_LEFTDOWN,0,0,0,0)
    end
    def leftup
      @mouse_event.Call(MOUSEEVENTF_LEFTUP,0,0,0,0)
    end
    def click
      leftdown
      leftup
    end
  end

end

