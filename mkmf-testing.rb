# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'mkmf'
create_makefile("dummy.c")

class MakefilePropertyFetcher
  @regexp
  @result
  @mathcGroupPosition = 1
  
  attr_reader :result
  
  def initialize(regexp, matchGroupPosition = 1)
    @regexp = regexp
    @matchGroupPosition = matchGroupPosition
  end
  def match(str, pos = 0)
    m = @regexp.match(str, pos)
    @result = m.to_a[@matchGroupPosition] if m
  end
  def match?
    return if @result
  end
end

required = {
  :libpath => MakefilePropertyFetcher.new(/^\s*LIBPATH\s*=\s*(.*)$/),
  :dldflags => MakefilePropertyFetcher.new(/^\s*DLDFLAGS\s*=\s*(.*)$/),
  :libs => MakefilePropertyFetcher.new(/^\s*LIBS\s*=\s*(.*)$/)
}

filled = true
IO.foreach("Makefile") {|line|  
  filled = true
  
  required.each {|k, v|
    v.match(line)
    filled = filled && v.match?
  }
  
  break if filled
}

required.each {|k, v|
  puts k.to_s + ":" + v.result.to_s
}