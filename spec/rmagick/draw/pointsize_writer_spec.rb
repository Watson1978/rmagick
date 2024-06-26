# frozen_string_literal: true

RSpec.describe Magick::Draw, '#pointsize=' do
  it 'works' do
    draw = described_class.new

    expect { draw.pointsize = 2 }.not_to raise_error
    expect { draw.pointsize = 'x' }.to raise_error(TypeError)
  end
end
