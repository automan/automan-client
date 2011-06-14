require File.dirname(__FILE__)+"/setup"
require 'childprocess'


class ButtonTest < Test::Unit::TestCase
  def test_read_output

        cmd = []
    cmd << "index=10"
    cmd << "while(index>0)"
    cmd << "index=index-1"
    cmd << "puts index"
    cmd << "STDOUT.flush"
    cmd << "sleep 0.1"
    cmd << "end"
    p = ChildProcess.build("ruby -e #{(cmd*";").inspect}")
    io = File.open("c:/automan/process-io.tmp","w+")
    p.io.stdout = io
    p.start

    pos = 0
    sleep 0.5
    io.pos = pos
    puts io.readlines
    pos = io.pos

    sleep 0.5
    io.pos = pos
    puts io.readlines
    pos = io.pos

    sleep 0.5
    io.pos = pos
    puts io.readlines
    pos = io.pos


    STDOUT.puts "running"
    p.poll_for_exit(10)
    STDOUT.puts "end"
    
  end
end



