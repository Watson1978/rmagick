# frozen_string_literal: true

RSpec.describe Magick::Draw, '#fill_rule' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.fill_rule('evenodd')
    expect(draw.inspect).to eq('fill-rule evenodd')
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.fill_rule('nonzero')
    expect(draw.inspect).to eq('fill-rule nonzero')
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(image) }.not_to raise_error

    expect { draw.fill_rule('zero') }.to raise_error(ArgumentError)
  end
end
