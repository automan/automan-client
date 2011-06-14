=begin
      创 建 者:
      脚本功能: 1.
               2.
               3.
      创建日期：2010-09-03
      对应场景：
=end
require 'automan/baseline' #加载automan，自动查找boot文件加载配置，默认的page加载位置是c:\automan\base\page

class TestExample < Automan::DataDrivenTestcase

  # process前执行，一个class只运行一次
#  def class_initialize
#    IEUtil.close_all_ies
#    #进行login等只会执行一次的操作
#  end

  # process后执行，一个class只运行一次
#  def class_cleanup
#    IEUtil.close_ies
#  end

	def process(*m)
    ie = IEModel.start("http://login.daily.taobao.net/member/login.jhtml?")
    bpage = ie.cast(Mms::LoginPage)
    bpage.chk_safelogin.clear
    bpage.txt_username.set "automan_sample"
    ie.close
	end

end