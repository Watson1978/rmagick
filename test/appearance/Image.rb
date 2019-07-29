#!/usr/bin/env ruby -w

require 'rmagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require_relative 'appearance_assertion'

IMAGES_DIR = File.expand_path('../../doc/ex/images') unless defined? IMAGES_DIR
DELTA = 0.00001

class AppearanceMontageUT < Test::Unit::TestCase
  include AppearanceAssertion

  def setup
    @image = Magick::Image.read(image_path('images/Small_Flower_Hat.png')).first
  end

  def test_adaptive_blur_channel
    new_image = @image.adaptive_blur_channel(20, 5, Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_adaptive_blur_channel.png', new_image, delta: DELTA)
  end

  def test_adaptive_sharpen_channel
    new_image = @image.adaptive_sharpen_channel(20, 5, Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_adaptive_sharpen_channel.png', new_image, delta: DELTA)
  end

  def test_add_compose_mask
    source = Magick::Image.read(image_path('images/compose_mask_source.gif')).first
    mask = Magick::Image.read(image_path('images/compose_mask.gif')).first

    @image.add_compose_mask(source)
    @image.add_compose_mask(mask)
    new_image = @image.composite(source, Magick::CenterGravity, Magick::BlendCompositeOp)
    assert_same_image('expected/image_add_compose_mask.png', new_image)
  end

  def test_auto_gamma_channel
    new_image = @image.auto_gamma_channel(Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_auto_gamma_channel.png', new_image, delta: DELTA)
  end

  def test_auto_level_channel
    new_image = @image.auto_level_channel(Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_auto_level_channel.png', new_image, delta: DELTA)
  end

  def test_bilevel_channel
    new_image = @image.bilevel_channel(2.0 / 3.0 * Magick::QuantumRange, Magick::RedChannel, Magick::GreenChannel)
    assert_same_image('expected/image_bilevel_channel.png', new_image)
  end

  def test_blend
    source = Magick::Image.read(image_path('images/compose_mask_source.gif')).first
    new_image = @image.blend(source, '90%', '20%', 50, 20)
    assert_same_image('expected/image_blend.png', new_image, delta: DELTA)
  end

  def test_displace
    source = Magick::Image.read(image_path('images/compose_mask_source.gif')).first
    new_image = @image.displace(source, 25, 25, Magick::CenterGravity, 10, 10)
    assert_same_image('expected/image_displace.png', new_image, delta: DELTA)
  end

  def test_blur_channel
    new_image = @image.blur_channel(10, 5, Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_blur_channel.png', new_image, delta: DELTA)
  end

  def test_border
    new_image = @image.border(20, 20, 'red')
    assert_same_image('expected/image_border.png', new_image, delta: DELTA)
  end

  def test_channel
    new_image = @image.channel(Magick::BlueChannel)
    assert_same_image('expected/image_channel.png', new_image, delta: DELTA)
  end

  def test_clut_channel
    clut = Magick::Image.new(20, 1) { self.background_color = 'red' }
    @image.clut_channel(clut, Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_clut_channel.png', @image, delta: DELTA)
  end

  def test_color_flood_fill
    target_color = @image.pixel_color(100, 100)
    @image.fuzz = 25
    new_image = @image.color_flood_fill(target_color, 'red', 100, 100, Magick::FloodfillMethod)
    assert_same_image('expected/image_color_flood_fill.png', new_image, delta: DELTA)
  end

  def test_colorize
    pixel = Magick::Pixel.new(Magick::QuantumRange)
    new_image = @image.colorize(0.4, 0.5, 0.6, 0.7, pixel)
    assert_same_image('expected/image_colorize.png', new_image, delta: DELTA)
  end

  def test_composite_affine
    affine = Magick::AffineMatrix.new(1, 1, 1, 0, 0, 0)
    img1 = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    img2 = Magick::Image.read(IMAGES_DIR + '/Button_1.gif').first

    new_image = img1.composite_affine(img2, affine)
    assert_same_image('expected/image_composite_affine.gif', new_image, delta: DELTA)
  end

  def test_composite_tiled
    fg = Magick::Image.new(50, 100) { self.background_color = 'red' }
    new_image = @image.composite_tiled(fg, Magick::DarkenCompositeOp, Magick::BlueChannel, Magick::GreenChannel)
    assert_same_image('expected/image_composite_tiled.png', new_image, delta: DELTA)
  end

  def test_constitute
    pixels = @image.dispatch(0, 0, @image.columns, @image.rows, 'RGB').reverse
    new_image = Magick::Image.constitute(@image.columns, @image.rows, 'RGB', pixels)
    assert_same_image('expected/image_constitute.png', new_image, delta: DELTA)
  end

  def test_contrast
    new_image = @image.contrast(true)
    assert_same_image('expected/image_contrast.png', new_image, delta: DELTA)
  end

  def test_contrast_stretch_channel
    new_image = @image.contrast_stretch_channel('60%', '20%', Magick::RedChannel, Magick::GreenChannel)
    assert_same_image('expected/image_contrast_stretch_channel.png', new_image)
  end

  def test_morphology_channel
    kernel = Magick::KernelInfo.new('Octagon')
    new_image = @image.morphology_channel(Magick::RedChannel, Magick::EdgeOutMorphology, 2, kernel)
    assert_same_image('expected/image_morphology_channel.png', new_image)
  end

  def test_convolve
    kernel = [0.5, 1.0, 0.5, 1.0, 0.5, 1.0, 0.5, 1.0, 0.5]
    new_image = @image.convolve(1, kernel)
    assert_same_image('expected/image_convolve.png', new_image, delta: DELTA)
  end

  def test_convolve_channel
    kernel = [0.5, 1.0, 0.5, 1.0, 0.5, 1.0, 0.5, 1.0, 0.5]
    new_image = @image.convolve_channel(1, kernel, Magick::RedChannel, Magick:: BlueChannel)
    assert_same_image('expected/image_convolve_channel.png', new_image, delta: DELTA)
  end

  def test_cycle_colormap
    new_image = @image.cycle_colormap(100)
    assert_same_image('expected/image_cycle_colormap.png', new_image)
  end

  def test_equalize
    new_image = @image.equalize
    assert_same_image('expected/image_equalize.png', new_image)
  end

  def test_equalize_channel
    new_image = @image.equalize_channel(Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_equalize_channel.png', new_image, delta: DELTA)
  end

  def test_erase!
    @image.erase!
    assert_same_image('expected/image_erase_bang.png', @image, delta: DELTA)
  end

  def test_frame
    new_image = @image.frame(20, 20, 20, 20, 5, 5, 'red')
    assert_same_image('expected/image_frame.png', new_image, delta: DELTA)
  end

  def test_function_channel
    new_image = @image.function_channel(Magick::SinusoidFunction, 0.5, Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_function_channel.png', new_image, delta: DELTA)
  end

  def test_fx
    new_image = @image.fx('1/3', Magick::BlueChannel, Magick::RedChannel)
    assert_same_image('expected/image_fx.png', new_image, delta: DELTA)
  end

  def test_gamma_channel
    new_image = @image.gamma_channel(0.5, Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_gamma_channel.png', new_image, delta: DELTA)
  end

  def test_gramma_correct
    new_image = @image.gamma_correct(0.8, 0.4, 0.5, 0.9)
    assert_same_image('expected/image_gamma_correct.png', new_image, delta: DELTA)
  end

  def test_gaussian_blur_channel
    new_image = @image.gaussian_blur_channel(5.0, 3.0, Magick::GreenChannel, Magick::BlueChannel)
    assert_same_image('expected/image_gaussian_blur_channel.png', new_image, delta: DELTA)
  end

  def test_implode
    new_image = @image.implode(0.5)
    assert_same_image('expected/image_implode.png', new_image, delta: DELTA)
  end

  def test_level2
    new_image = @image.level2(Magick::QuantumRange, Magick::QuantumRange / 2, 2)
    assert_same_image('expected/image_level2.png', new_image, delta: DELTA)
  end

  def test_level_channel
    new_image = @image.level_channel(Magick::GreenChannel, Magick::QuantumRange, Magick::QuantumRange / 2, 10)
    assert_same_image('expected/image_level_channel.png', new_image)
  end

  def test_level_colors
    new_image = @image.level_colors('white', 'red', false, Magick::GreenChannel, Magick::BlueChannel)
    assert_same_image('expected/image_level_colors.png', new_image, delta: DELTA)
  end

  def test_levelize_channel
    new_image = @image.levelize_channel(0, Magick::QuantumRange / 2, 0.5, Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_levelize_channel.png', new_image, delta: DELTA)
  end

  def test_linear_stretch
    new_image = @image.linear_stretch(Magick::QuantumRange / 2, Magick::QuantumRange)
    assert_same_image('expected/image_linear_stretch.png', new_image, delta: DELTA)
  end

  def test_matte_flood_fill
    target_color = @image.pixel_color(100, 100)
    new_image = @image.matte_flood_fill(target_color, 100, 100, Magick::FillToBorderMethod, alpha: 0.5)
    assert_same_image('expected/image_matte_flood_fill.png', new_image, delta: DELTA)
  end

  def test_modulate
    new_image = @image.modulate(0.5, 0.5, 0.5)
    assert_same_image('expected/image_modulate.png', new_image, delta: DELTA)
  end

  def test_negate
    new_image = @image.negate
    assert_same_image('expected/image_negate.png', new_image, delta: DELTA)
  end

  def test_negate_channel
    new_image = @image.negate_channel(false, Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_negate_channel.png', new_image, delta: DELTA)
  end

  def test_normalize
    new_image = @image.normalize
    assert_same_image('expected/image_normalize.png', new_image, delta: DELTA)
  end

  def test_normalize_channel
    new_image = @image.normalize_channel(Magick::RedChannel, Magick::BlueChannel)
    assert_same_image('expected/image_normalize_channel.png', new_image, delta: DELTA)
  end

  def test_oil_paint
    new_image = @image.oil_paint(5.0)
    assert_same_image('expected/image_oil_paint.png', new_image)
  end

  def test_opaque
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    target_color = img.pixel_color(100, 100)
    new_image = img.opaque(target_color, 'blue')
    assert_same_image('expected/image_opaque.gif', new_image, delta: DELTA)
  end

  def test_opaque_channel
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    target_color = img.pixel_color(100, 100)
    new_image = img.opaque_channel(target_color, 'blue', true, 50, Magick::RedChannel, Magick::GreenChannel)
    assert_same_image('expected/image_opaque_channel.gif', new_image, delta: DELTA)
  end

  def test_ordered_dither
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    new_image = img.ordered_dither(4)
    assert_same_image('expected/image_ordered_dither.gif', new_image)
  end

  def test_paint_transparent
    img = Magick::Image.read(IMAGES_DIR + '/Button_0.gif').first
    target_color = img.pixel_color(0, 0)
    new_image = img.paint_transparent(target_color, true, 100, alpha: Magick::TransparentAlpha)
    assert_same_image('expected/image_paint_transparent.gif', new_image)
  end

  def image_path(path)
    File.expand_path(File.join(__dir__, path))
  end
end
