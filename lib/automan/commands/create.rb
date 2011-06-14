module Automan::Command
  # ÃüÁîĞĞ automan create ¹¦ÄÜ
  class Create < Base
    require "fileutils"

    def index
      files = []
      dest = Dir.getwd
      project_name = @args.first
      error " please give me the project name, i.e: automan create YOUR_PROJECT_NAME " if project_name.nil?

      if File.directory? dest
        src = File.dirname(__FILE__)+"/../../../template/*"
        src = File.expand_path src
        src = Dir.glob src
        FileUtils.cp_r src, dest

        config = dest + "/config/automan_config.rb"
        replace_file_content(config, "{ProjectId}", project_name)

      else
        error "Cannot found dir #{File.expand_path dest}"
      end

    end

    def usage
      <<-EOTXT
=== Command List:
  automan create project_name


      EOTXT
    end

    private
      def replace_file_content(path, source, replacement)
        file = File.open(path, "r")
        result = file.readlines.to_s
        file.close

        result = result.gsub(source, replacement)

        file = File.open(path, "w")
        file.write(result)
        file.close
      end
  end
end