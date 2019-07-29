require 'test/unit'

module AppearanceAssertion
  include Test::Unit::Assertions

  def assert_same_image(expected_image_path, image_object, delta: 0.01)
    # return if IM_VERSION < Gem::Version.new('6.8')

    path = File.expand_path(File.join(__dir__, expected_image_path))

    # image_object.write(path) { |info| info.quality = 90 }

    expected = Magick::Image.read(path).first
    _, error = expected.compare_channel(image_object, Magick::MeanSquaredErrorMetric)
    puts "error: #{expected_image_path} -> #{format('%.10f', error)}"
    assert_in_delta(0.0, error, delta)
  end
end
