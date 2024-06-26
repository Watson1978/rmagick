# frozen_string_literal: true

RSpec.describe Magick::Image::Info, '#fuzz' do
  it 'works' do
    info = described_class.new

    expect { info.fuzz = 50 }.not_to raise_error
    expect(info.fuzz).to eq(50)
    expect { info.fuzz = '50%' }.not_to raise_error
    expect(info.fuzz).to eq(Magick::QuantumRange * 0.5)
    expect { info.fuzz = nil }.to raise_error(TypeError)
    expect { info.fuzz = 'xxx' }.to raise_error(ArgumentError)
  end
end
