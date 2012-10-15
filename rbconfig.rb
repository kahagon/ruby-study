require 'rbconfig'

puts RbConfig.expand("$(bindir) $(libdir)")