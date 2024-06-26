# frozen_string_literal: true

RSpec.describe Magick::Draw, '#get_type_metrics' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(10, 10)

    expect { draw.get_type_metrics('ABCDEF') }.not_to raise_error
    expect { draw.get_type_metrics(image, 'ABCDEF') }.not_to raise_error

    expect { draw.get_type_metrics }.to raise_error(ArgumentError)
    expect { draw.get_type_metrics(image, 'ABCDEF', 20) }.to raise_error(ArgumentError)
    expect { draw.get_type_metrics(image, '') }.to raise_error(ArgumentError)
    expect { draw.get_type_metrics('x', 'ABCDEF') }.to raise_error(NoMethodError)
  end

  it 'accepts an ImageList argument' do
    draw = described_class.new

    image_list = Magick::ImageList.new
    image_list.new_image(10, 10)
    expect { draw.get_type_metrics(image_list, 'ABCDEF') }.not_to raise_error
  end
end
