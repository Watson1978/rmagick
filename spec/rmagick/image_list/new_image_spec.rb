# frozen_string_literal: true

RSpec.describe Magick::ImageList, "#new_image" do
  it "works" do
    image_list = described_class.new

    image_list.new_image(20, 20)

    expect(image_list.length).to eq(1)
    expect(image_list.scene).to eq(0)
    image_list.new_image(20, 20, Magick::HatchFill.new(Magick::Pixel.from_color('black'), Magick::Pixel.from_color('white')))
    expect(image_list.length).to eq(2)
    expect(image_list.scene).to eq(1)
    image_list.new_image(20, 20) { |options| options.background_color = 'red' }
    expect(image_list.length).to eq(3)
    expect(image_list.scene).to eq(2)

    expect { image_list.new_image(20, 20, nil) }.not_to raise_error
  end
end
