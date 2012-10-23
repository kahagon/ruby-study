require 'arduino'


pins = [7 , 8, 9, 10, 11, 12, 13]
board = Arduino.new('/dev/ttyUSB0', 38400)
board.output(pins.size)

for pin in pins do
  board.setHigh(pin)
  sleep(1)
end

for pin in pins do
  board.setLow(pin)
  sleep(1)
end