Automan::Initializer.run do |config|
  config.project_tam_id     = "Base"
  config.tam_host           = "automan.heroku.com"
  #强制更新page xml
  config.page_force_update  = true
  #要不要在启动ie的时候自动最大化
  config.ie_max             = true
  config.mock_db            = nil #设为nil就会真正去执行sql语句，设为 STDOUT 可以只打印不执行sql
  config.page_path          = "page"
  #程序出错，assert不对截图
  config.capture_error      = true
  #verify不对截图
  config.capture_warning    = true
  config.capture_path       = "capture"
end
