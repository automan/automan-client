module WangWangClient
	module WWLoginWindow
 
      include AWatir
	  
		  
		  #旺旺登录窗口
		  class WWLoginWin < WinRootModel
			
			 #记住密码
			 def remember_password
		      return  find_element(AWatir::WinElement,".StandardButton:eq(4)", :name=>"remember_password", :description=>"记住密码")
			 end
			
			 #自动登录
			 def auto_login
		      return  find_element(AWatir::WinElement,".StandardButton:eq(5)", :name=>"auto_login", :description=>"自动登录")
			 end
			
			 #登录按钮
			 def login
		      return  find_element(AWatir::WinElement,"*:contains(登 录)", :name=>"login", :description=>"登录按钮")
			 end
			
			 #帐号类型
			 def account_type
		      return  find_element(AWatir::WinElement,".StandardButton:eq(1)", :name=>"account_type", :description=>"帐号类型")
			 end
			
			 #会员名
			 def txt_ww_username
		      return  find_element(AWatir::WinTextField,".EditComponent:eq(1)", :name=>"txt_ww_username", :description=>"会员名")
			 end
			
			 #密码
			 def txt_password
		      return  find_element(AWatir::WinWWPassword,".ATL\\:Edit", :name=>"txt_password", :description=>"密码")
			 end
			

          include AWatir
           
		  end
	  
	end
end
