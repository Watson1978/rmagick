# frozen_string_literal: true

RSpec.describe Magick::Image, "#colormap" do
  it "works" do
    image = described_class.new(20, 20)

    # IndexError b/c image is DirectClass
    expect { image.colormap(0) }.to raise_error(IndexError)
    # Read PseudoClass image
    pc_image = described_class.read(IMAGES_DIR + '/Button_0.gif') { |info| info.depth = 8 }.first
    expect { pc_image.colormap(0) }.not_to raise_error
    ncolors = pc_image.colors
    expect { pc_image.colormap(ncolors + 1) }.to raise_error(IndexError)
    expect { pc_image.colormap(-1) }.to raise_error(IndexError)
    expect { pc_image.colormap(ncolors - 1) }.not_to raise_error
    result = pc_image.colormap(0)
    expect(result).to be_instance_of(String)

    # test 'set' operation
    old_color = pc_image.colormap(0)
    result = pc_image.colormap(0, 'red')
    expect(result).to eq(old_color)
    result = pc_image.colormap(0)
    expected = value_by_version(
      "6.8": "#FF0000",
      "6.9": "#FF0000FF",
      "7.0": "#FF0000FF",
      "7.1": "#FF0000FF"
    )
    expect(result).to eq(expected)

    pixel = Magick::Pixel.new(Magick::QuantumRange)
    expect { pc_image.colormap(0, pixel) }.not_to raise_error
    expect { pc_image.colormap }.to raise_error(ArgumentError)
    expect { pc_image.colormap(0, pixel, Magick::BlackChannel) }.to raise_error(ArgumentError)
    expect { pc_image.colormap(0, [2]) }.to raise_error(TypeError)
    pc_image.freeze
    expect { pc_image.colormap(0, 'red') }.to raise_error(FrozenError)
  end
end
