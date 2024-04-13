# frozen_string_literal: true

require 'rmagick'

# Demonstrate the Image#transverse method

img = Magick::Image.read('images/Flower_Hat.jpg').first
img = img.transverse
img.write('transverse.jpg')
exit
