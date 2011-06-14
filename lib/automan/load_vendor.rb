#加载所有vendor包
automan_root = File.expand_path File.dirname(__FILE__) + '/../../'       
Dir[File.join(automan_root, "/vendors/gems/*/lib")].select{|e|File.directory? e}.each do |dir|
	$:.unshift dir
end