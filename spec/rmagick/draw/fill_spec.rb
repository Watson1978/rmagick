# frozen_string_literal: true

RSpec.describe Magick::Draw, '#fill' do
  it 'works' do
    draw = described_class.new
    image = Magick::Image.new(200, 200)

    draw.fill('tomato')
    expect(draw.inspect).to eq('fill "tomato"')
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.fill_color('tomato')
    expect(draw.inspect).to eq('fill "tomato"')
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(image) }.not_to raise_error

    draw = described_class.new
    draw.fill_pattern('tomato')
    expect(draw.inspect).to eq('fill "tomato"')
    draw.circle(10, '20.5', 30, 40.5)
    expect { draw.draw(image) }.not_to raise_error

    # draw = Magick::Draw.new
    # draw.fill_pattern('foo')
    # expect { draw.draw(image) }.not_to raise_error
  end
end
