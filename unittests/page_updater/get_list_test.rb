require File.dirname(__FILE__) + "/setup.rb"

include Automan::Version
class GetListTest < Test::Unit::TestCase
  def test_get_list
    #server
    vs = VersionRoot.new("2010050519240009", "project123", "project123") #update
    vs.add_nodes FileNode.new("2010050519240001", "filename123.xml", "/filename1.xml") #add

    folder1 = FolderNode.new("2010050519240006", "folder3") #add
    folder1.add_nodes FileNode.new("2010050519240008", "filename3.xml", "folder1/filename2.xml") #add
    folder2 = FolderNode.new("2010050519240003", "folder2") #update
    folder2.add_nodes FileNode.new("2010050519240001", "filename2.xml", "folder1/filename2.xml") #update

    folder_same = FolderNode.new("2010050519240003", "folderS") #same
    folder_same.add_nodes FileNode.new("2010050519240001", "filenameS.xml", "folder1/filenameS.xml") #update

    vs.add_nodes folder1
    vs.add_nodes folder2
    vs.add_nodes folder_same
    vs.add_nodes FolderNode.new("2010050519240006", "folder_new") #add

    #local
    vr = VersionRoot.new("2010050519240002", "project123", "project123")
    vr.add_nodes FileNode.new("2010050519240002", "filename1.xml", "/filename1.xml") #delete

    folder1 = FolderNode.new("2010050519240003", "folder1") #delete
    folder1.add_nodes FileNode.new("2010050519240004", "filename1.xml", "folder1/filename2.xml") #delete
    folder2 = FolderNode.new("2010050519240004", "folder2")
    folder2.add_nodes FileNode.new("2010050519240003", "filename2.xml", "folder1/filename2.xml")

    folder_same = FolderNode.new("2010050519240003", "folderS") #same
    folder_same.add_nodes FileNode.new("2010050519240001", "filenameS.xml", "folder1/filenameS.xml") #update

    vr.add_nodes folder1
    vr.add_nodes folder2
    vr.add_nodes folder_same

    File.open(File.dirname(__FILE__) + "/store_root_version","w") do |file|
      Marshal.dump(vr,file)
    end

    vr_local =nil
    File.open(File.dirname(__FILE__) + "/store_root_version") do |file|
      vr_local = Marshal.load(file)
    end  

    parent_folder = File.dirname(__FILE__)

    assert(!vr_local.ver_eql(vs))

    list = vs.get_list(vr_local, parent_folder)

    assert_equal(list.length,7)

    list_none = vr.get_list(vr_local, parent_folder)
    assert(list_none.empty?)

  end
end

