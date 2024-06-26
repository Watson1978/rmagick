# frozen_string_literal: true

RSpec.describe Magick::Draw, '#draw' do
  it 'works' do
    draw1 = described_class.new
    draw2 = draw1.dup

    image = Magick::Image.new(10, 10)
    draw1.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    expect { draw1.draw(image) }.not_to raise_error

    expect { draw2.draw(image) }.to raise_error(ArgumentError)
    expect { draw2.draw('x') }.to raise_error(NoMethodError)
  end

  it 'accepts an ImageList argument' do
    draw = described_class.new

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    draw.path('M110,100 h-75 a75,75 0 1,0 75,-75 z')
    expect { draw.draw(image_list) }.not_to raise_error
  end
end
