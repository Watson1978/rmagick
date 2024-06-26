# frozen_string_literal: true

RSpec.describe Magick::Draw, '#font_weight' do
  it 'works' do
    image = Magick::Image.new(200, 200)

    Magick::WeightType.values do |weight|
      draw = described_class.new
      draw.font_weight(weight)
      draw.text(50, 50, 'Hello world')
      expect { draw.draw(image) }.not_to raise_error
    end

    draw = described_class.new
    draw.font_weight(400)
    expect(draw.inspect).to eq('font-weight 400')
    draw.text(50, 50, 'Hello world')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.font_weight('xxx') }.to raise_error(ArgumentError)
  end
end
