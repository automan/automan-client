#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-10-03.
#  Copyright (c) 2007. All rights reserved.
require 's4t-utils/rake-task-helpers'
require 's4t-utils/os'

# These are at the top level so that they can be available in the context
# of a running task.
def assert_in(dir, taskname) # :nodoc:
  unless Dir.pwd == dir
    puts "Run task '#{taskname}' from directory '#{dir}'."
    exit 1
  end
end

def confirmed_step(name) # :nodoc:
  STDOUT.puts "** #{name} **"
  STDOUT.puts `rake #{name}`
  STDOUT.print 'OK? > '
  exit if STDIN.readline =~ /[nN]/
end



# HoeLike is intended to be used with the Hoe gem. It adds some 
# Rake tasks.
#
# * slow: Runs tests whose filenames are '*-slowtests.rb'
# * fast: Runs all tests, skipping slow tests.
# * upload_pages: copy website pages up to Rubyforge
# * export_and_upload_pages: upload_pages without any garbage or .svn
#   files lying around.
# * tag_release: Make a Subversion tag called rel-X.Y.Z. Release number
#   is gotten from lib/name/version.rb.
# * export: export entire project to pristine temp directory.
# * release_everything: Release code, rdoc, and website to rubyforge.
class HoeLike
  
  def initialize(keys)
    @keys = keys
    project = pull(:project)
    this_release = pull(:this_release)
    login = pull(:login)
    web_site_root = pull(:web_site_root)
    export_root = pull(:export_root)
    
    root = "svn+ssh://#{login}/var/svn/#{project}"
    project_exports = "#{export_root}/#{project}"
    
    desc "Run fast tests."
    task 'fast' do
      S4tUtils.run_particular_tests('test', 'fast')
    end
    
    desc "Run slow tests."
    task 'slow' do
      S4tUtils.run_particular_tests('test', 'slow')
    end
    
    desc "Upload all the web pages (as part of release)"
    task 'upload_pages' do | task |
      assert_in(project_exports, task.name)
      exec = "scp -r #{web_site_root}/* #{login}:/var/www/gforge-projects/#{project}/"
      puts exec
      system(exec)
    end
    
    desc "Upload all the web pages (not as part of release)"
    task 'export_and_upload_pages' => 'export' do | task |
      Dir.chdir(project_exports) do
        exec = "scp -r #{web_site_root}/* #{login}:/var/www/gforge-projects/#{project}/"
        puts exec
        system(exec)
      end
    end

    desc "Tag release with current version."
    task 'tag_release' do
      from = "#{root}/trunk"
      to = "#{root}/tags/rel-#{this_release}"
      message = "Release #{this_release}"
      exec = "svn copy -m '#{message}' #{from} #{to}"
      puts exec
      system(exec)
    end
    
    desc "Export to #{project_exports}"
    task 'export' do 
      Dir.chdir(export_root) do
        rm_rf project
        exec = "svn export #{root}/trunk #{project}"
        puts exec
        system exec
      end
    end
    

    desc "Complete release of everything - asks for confirmation after steps"
    # Because in Ruby 1.8.6, Rake doesn't notice subtask failures, so it
    # won't stop for us.
    task 'release_everything' do  
      confirmed_step 'check_manifest'
      confirmed_step 'export'
      Dir.chdir(project_exports) do
        puts "Working in #{Dir.pwd}"
        confirmed_step 'test'
        confirmed_step 'upload_pages'
        confirmed_step 'publish_docs'
        ENV['VERSION'] = this_release
        confirmed_step 'release'
      end
      confirmed_step 'tag_release'
    end

  end
  
  private
  
  def pull(key)
    @keys[key] || raise("Missing key #{key.inspect}")
  end
end
