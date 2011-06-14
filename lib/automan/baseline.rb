
file = $0
if(File.exist?(file))
  current = File.expand_path(file)
  puts "引用baseline的文件为：#{current}"
  boot_file = ""
  while (parent = File.dirname(current)) != current #根目录时，File.dirname(current)==current
    if File.exist?(parent+"/config/boot.rb") #查找放在config下的boot.rb文件
      boot_file = File.expand_path(parent+"/config/boot.rb")
      break
    end
    current = parent
  end

  #项目里，如果有boot_file，就load boot_file为方便automan console的reload，直接改load
  if(File.exist?(boot_file))
    load boot_file
  end
elsif(file == "irb")
  #说明是console里启动的，啥也不做
else
  puts "引用baseline的文件为：#{file}，不做引用"
end


#项目里，如果boot_file没有定义AUTOMAN_ROOT，会使用默认值
#如果定义过AUTOMAN_ROOT，不会执行下面的设置
if (!defined? AUTOMAN_ROOT) || (defined? @step_in_again)
  #@step_in_again为了确保只要进来一次，就次次都进来。
  require 'automan'

  unless defined? AUTOMAN_ROOT
    AUTOMAN_ROOT = "c:/automan/"
    require 'fileutils'
    FileUtils.mkdir_p AUTOMAN_ROOT
  end
  @step_in_again = true  unless defined? @step_in_again

  Automan::Initializer.run do |config|
    config.project_tam_id     = (defined?AUTOMAN_CONSOLE_PROJECT_ID).nil? ? "base": AUTOMAN_CONSOLE_PROJECT_ID
    config.tam_host           = "automan.taobao.net"
    #强制更新page xml
    config.page_force_update  = true
    #要不要在启动ie的时候自动最大化
    config.ie_max             = true
    config.mock_db            = nil #设为nil就会真正去执行sql语句，设为 STDOUT 可以只打印不执行sql

    #程序出错，assert不对截图
    config.capture_error      = true
    #verify不对截图
    config.capture_warning    = true
    config.log_level          = :info
  end
end

include Share if defined? Share


