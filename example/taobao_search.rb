require "automan/baseline"
class TestTODO < Automan::DataDrivenTestcase
  def process(checkresult, search_content)
    IEUtil.close_all_ies  #关闭当前桌面打开的所有IE
    ie = IEModel.start("http://s.taobao.com/")                                  #开启一个url
    page = ie.cast(Taobao::Searchtaobao)                                        #将IE视图转换为htmlmodel视图
    ptext = page.search_tabs[2].lnk_tab_item.text                               #取页面上的某个文字
    CheckText.assert_equal(ptext,checkresult)                                   # 校验所取的文字是否是预期值
    page.search_tabs["店铺"].lnk_tab_item.click                                 #点击“店铺”tab
    page.txt_search.set search_content                                          #搜索输入框输入需要搜索的内容
    page.btn_search.click                                                       #点击“搜索”按钮
    ie.close
  end
end
