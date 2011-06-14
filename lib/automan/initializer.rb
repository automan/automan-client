module Automan
  class << self
    #Automan配置信息
    def config
      if @config.nil?
      	Initializer.run
    	end
    	@config
    end

    def config=(config)
      @config = config
    end     
  end  
end

module Automan
  class Initializer
    attr_reader :configuration
    
    def initialize(configuration)
      AWatir::TestRunLogger.load_logger if(ARGV.include?("-jobId"))
      @configuration = configuration
    end
    
    def self.run(configuration = Configuration.new)
      yield configuration if block_given?
      initializer = new configuration
      initializer.process
      initializer
    end
    
    def process
      Automan.config = configuration
      if configuration.project_mode?
      	if configuration.page_force_update
      		update_page_xml
          #update_share_file
    		end
      	require_pages
        #require_share
    	end
  	end

    def update_share_file
  		tam_host = Automan.config.tam_host
  		assert tam_host

      share_path = Automan.config.share_path
      return if share_path.nil?
      
      begin
        name = "ashare"
        server_url = "http://#{tam_host}/api/svn_revision.xml?svn_path=AShare/#{name}.rb"
        server_io = open(server_url)
        server_hash = Hash.from_xml(server_io)
        info_file = share_path + "/#{name}.info"

        if File.exist?(info_file)
          local_hash = nil
          File.open(info_file) { |file| local_hash = YAML.load(file) }
          if(local_hash["result"]["revision"] == server_hash["result"]["revision"])
            return nil
          end
        end

        FileUtils.mkdir_p share_path
        share_file = share_path + "/#{name}.rb"
      
        Automan::Version::VersionHelper.write_share(share_file, server_hash["result"]["file_url"])
        File.open(info_file, 'w') { |file| YAML.dump(server_hash, file) }

      rescue Exception => ex
        puts "Share方法更新失败，打印失败日志如下，并尝试继续执行脚本："
        puts "Error: #{ex} (#{ex.class}).At:"
        puts ex.backtrace
      end
    end

    def require_share
  		share_path = Automan.config.share_path
  		return if share_path.nil?
      Automan.require_folder(share_path)
    end

    #加载页面模型
  	def require_pages 
  		page_path = Automan.config.page_path
  		return if Automan.config.page_path.nil?
  		
  	  raise "page path: #{page_path} not exist!, Please check config/automan_config.rb" unless File.exists?(page_path)
  		Automan.require_folder(page_path)
  	end

  	#更新页面模型
  	def update_page_xml  		  		
  		tam_host = Automan.config.tam_host
  		assert tam_host
  		project_id = Automan.config.project_tam_id
  		assert project_id  		
		  parent_folder = Automan.config.page_path
      unless(File.exist?(parent_folder))
        require "fileutils"
        FileUtils.mkdir_p parent_folder
      end
		  Automan::Version::VersionHelper.process("http://#{tam_host}/api/pm_libs/#{project_id}.xml", parent_folder)
  	end
	end
	
	
	class Configuration
		
		attr_accessor :excel_parser
		
		# The test project's base directory.
		attr_accessor :tam_host, :project_tam_id
		
		# automan files comes here
		attr_accessor :root_path
		
		# The page model folder name
		attr_accessor :page_path
		
		# do we need to update pages from tam
		attr_accessor :page_force_update

    attr_accessor :ie_max

    attr_accessor :capture_warning, :capture_error

		attr_accessor :log_level
		
		attr_accessor :capture_path
		attr_accessor :mock_db
		    
    def default_excel_parser
    	:ruby
    end

    def default_log_level
      :info
    end
    
    def default_page_path
    	"page"
    end
    
    def default_page_force_update
    	true
    end
		
    def default_capture_path
    	"capture"
    end
    
    def page_path
      default_path = "c:\\automan\\"
      unless(File.exist?(default_path))
        Dir.mkdir(default_path)
      end
  		assert @project_tam_id
    	File.expand_path File.join(default_path, @project_tam_id, "page")
    end

    def share_path
      default_path = "c:\\automan\\"
      unless(File.exist?(default_path))
        Dir.mkdir(default_path)
      end
  		assert @project_tam_id
    	File.expand_path File.join(default_path, @project_tam_id, "share")
    end

    def tam_host= (value)
      @tam_host = value
    end

		def initialize
			set_root_path!
      self.log_level                    = default_log_level      
      self.excel_parser                    = default_excel_parser
      self.tam_host                     = "automan.taobao.net"
      self.project_tam_id               = "无"
      self.mock_db                      = false
      self.ie_max                       = false
      self.capture_error                = false
      self.capture_warning              = false
      
      self.page_force_update            = default_page_force_update 
      self.capture_path                 = default_capture_path       
		end
		
		def project_mode?
			defined?(AUTOMAN_ROOT)
		end
		
		
	 	private
	 	def set_root_path!	 
	 		if project_mode?
	 			raise 'AUTOMAN_ROOT is not a directory' unless File.directory?(::AUTOMAN_ROOT)
	 			@root_path = File.expand_path(::AUTOMAN_ROOT)      
      	::AUTOMAN_ROOT.replace @root_path
    	else
  			@root_path = File.expand_path "."
  		end
	 	end
	 	
	end
	
end

unless defined? AUTOMAN_ROOT
	Automan::Initializer.run
end