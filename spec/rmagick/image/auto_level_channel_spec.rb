# frozen_string_literal: true

RSpec.describe Magick::Image, "#auto_level_channel" do
  it "works" do
    image = described_class.new(20, 20)

    result = image.auto_level_channel
    expect(result).to be_instance_of(described_class)
    expect(result).not_to be(image)

    expect { image.auto_level_channel Magick::RedChannel }.not_to raise_error
    expect { image.auto_level_channel Magick::RedChannel, Magick::BlueChannel }.not_to raise_error
    expect { image.auto_level_channel(1) }.to raise_error(TypeError)
  end
end
