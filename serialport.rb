#!/usr/bin/env ruby
require 'serialport'

class MySerialPort < SerialPort
  def parity_str
    (p = parity) == SerialPort::EVEN ? "EVEN" : 
      p == SerialPort::ODD ? "ODD" :
      p == SerialPort::NONE ? "NONE" : "UNKNOWN"
  end
  def parity_str= (p)
    case p 
    when "EVEN"
      parity = SerialPort::EVEN
    when "ODD"
      parity = SerialPort::ODD
    when "NONE"
      parity = SerialPort::NONE
    else
      raise ArgumentError
    end
  end
  def flow_control_str
    (f = flow_control) == SerialPort::HARD ? "HARD" :
      f == SerialPort::SOFT ? "SOFT" :
      f == SerialPort::NONE ? "NONE" :
      f == SerialPort::HARD|SerialPort::SOFT ? "HARD|SOFT" : "UNKNOWN"
  end
  def flow_control_str= (v)
    case v
    when "HARD"
      flow_control = SerialPort::HARD
    when "SOFT"
      flow_control = SerialPort::SOFT
    when "NONE"
      flow_control = SerialPort::NONE
    when "HARD|SOFT", "SOFT|HARD"
      flow_control = SerialPort::HARD|SerialPort::SOFT
    else 
      raise ArgumentError
    end
  end
  def to_s
  sprintf(
    "rts: %d\n" + 
    "cts: %d\n" + 
    "dtr: %d\n" +
    "dsr: %d\n" +
    "data bits: %d\n" +
    "baud rate: %d\n" +
    "flow control: %s\n" +
    "parity: %s\n",
    rts,
    cts,
    dtr,
    dsr,
    data_bits,
    baud,
    flow_control_str,
    parity_str);
  end
end

class Command
  @name
  @usage
  @procedure
  @raw_args = nil

  attr_reader :name
  attr_reader :usage
  attr_reader :procedure
  attr_reader :raw_args

  def initialize(name=nil, usage=nil, procedure=nil, raw_args=nil)
    @name = name
    @usage = usage
    @procedure = procedure
    @raw_args = raw_args
  end

  def call(*args)
    @procedure.call(*args)
  end
end

if (ARGV.size < 1) 
  puts "Usage: " + __FILE__ + " /path/to/port [baud_rate = 38400]"
  exit 1
end

port = ARGV[0]
device = MySerialPort.new(port, ARGV.size > 1 ? ARGV[1].to_i : 38400) 
prompt = "> "
commands = {}

commands["help"] = Command.new(
  "help", 
  "show this help",
  lambda {|cmd_str = nil|
    if (cmd_str)
      if (cmd = commands.fetch(cmd_str))
        puts cmd.name.to_s + ":"
        cmd.usage.split("\n").each {|line|
          puts "\t" + line.to_s
        }
      else
        puts "specified command does not exist"
      end
    else
      commands.each {|k, v|
        puts k.to_s + ":"
        v.usage.split("\n").each {|line|
          puts "\t" + line.to_s
        }
      }
    end
  }) 
commands["exit"] = Command.new(
  "exit",
  "exit this repl.",
  lambda {
    exit
  })
commands["dump"] = Command.new(
  "dump",
  "Dump all statuses.\n",
  lambda {
    puts device
  }) 
commands["rts"] = Command.new(
  "rts",
  "rts [0|1]\n" +
    "Set the state (0 or 1) of the RTS(Request to Send).\n" +
    "Or show current RTS.",
  lambda {|v=nil|
    if (v)
      device.rts=v.to_i
    end
    puts device.rts ? "1" : "0"
  }) 
commands["cts"] = Command.new(
  "cts",
  "Get the state (0 or 1) of the CTS.\n",
  lambda {
    puts device.cts ? "1" : "0"
  }) 
commands["dtr"] = Command.new(
  "dtr",
  "dtr [0|1]\n" +
    "Set the state (0 or 1) of the DTR(Data Terminal Ready).\n" +
    "Or show current DTR.",
  lambda {|v=nil|
    if (v)
      device.rts=v.to_i
    end
    puts device.rts ? "1" : "0"
  }) 
commands["dsr"] = Command.new(
  "dsr",
  "Get the state (0 or 1) of the DSR(Data Set Ready).\n",
  lambda {
    puts device.dsr ? "1" : "0"
  }) 
commands["dbits"] = Command.new(
  "dbits",
  "dbits [data_bits]\n" +
    "Set the data bits.\n" +
    "Or show current data bits.",
  lambda {|v=nil|
    if (v)
      device.data_bits=v.to_i
    end
    puts device.data_bits
  }) 
commands["brate"] = Command.new(
  "brate",
  "brate [baud_rate]\n" +
    "Set the baud rate.\n" +
    "Or show current baud rate.",
  lambda {|v=nil|
    if (v)
      device.baud=v.to_i
    end
    puts device.baud
  }) 
commands["flowctl"] = Command.new(
  "flowctl",
  "flowctl [HARD | SOFT | NONE | (HARD|SOFT)]\n" +
    "Set the flow control.\n" +
    "Or show current flow control state.",
  lambda {|v=nil|
    if (v)
      device.flow_control_str = v
    end
    puts device.flow_control_str
  }) 
commands["parity"] = Command.new(
  "parity",
  "parity [EVEN | ODD | NONE]\n" +
    "Set the parity.\n" +
    "Or show current parity state.",
  lambda {|v=nil|
    if (v)
      device.parity_str = v
    end
    puts device.parity_str
  }) 
commands["getc"] = Command.new(
  "getc",
  "read a char.",
  lambda {
    puts device.getc()
  }) 
commands["gets"] = Command.new(
  "gets",
  "read a line.",
  lambda {
    puts device.gets()
  }) 
commands["putc"] = Command.new(
  "putc c",
  "write given character.",
  lambda {|v|
    device.putc(v.chr) 
  }, 1) 
commands["puts"] = Command.new(
  "puts string_to_write",
  "write given line.",
  lambda {|v|
    device.puts(v.to_s)
  }, 1) 

print prompt
while line = STDIN.gets
  elements = line.split(" ", 2)
  command_string = elements.shift
  begin
    command = commands.fetch(command_string)
    if (command.raw_args)
      command.call(elements[0])
    else
      e = elements[0].split(" ")
      command.call(*e)
    end
  rescue ArgumentError
    puts "Argument is not valid"

    command = commands.fetch(command_string)
    puts command.name.to_s + ":"
    command.usage.split("\n").each {|line|
      puts "\t" + line.to_s
    }

  rescue KeyError
    puts command_string.to_s + " command not found."
    commands["help"].call
  end
  print prompt
end
