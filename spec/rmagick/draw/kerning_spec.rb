# frozen_string_literal: true

RSpec.describe Magick::Draw, '#kerning' do
  it 'accepts a valid parameter without raising an error' do
    draw = described_class.new

    expect { draw.kerning(1) }.not_to raise_error
  end

  it 'raises an error when given an invalid parameter' do
    draw = described_class.new

    expect { draw.kerning('a') }.to raise_error(ArgumentError)
    expect { draw.kerning([]) }.to raise_error(TypeError)
  end

  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.kerning(40.5)
    expect(draw.inspect).to eq('kerning 40.5')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.kerning('40.5')
    expect(draw.inspect).to eq('kerning 40.5')
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.kerning(1/4r)
    expect(draw.inspect).to eq('kerning 0.25')
    expect { draw.draw(image) }.not_to raise_error

    # expect { draw.kerning(Float::NAN) }.to raise_error(ArgumentError)
    expect { draw.kerning('nan') }.to raise_error(ArgumentError)
    expect { draw.kerning('xxx') }.to raise_error(ArgumentError)
    expect { draw.kerning(nil) }.to raise_error(TypeError)
  end
end
