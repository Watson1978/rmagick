# frozen_string_literal: true

RSpec.describe Magick::Image, '#median_filter' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.median_filter
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.median_filter(0.5) }.not_to raise_error
    expect { image.median_filter(0.5, 'x') }.to raise_error(ArgumentError)
    expect { image.median_filter('x') }.to raise_error(TypeError)
  end
end
