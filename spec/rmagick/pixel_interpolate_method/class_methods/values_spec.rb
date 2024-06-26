# frozen_string_literal: true

RSpec.describe Magick::PixelInterpolateMethod, '.values' do
  it 'does not cause an infinite loop' do
    image = Magick::Image.new(1, 1)
    described_class.values do |value|
      image.pixel_interpolation_method = value
      expect(image.pixel_interpolation_method).to eq(value)
    end
  end
end
