module Share
  class SharePageWrapper    
    def self.login(ie, name, password)
      lpage = ie.cast(Mms::LoginPage)
      lpage.standard_login.click
      lpage.username.set(name)
      lpage.password.set(password)
      lpage.login_button.click
    end
  end

end
