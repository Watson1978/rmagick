#!/usr/bin/env ruby -w
puts RUBY_VERSION
puts `gcc -v`
root_dir = File.expand_path('..', __dir__)
IMAGES_DIR = File.join(root_dir, 'doc/ex/images')
FILES = Dir[IMAGES_DIR + '/Button_*.gif'].sort
FLOWER_HAT = IMAGES_DIR + '/Flower_Hat.jpg'
IMAGE_WITH_PROFILE = IMAGES_DIR + '/image_with_profile.jpg'

require 'test/unit'
if RUBY_VERSION < '1.9'
  require 'test/unit/ui/console/testrunner'
  $LOAD_PATH.push(root_dir)
else
  require 'simplecov'
  $LOAD_PATH.unshift(File.join(root_dir, 'lib'))
  $LOAD_PATH.unshift(File.join(root_dir, 'test'))
end

require 'rmagick'

Magick::Magick_version =~ /ImageMagick (\d+\.\d+\.\d+)-(\d+) /
abort 'Unable to get ImageMagick version' unless Regexp.last_match(1) && Regexp.last_match(2)

IM_VERSION = Gem::Version.new(Regexp.last_match(1))
IM_REVISION = Gem::Version.new(Regexp.last_match(2))

FreezeError = if RUBY_VERSION > '2.5'
                FrozenError
              elsif RUBY_VERSION > '1.9'
                RuntimeError
              else
                TypeError
              end

require 'Draw.rb'
require 'Enum.rb'
require 'Fill.rb'
require 'Image1.rb'
require 'Image2.rb'
require 'Image3.rb'
require 'ImageList1.rb'
require 'ImageList2.rb'
require 'Image_attributes.rb'
require 'Import_Export.rb'
require 'Info.rb'
require 'KernelInfo.rb'
require 'Pixel.rb'
require 'PolaroidOptions.rb'
require 'Preview.rb'
require 'Magick.rb'
