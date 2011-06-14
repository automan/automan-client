# 处理各种弹出框、及模拟键盘输入
module Popwin
  require 'automan/autility/LibAutoit'

  #上传文件
  #@param [String] string 输入需要上传的文件路径
  #@example file_upload(:file_path => "C:\\Documents and Settings\\ss2.jpg")
  def file_upload(options={})
    LibAutoit::AutoItApi.instance.ChooseFileDialog(options[:file_path])
  end
  #js弹出框处理，暂不支持radio点击弹出框
  #@param [String] 需要点击的button名称
  #@example  deal_dialog("确定")
  def deal_dialog(name=nil)
    LibAutoit::AutoItApi.instance.DealConfirmDialog(name)
  end

  #功能描述：处理Prompt对话框
  #@param [String] string 输入的文本内容 type 点击确定或取消按钮，type:确定 or 取消
  #@return [Boolean] true 成功 false 失败
  #@example  deal_prompt_dialog('test',"确定")
  def deal_prompt_dialog(string,type)
    LibAutoit::AutoItApi.instance.DealPromptDialog(string,type)
  end


  #处理文件下载对话框，调用DealPathDialog函数设置路径及下载文件
  #@param [String] file_path：文件下载后存放的路径，格式如：c:\\test file_name  文件名，如：test.txt
  #@return [Boolean]  true 成功 false 失败
  #@example  save_file(“c:\\test”,"test.txt")
  def save_file(file_path,file_name)
    LibAutoit::AutoItApi.instance.DealDownloadDialog(file_path,file_name)
  end

  #获取弹出框的内容，如果60秒后还是没有见到弹出框，就返回nil
  #@return [String] 获取弹出框的内容
  #@example 调用示例：text = get_content
  def get_content
    return LibAutoit::AutoItApi.instance.DealConfirmContent()
  end

  #功能说明：模拟键盘输入字符
  #返回值说明：无
  #@param [String] 输入的字符串信息，
  #@example Send("#r")，将发送 Win+r,这将打开“运行”对话框.
  #@example Send("^!a")，发送按键 "CTRL + ALT + a".
  #@example Send(" !a")，按下"ALT + a".
  def SendKey(string = '{ENTER}')
    LibAutoit::AutoItApi.instance.SendKey(string)
  end  
end