require 'arduino'

pin = 13
board = Arduino.new('/dev/ttyUSB0')
board.output(pin)

10.times { |i| 
  board.setHigh(pin)
  sleep(1)
  board.setLow(pin)
  sleep(1)
}