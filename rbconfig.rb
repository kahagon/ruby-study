require 'rbconfig'

puts RbConfig.expand("$(rubyhdrdir)/$(arch)");
puts RbConfig.expand("$(rubylibdir)");