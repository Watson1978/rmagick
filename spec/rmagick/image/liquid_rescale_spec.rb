# frozen_string_literal: true

describe Magick::Image, '#liquid_rescale' do
  it 'works' do
    image = described_class.new(20, 20)

    begin
      image.liquid_rescale(15, 15)
    rescue NotImplementedError
      puts 'liquid_rescale not implemented.'
      return
    end

    result = image.liquid_rescale(15, 15)
    expect(result.columns).to eq(15)
    expect(result.rows).to eq(15)

    expect { image.liquid_rescale(15, 15, 0, 0) }.not_to raise_error
    expect { image.liquid_rescale(15) }.to raise_error(ArgumentError)
    expect { image.liquid_rescale(15, 15, 0, 0, 0) }.to raise_error(ArgumentError)
    expect { image.liquid_rescale([], 15) }.to raise_error(TypeError)
    expect { image.liquid_rescale(15, []) }.to raise_error(TypeError)
    expect { image.liquid_rescale(15, 15, []) }.to raise_error(TypeError)
    expect { image.liquid_rescale(15, 15, 0, []) }.to raise_error(TypeError)
  end
end
