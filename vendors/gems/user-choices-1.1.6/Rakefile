#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-07-03.
#  Copyright (c) 2007. All rights reserved.

require 'hoe'
$:.unshift(File.join(Dir.pwd, "lib"))
require 'user-choices/version'

PROJECT='user-choices'
THIS_RELEASE=UserChoices::Version


Hoe.new(PROJECT, THIS_RELEASE) do |p|
  p.rubyforge_name = PROJECT
  p.changes = "See History.txt"
  p.author = "Brian Marick"
  p.description = "Unified interface to command-line, environment, and configuration files."
  p.summary = p.description
  p.email = "marick@exampler.com"
  p.extra_deps = [['xml-simple', '>= 1.0.11'], 
                  ['s4t-utils', '>= 1.0.3'],
                  ['builder', '>= 2.1.2']]        # for testing
  p.test_globs = "test/**/*tests.rb"
  p.rdoc_pattern = %r{README.txt|History.txt|lib/user-choices.rb|lib/user-choices/.+\.rb}
  p.url = "http://user-choices.rubyforge.org"
  p.remote_rdoc_dir = 'rdoc'
end

require 's4t-utils/rake-task-helpers'
desc "Run fast tests."
task 'fast' do
  S4tUtils.run_particular_tests('test', 'fast')
end

desc "Run slow tests."
task 'slow' do
  S4tUtils.run_particular_tests('test', 'slow')
end

require 's4t-utils/hoelike'
HoeLike.new(:project => PROJECT, :this_release => THIS_RELEASE,
            :login => "marick@rubyforge.org",
            :web_site_root => 'examples/tutorial', 
            :export_root => "#{S4tUtils.find_home}/tmp/exports")
