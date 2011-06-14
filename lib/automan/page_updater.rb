$:.unshift(File.dirname(__FILE__))
module Automan
  # 提供PageModel在线更新功能
  module Version

    require 'open-uri'
    require 'yaml'
    require 'fileutils'
    require 'automan/codegen/pagemodel_generator'

    require 'htmlentities'

    # 页面信息，基本节点    
    class VersionNode
      # @return [String] 版本号
      attr_accessor :version
      # @return [String] 名称
      attr_accessor :name
      # @return [VersionNode] 父节点
      attr_accessor :parent
      def to_s
        return "#{name} #{version}: #{path}"
      end
      # @param [String] version_number 版本号
      # @param [String] name 名称
      def initialize(version_number, name)
        @version = version_number
        @name = name
      end
      def ver_eql(node)
        return false unless(node)
        return node.version.eql?(self.version)
      end
      # 拼装全路径
      # @return [String]
      def path
        return File.join(@parent.path, @name)
      end
      # 给出需要更新的文件及文件夹列表
      # @param [VersionNode] local_node 本地节点
      # @abstract override by {FolderNode#need_update} and {FileNode#need_update}
      # @return [Array<Hash>]
      # @example 返回值为[
      #   {:AddFile=>[FileNode]}
      #   {:AddDir=>"c:/automan/base/page/testfolder"}
      #   ]
      def need_update(local_node)
        raise NotImplementedError.new("#{self.class.name}#area是抽象方法")
      end
    end
    # 页面信息，文件节点
    class FileNode < VersionNode
      # @param (see VersionNode#initialize)
      # @param [String] file_url 文件下载地址
      def initialize(version_number, name, file_url)
        super(version_number, name)
        @url = file_url
      end
      # @return [String] 文件下载地址
      attr_accessor :url
      # 给出需要更新的文件列表
      # @param (see VersionNode#need_update)
      # @return (see VersionNode#need_update)
      def need_update(local_node)
        result = []
        unless local_node
          result << {:AddFile => self}
        else
          unless(ver_eql(local_node))
            result << {:UpdateFile => self}
          end
        end
        return result
      end
    end
    # 页面信息，目录
    class FolderNode < VersionNode
      # @param (see VersionNode#initialize)
      def initialize(version_number, name)
        super
        @sub_nodes = []
      end
      # @return [Array<VersionNode>] 子节点
      attr_reader :sub_nodes
      # 添加子节点
      # @param [Array<VersionNode>] nodes 子节点
      def add_nodes(nodes)
        Array(nodes).each { |n|
          n.parent = self
          @sub_nodes << n
        }
      end
      # 从子节点中查找同名节点
      # @return [VersionNode, nil] 找到的节点
      def find_same_name(node)
        @sub_nodes.each{|n|
          if(n.name == node.name)
            return n
          end
        }
        return nil
      end

      # 给出需要更新的文件夹列表
      # @param (see VersionNode#need_update)
      # @return (see VersionNode#need_update)
      def need_update(local_node)
        result = []
        unless(local_node)#本地不存在
          result << {:AddDir=>File.join(self.path)}          

          @sub_nodes.each { |n|
            result.concat(n.need_update(nil))
          }
        else
          unless(ver_eql(local_node))
            #开始找下面哪里不一样
            local_sub = local_node.sub_nodes

            @sub_nodes.each { |n|
              ln = local_node.find_same_name(n) #查找到本地的节点
              if(ln)
                #找到了本地的节点
                unless(ln.ver_eql(n))
                  result.concat(n.need_update(ln))
                end
              else
                #找不到本地的节点
                result.concat(n.need_update(nil))
              end
            }
          
            local_sub.each{|ln|
              sn = self.find_same_name(ln) #查找服务器的节点
              #找不到服务器上的节点
              unless(sn)
                if(ln.is_a? FolderNode)
                  result << {:DelDir=>File.join(self.path, ln.name)}
                elsif(ln.is_a? FileNode)
                  result << {:DelFile=>File.join(self.path, ln.name)}
                else
                  raise "not supported"
                end
              end
            }
          end
        end
        return result
      end
    end
    # 页面信息，根目录
    class VersionRoot < FolderNode
      # @param [String] project_name 项目名称
      # @param (see VersionNode#initialize)
      def initialize(version_number, name, project_name=name)
        super(version_number, name)
        @project_name = project_name
      end
      # @return [String] 项目名称
      attr_accessor :project_name
      attr_reader :root_path
      def get_list(local_node, root_path)
        @root_path = root_path
        return need_update(local_node)
      end
      def path
        return @root_path
      end
    end

    class VersionHelper
      @MaxNumber = 50

      # 更新信息打印给用户看
      def self.show_hash(hash)
        value = hash.values[0]
        if(value.is_a?(FileNode))
          result = "#{value.path}=>#{value.url}"
        else 
          result = value
        end
        puts "#{hash.keys[0]}=>#{result}"
      end
      def self.process_file(file_list_hash_array)
        file_list_hash_array.each { |hash|
          show_hash(hash)
          if(hash[:AddDir])
            value = hash[:AddDir]
            unless(File.exist?(value))
              Dir.mkdir(value)
            end
          elsif(hash[:DelDir])
            value = hash[:DelDir]
            #删除不存在的文件夹时，不会报错
            FileUtils.rm_rf(value)
          elsif(hash[:DelFile])
            value = hash[:DelFile]
            File.delete(value) if File.exist?(value)
            ruby_file = value.sub(/\.xml$/,".rb")
            File.delete(ruby_file) if File.exist?(ruby_file)
          elsif(hash[:UpdateFile])
            file_node = hash[:UpdateFile]
            write_to_file(file_node)
          elsif(hash[:AddFile])
            file_node = hash[:AddFile]
            write_to_file(file_node)
          end
        }
      end
      # @param [String] url 页面模型信息xml文件url，如 url='http://t-taichan:3000/pm_libs/object_lib-one.xml'
      # @return [VersionRoot] 从服务器端拿到的页面模型版本信息文件
      def self.get_server_version(url)
        version_server = YAML.load(http_get(url))
        return version_server
      end

   
      def self.http_get(url)
        begin
          open(url,:proxy=>nil).read
        rescue StandardError => e
          raise "Error raised when reading url: #{url}, message is : \n\t#{e.message}"
        end
      end
      # 更新文件夹
      # @return [nil]
      # @example 使用示例
      #   parent_folder = File.dirname(__FILE__)+ "/page"
      #   VersionHelper.process('http://t-taichan:3000/pm_libs/object_lib-one.xml', parent_folder)
      def self.process(root_url, parent_folder)        
        server_version = get_server_version(root_url)
        name = server_version.name
        
        local = File.join(parent_folder , "#{name}.info")
        file_list = File.join(parent_folder , "#{name}.list")
        file_list_temp = File.join(parent_folder , "#{name}.list_temp")
        server_target = File.join(parent_folder , "#{name}.target")

        unless(File.exist?(file_list))
          #获取要更新的file list，写入文件，并保存服务器端文件
          process_folder = parent_folder
          local_version = nil
          if(File.exist?(local))
            File.open(local) do |file|
              local_version = YAML.load(file)
            end
          end
          list = server_version.get_list(local_version, process_folder)
          if(list.length < @MaxNumber)
            #如果数目小就简单处理，跟原来的逻辑一样，不用写list文件
            #大部分更新会走这里的逻辑。
            if(list.empty?)
              return nil
            end
            process_file(list)
            File.open(local, 'w') { |file| YAML.dump(server_version, file) }
            return nil
          end
          File.open(file_list, 'w') { |file| YAML.dump(list, file) }
          File.open(server_target, 'w') { |file| YAML.dump(server_version, file) }
        end
        #处理要更新的file list文件，处理完后把服务器端文件覆盖到本地文件
        list_load = []
        File.open(file_list){|file| list_load = YAML.load(file)}
        while(!list_load.empty?)
          current_list = list_load.slice!(0, @MaxNumber)
          process_file(current_list)
          File.open(file_list_temp, 'w') { |file| YAML.dump(list_load, file) }
          # Overwrite original file with temp file
          File.rename(file_list_temp, file_list)
        end
        FileUtils.rm(file_list, :force => true)
        FileUtils.copy_file(server_target, local)
        FileUtils.rm(server_target, :force => true)
        return nil
      end

      def self.write_share(path,url)
        File.open(path, 'w') { |file|
          open(url,:proxy=>nil){|io|
            result = io.readlines
            result.each do |line|
              line = HTMLEntities.new.decode(line)
              file << line
            end
          }
        }
      end

      private
      def self.write_to_file(file_node)
        dir = File.dirname(file_node.path)
        FileUtils.mkdir_p(dir) unless File.exist?(dir)
        File.open(file_node.path, 'w') { |file|
          url = file_node.url
          open(url,:proxy=>nil){|io|
            result = io.readlines
            result.each do |line|
              line = HTMLEntities.new.decode(line)
              file << line
            end
          }
        }
        xml_file = file_node.path
        ruby_file = xml_file.sub(/\.xml$/,".rb")
        output = Codegen::PageModelGenerator.new(xml_file).run
        File.open(ruby_file,"w"){|f|f<<output} #dup code
      end
    end
  end
end
