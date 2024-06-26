# frozen_string_literal: true

RSpec.describe Magick::Image, '#levelize_channel' do
  it 'works' do
    image = described_class.new(20, 20)

    result = image.levelize_channel(0, Magick::QuantumRange)
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.levelize_channel(0) }.not_to raise_error
    expect { image.levelize_channel(0, Magick::QuantumRange) }.not_to raise_error
    expect { image.levelize_channel(0, Magick::QuantumRange, 0.5) }.not_to raise_error
    expect { image.levelize_channel(0, Magick::QuantumRange, 0.5, Magick::RedChannel) }.not_to raise_error
    expect { image.levelize_channel(0, Magick::QuantumRange, 0.5, Magick::RedChannel, Magick::BlueChannel) }.not_to raise_error

    expect { image.levelize_channel(0, Magick::QuantumRange, 0.5, 1, Magick::RedChannel) }.to raise_error(TypeError)
    expect { image.levelize_channel }.to raise_error(ArgumentError)
  end
end
