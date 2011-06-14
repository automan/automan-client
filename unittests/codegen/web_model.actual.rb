module Taojianghu
	module Portal
		module Home
 
      include AWatir
	  
		  
		  #主页
		  class HomePage < HtmlRootModel
			
			 #留言区域
			 def comment
		      return  find_model(Comment,"#J_commentBox", :name=>"comment", :description=>"留言区域")
			 end
			
			 #关注等操作
			 def follow_act
		      return  find_model(FollowAct,"div.follow-act", :name=>"follow_act", :description=>"关注等操作")
			 end
			

          include AWatir
           

          #留言区域
          class Comment < HtmlModel
            
             #留言框
             def comment_box
                return  find_model(CommentBox,".reply-form", :name=>"comment_box", :description=>"留言框")
             end
            
             #留言列表
             def comment_lists
                return  find_models(CommentList,".reply-list", :name=>"comment_lists", :description=>"留言列表")
             end
            
             #提示弹出框
             def popup
                return  find_model(Popup,"div.sns-panel-content>div.bd", :name=>"popup", :description=>"提示弹出框")
             end
            
          end
                  

          #留言框
          class CommentBox < HtmlModel
            
             #输入框
             def txt_input
                return  find_element(AWatir::ATextField,".J_Suggest", :name=>"txt_input", :description=>"输入框")
             end
            
             #表情
             def lnk_face
                return  find_element(AWatir::ALink,"#J_viewMoreSmile", :name=>"lnk_face", :description=>"表情")
             end
            
             #写好了
             def btn_submit
                return  find_element(AWatir::AButton,"a.post", :name=>"btn_submit", :description=>"写好了")
             end
            
          end
                  

          #留言列表
          class CommentList < HtmlModel
            
             #回复链接
             def lnk_reply
                return  find_element(AWatir::ALink,".sns-icon\\ icon-comment", :name=>"lnk_reply", :description=>"回复链接")
             end
            
             #删除链接
             def lnk_delete
                return  find_element(AWatir::ALink,".sns-icon\\ icon-del", :name=>"lnk_delete", :description=>"删除链接")
             end
            
          end
                  

          #提示弹出框
          class Popup < HtmlModel
            
          end
                  

          #关注等操作
          class FollowAct < HtmlModel
            
             #关注按钮
             def lnk_follow
                return  find_element(AWatir::ALink,"a.add-link", :name=>"lnk_follow", :description=>"关注按钮")
             end
            
             #动一下
             def lnk_poke
                return  find_element(AWatir::ALink,"#J_touch", :name=>"lnk_poke", :description=>"动一下")
             end
            
             #推荐给好友
             def lnk_recfriend
                return  find_element(AWatir::ALink,"#J_recommend", :name=>"lnk_recfriend", :description=>"推荐给好友")
             end
            
             #送礼物
             def lnk_gift
                return  find_element(AWatir::ALink,"a.sns-icon\\ icon-gift-send", :name=>"lnk_gift", :description=>"送礼物")
             end
            
          end
                  
		  end
	  
		end
	end
end
