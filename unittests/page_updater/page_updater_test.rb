require File.dirname(__FILE__) + "/setup.rb"

include Automan::Version
class GenTest < Test::Unit::TestCase

  def test_page_updater        
    local = File.join( File.dirname(__FILE__), "test_old.info")
    local_version = nil
    File.open(local) do |file|
      local_version = YAML.load(file)
    end

    server = File.join( File.dirname(__FILE__), "test_new.info")
    server_version = nil
    File.open(server) do |file|
      server_version = YAML.load(file)
    end

    process_folder = File.dirname(__FILE__)
    list = server_version.get_list(local_version, process_folder)
    assert_equal(54, list.length)
    assert_equal([:UpdateFile], list[0].keys)
    assert_equal(1, list[0].values.length)
    assert_equal("CWangPuDetail.xml", list[0].values[0].name)
    assert_equal("http://automan.taobao.net/api/pm_models/721.xml", list[0].values[0].url)
    assert_equal("2010-12-01 09:47:03", list[0].values[0].version)
  end
end