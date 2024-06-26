# frozen_string_literal: true

# Demonstrate the random_channel_threshold method

require 'rmagick'

img = Magick::Image.read('images/Flower_Hat.jpg').first

geom = Magick::Geometry.new(Magick::QuantumRange / 2)
img2 = img.random_threshold_channel(geom, Magick::RedChannel)

img2.write('random_threshold_channel.jpg')
exit
