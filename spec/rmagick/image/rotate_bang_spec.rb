# frozen_string_literal: true

RSpec.describe Magick::Image, '#rotate!' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.rotate!(45)
    expect(result).to be(image)

    image.freeze
    expect { image.rotate!(45) }.to raise_error(FrozenError)
  end
end
