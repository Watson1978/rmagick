# frozen_string_literal: true

describe Magick::Segment, '#to_s' do
  it 'works' do
    segment = described_class.new(10, 20, 30, 40)
    expect(segment.to_s).to eq('x1=10, y1=20, x2=30, y2=40')
  end
end
