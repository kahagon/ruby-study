contents = File.new("Makefile", "r").read
puts contents
      .gsub(/^[a-zA-Z0-9.\-_$()\/]+\s*:.*[\r\n]{1,2}(?:\t+.*[\r\n]{1,2})*/, "") # remove all rules
      .gsub(/^\s*([a-zA-Z0-9_]+)\s*=/, "PSO_\\1 =") # add prefix 'PSO_' to variable declaration
      .gsub(/(\$\(?)([^)<@]+)(\)?)/, "\\1PSO_\\2\\3") # add prefix 'PSO_' to existing variable name
