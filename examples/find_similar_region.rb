# frozen_string_literal: true

require 'rmagick'

#   The Image#find_similar_region searches for a region in the image
#   similar to the target. This example uses a rectangle from the image
#   as the target, assuring that find_similar_region will succeed.

#   Draw a red rectangle over the image that shows where the target matched.

img = Magick::Image.read('../doc/ex/images/Flower_Hat.jpg').first
target = img.crop(21, 94, 118, 126)

res = img.find_similar_region(target)
if res
  gc = Magick::Draw.new
  gc.stroke('red')
  gc.stroke_width(2)
  gc.fill('none')
  gc.rectangle(res[0], res[1], res[0] + target.columns, res[1] + target.rows)
  gc.draw(img)
  img.alpha(Magick::DeactivateAlphaChannel)
  puts "Found similar region. Writing `find_similar_region.gif'..."
  img.write('find_similar_region.gif')
else
  puts 'No match!'
end

exit
