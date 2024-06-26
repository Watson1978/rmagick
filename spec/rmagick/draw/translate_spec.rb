# frozen_string_literal: true

RSpec.describe Magick::Draw, '#translate' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.translate('200', 300)
    expect(draw.inspect).to eq('translate 200,300')
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.translate('x', 300) }.to raise_error(ArgumentError)
    expect { draw.translate(200, 'x') }.to raise_error(ArgumentError)
  end
end
