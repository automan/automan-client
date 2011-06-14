require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'fileutils'
include FileUtils

version="0.8"
name="automan"

spec = Gem::Specification.new do |s|
  s.name = name
  s.version = version
  s.description = s.summary = "The tcommon GemPlugin"
  s.author = "AutoMan"
  s.add_dependency('gem_plugin', '>= 0.2.3')
  
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  
  s.files = %w(COPYING LICENSE README Rakefile) +
    Dir.glob("{bin,doc/rdoc,lib,template}/**/*") +
    Dir.glob("ext/**/*.{h,c,rb}") +
    Dir.glob("vendors/gems/*/lib/**/*")+
    Dir.glob("vendors/plugins/**/*")
  s.require_path = "lib"
  s.bindir = "bin" 
  s.executables = [ "automan" ]
end

Rake::GemPackageTask.new(spec) do |p|
  p.need_tar = true if RUBY_PLATFORM !~ /mswin/
end 

task :deploy do
  unless File.exist? "pkg/#{name}-#{version}.gem" 
    puts "please rake package first"
    exit 1
  end
  sh %[scp pkg/#{name}-#{version}.gem  root@twork.taobao.net:/home/rails/automan/gems/gems]
  sh %[ssh root@twork.taobao.net 'gem generate_index -d /home/rails/automan/gems/']
end

task :install => [:package] do
  sh %{gem install pkg/#{name}-#{version}.gem --no-rdoc --no-ri}
end

task :uninstall => [:clean] do
  sh %{gem uninstall #{name}}
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.add ['README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc']
end

task :default => [:test, :package]

CLEAN.include ['build/*', '**/*.o', '**/*.so', '**/*.a', 'lib/*-*', '**/*.log', 'pkg', 'lib/*.bundle', '*.gem', '.config']

