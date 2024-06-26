# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#[]=' do
  it 'works' do
    info = described_class.new

    expect { info['tiff'] = 'xxx' }.not_to raise_error
    expect(info['tiff']).to eq('xxx')
    expect { info['tiff', 'bits-per-sample'] = 'abc' }.not_to raise_error
    expect(info['tiff', 'bits-per-sample']).to eq('abc')
    expect { info['tiff', 'a', 'b'] }.to raise_error(ArgumentError)
    expect { info['tiff', 'a' * 10_000] }.to raise_error(ArgumentError)
    expect { info['tiff', 'a' * 10_000] = 'abc' }.to raise_error(ArgumentError)
    expect { info['tiff', 'a', 'b'] = 'abc' }.to raise_error(ArgumentError)
  end
end
