# frozen_string_literal: true

require 'rmagick'

# Demonstrate the Image#flip method

img = Magick::Image.read('images/Flower_Hat.jpg').first

img.flip!

img.write('flip.jpg')
exit
