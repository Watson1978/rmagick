lib_dir = File.expand_path('../../lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'rubygems'
require 'mkmf'
require 'date'

module RMagick
  class Extconf
    require 'rmagick/version'
    RMAGICK_VERS = ::Magick::VERSION
    MIN_RUBY_VERS = ::Magick::MIN_RUBY_VERSION
    MIN_RUBY_VERS_NO = MIN_RUBY_VERS.tr('.', '').to_i

    attr_reader :headers

    def initialize
      configure_compile_options
      assert_can_compile!
      configure_headers
    end

    def configured_compile_options
      {
        magick_config: $magick_config,
        with_magick_wand: $with_magick_wand,
        pkg_config: $pkg_config,
        magick_version: $magick_version,
        local_libs: $LOCAL_LIBS,
        cflags: $CFLAGS,
        cppflags: $CPPFLAGS,
        ldflags: $LDFLAGS,
        defs: $defs,
        config_h: $config_h
      }
    end

    def configure_headers
      # headers = %w{assert.h ctype.h errno.h float.h limits.h math.h stdarg.h stddef.h stdint.h stdio.h stdlib.h string.h time.h}
      @headers = %w[assert.h ctype.h stdio.h stdlib.h math.h time.h]
      headers << 'stdint.h' if have_header('stdint.h') # defines uint64_t
      headers << 'sys/types.h' if have_header('sys/types.h')

      if have_header('MagickWand/MagickWand.h')
        headers << 'MagickWand/MagickWand.h'
      else
        exit_failure "\nCan't install RMagick #{RMAGICK_VERS}. Can't find MagickWand.h."
      end
    end

    def configure_compile_options
      # Magick-config is not available on Windows
      if RUBY_PLATFORM !~ /mswin|mingw/

        # Check for compiler. Extract first word so ENV['CC'] can be a program name with arguments.
        config = defined?(RbConfig) ? ::RbConfig : ::Config
        cc = (ENV['CC'] || config::CONFIG['CC'] || 'gcc').split(' ').first
        exit_failure "No C compiler found in ${ENV['PATH']}. See mkmf.log for details." unless find_executable(cc)

        # ugly way to handle which config tool we're going to use...
        $with_magick_wand = false
        $magick_config = false
        $pkg_config = false

        # Check for Magick-config
        if find_executable('pkg-config')
          $pkg_config = true
          $magick_version = `pkg-config MagickCore --modversion`[/^(\d+\.\d+\.\d+)/]
        elsif find_executable('Magick-config') && !has_graphicsmagick_libmagick_dev_compat?
          $magick_config = true
          $magick_version = `Magick-config --version`[/^(\d+\.\d+\.\d+)/]
        else
          exit_failure "Can't install RMagick #{RMAGICK_VERS}. Can't find Magick-config or pkg-config in #{ENV['PATH']}\n"
        end

        check_multiple_imagemagick_versions
        check_partial_imagemagick_versions

        # Ensure minimum ImageMagick version
        # Check minimum ImageMagick version if possible
        checking_for("outdated ImageMagick version (<= #{Magick::MIN_IM_VERSION})") do
          Logging.message("Detected ImageMagick version: #{$magick_version}\n")

          exit_failure "Can't install RMagick #{RMAGICK_VERS}. You must have ImageMagick #{Magick::MIN_IM_VERSION} or later.\n" if Gem::Version.new($magick_version) < Gem::Version.new(Magick::MIN_IM_VERSION)
          true
        end

        # From ImageMagick 6.9 binaries are split to two and we have to use
        # MagickWand instead of MagickCore
        checking_for("presence of MagickWand API (ImageMagick version >= #{Magick::MIN_WAND_VERSION})") do
          $with_magick_wand = Gem::Version.new($magick_version) >= Gem::Version.new(Magick::MIN_WAND_VERSION)
          exit_failure "Older version detected." unless $with_magick_wand
          true
        end

        # either set flags using Magick-config, MagickWand-config or pkg-config (new Debian default)
        if $with_magick_wand
          if $magick_config
            # Save flags
            $CFLAGS = ENV['CFLAGS'].to_s + ' ' + `MagickWand-config --cflags`.chomp
            $CPPFLAGS = ENV['CPPFLAGS'].to_s + ' ' + `MagickWand-config --cppflags`.chomp
            $LDFLAGS = ENV['LDFLAGS'].to_s + ' ' + `MagickWand-config --ldflags`.chomp
            $LOCAL_LIBS = ENV['LIBS'].to_s + ' ' + `MagickWand-config --libs`.chomp
          end

          if $pkg_config
            # Save flags
            $CFLAGS = ENV['CFLAGS'].to_s + ' ' + `pkg-config --cflags MagickWand`.chomp
            $CPPFLAGS = ENV['CPPFLAGS'].to_s + ' ' + `pkg-config --cflags MagickWand`.chomp
            $LDFLAGS = ENV['LDFLAGS'].to_s + ' ' + `pkg-config --libs MagickWand`.chomp
            $LOCAL_LIBS = ENV['LIBS'].to_s + ' ' + `pkg-config --libs MagickWand`.chomp
          end
        else
          if $magick_config
            # Save flags
            $CFLAGS = ENV['CFLAGS'].to_s + ' ' + `Magick-config --cflags`.chomp
            $CPPFLAGS = ENV['CPPFLAGS'].to_s + ' ' + `Magick-config --cppflags`.chomp
            $LDFLAGS = ENV['LDFLAGS'].to_s + ' ' + `Magick-config --ldflags`.chomp
            $LOCAL_LIBS = ENV['LIBS'].to_s + ' ' + `Magick-config --libs`.chomp
          end

          if $pkg_config
            # Save flags
            $CFLAGS = ENV['CFLAGS'].to_s + ' ' + `pkg-config --cflags MagickCore`.chomp
            $CPPFLAGS = ENV['CPPFLAGS'].to_s + ' ' + `pkg-config --cflags MagickCore`.chomp
            $LDFLAGS = ENV['LDFLAGS'].to_s + ' ' + `pkg-config --libs MagickCore`.chomp
            $LOCAL_LIBS = ENV['LIBS'].to_s + ' ' + `pkg-config --libs MagickCore`.chomp
          end
        end

        set_archflags_for_osx if RUBY_PLATFORM =~ /darwin/ # osx

      elsif RUBY_PLATFORM =~ /mingw/ # mingw

        `magick -version` =~ /Version: ImageMagick (\d+\.\d+\.\d+)-+\d+ /
        abort 'Unable to get ImageMagick version' unless Regexp.last_match(1)
        $magick_version = Regexp.last_match(1)
        search_paths_for_library_for_mingw unless have_library('CORE_RL_MagickCore_')
        have_library('X11')

      else # mswin

        `magick -version` =~ /Version: ImageMagick (\d+\.\d+\.\d+)-+\d+ /
        abort 'Unable to get ImageMagick version' unless Regexp.last_match(1)
        $magick_version = Regexp.last_match(1)
        $CFLAGS = '-W3'
        $CPPFLAGS = %(-I"C:\\Program Files\\Microsoft Platform SDK for Windows Server 2003 R2\\Include" -I"C:\\Program Files\\ImageMagick-#{$magick_version}-Q8\\include")
        # The /link option is required by the Makefile but causes warnings in the mkmf.log file.
        $LDFLAGS = %(/link /LIBPATH:"C:\\Program Files\\Microsoft Platform SDK for Windows Server 2003 R2\\Lib" /LIBPATH:"C:\\Program Files\\ImageMagick-#{$magick_version}-Q8\\lib" /LIBPATH:"C:\\ruby\\lib")
        $LOCAL_LIBS = 'CORE_RL_MagickCore_.lib'
        have_library('X11')

      end
    end

    # Test for a specific value in an enum type
    def have_enum_value(enum, value, headers = nil, &b)
      checking_for "#{enum}.#{value}" do
        if try_compile(<<"SRC", &b)
#{COMMON_HEADERS}
        #{cpp_include(headers)}
/*top*/
int main() { #{enum} t = #{value}; t = t; return 0; }
SRC
          $defs.push(format('-DHAVE_ENUM_%s', value.upcase))
          true
        else
          false
        end
      end
    end

    # Test for multiple values of the same enum type
    def have_enum_values(enum, values, headers = nil, &b)
      values.each do |value|
        have_enum_value(enum, value, headers, &b)
      end
    end

    def has_graphicsmagick_libmagick_dev_compat?
      config_path = `which Magick-config`.chomp
      if File.exist?(config_path) &&
         File.symlink?(config_path) &&
         File.readlink(config_path) =~ /GraphicsMagick/
        msg = 'Found a graphicsmagick-libmagick-dev-compat installation.'
        Logging.message msg
        message msg + "\n"
        true
      else
        false
      end
    end

    def exit_failure(msg)
      Logging.message msg
      message msg + "\n"
      exit(1)
    end

    # Seems like lots of people have multiple versions of ImageMagick installed.
    def check_multiple_imagemagick_versions
      versions = []
      path = ENV['PATH'].split(File::PATH_SEPARATOR)
      path.each do |dir|
        file = File.join(dir, 'Magick-config')
        next unless File.executable? file

        vers = `#{file} --version`.chomp.strip
        prefix = `#{file} --prefix`.chomp.strip
        versions << [vers, prefix, dir]
      end
      versions.uniq!
      return unless versions.size > 1

      msg = "\nWarning: Found more than one ImageMagick installation. This could cause problems at runtime.\n"
      versions.each do |vers, prefix, dir|
        msg << "         #{dir}/Magick-config reports version #{vers} is installed in #{prefix}\n"
      end
      msg << "Using #{versions[0][0]} from #{versions[0][1]}.\n\n"
      Logging.message msg
      message msg
    end

    # Ubuntu (maybe other systems) comes with a partial installation of
    # ImageMagick in the prefix /usr (some libraries, no includes, and no
    # binaries). This causes problems when /usr/lib is in the path (e.g., using
    # the default Ruby installation).
    def check_partial_imagemagick_versions
      prefix = config_string('prefix') || ''
      matches = [
        prefix + '/lib/lib?agick*',
        prefix + '/include/ImageMagick',
        prefix + '/bin/Magick-config'
      ].map do |file_glob|
        Dir.glob(file_glob)
      end
      matches.delete_if(&:empty?)
      return unless !matches.empty? && matches.length < 3

      msg = "\nWarning: Found a partial ImageMagick installation. Your operating system likely has some built-in ImageMagick libraries but not all of ImageMagick. This will most likely cause problems at both compile and runtime.\nFound partial installation at: " + prefix + "\n"
      Logging.message msg
      message msg
    end

    # issue #169
    # set ARCHFLAGS appropriately for OSX
    def set_archflags_for_osx
      archflags = []
      fullpath = `which convert`
      fileinfo = `file #{fullpath}`

      # default ARCHFLAGS
      archs = $ARCH_FLAG.scan(/-arch\s+(\S+)/).flatten

      archs.each do |arch|
        archflags << "-arch #{arch}" if fileinfo.include?(arch)
      end

      $ARCH_FLAG = archflags.join(' ') unless archflags.empty?
    end

    def search_paths_for_library_for_mingw
      msg = 'searching PATH for the ImageMagick library...'
      Logging.message msg
      message msg + "\n"

      found_lib = false

      paths = ENV['PATH'].split(File::PATH_SEPARATOR)
      paths.each do |dir|
        lib = File.join(dir, 'lib')
        lib_file = File.join(lib, 'CORE_RL_MagickCore_.lib')
        next unless File.exist?(lib_file)

        $CPPFLAGS = %(-I"#{File.join(dir, 'include')}")
        $LDFLAGS = %(-L"#{lib}")
        found_lib = have_library('CORE_RL_MagickCore_')
        break if found_lib
      end

      return if found_lib

      exit_failure <<END_MINGW
Can't install RMagick #{RMAGICK_VERS}.
Can't find the ImageMagick library.
Retry with '--with-opt-dir' option.
Usage: gem install rmagick -- '--with-opt-dir=\"[path to ImageMagick]\"'
e.g.
  gem install rmagick -- '--with-opt-dir=\"C:\Program Files\ImageMagick-7.0.8-Q16\"'
END_MINGW
    end

    def assert_can_compile!
      assert_not_windows!
      assert_minimum_ruby_version!
      assert_has_dev_libs!
    end

    def assert_not_windows!
      return unless RUBY_PLATFORM =~ /mswin/

      abort <<END_MSWIN
+----------------------------------------------------------------------------+
| This rmagick gem is for use only on Linux, BSD, OS X, and similar systems  |
| that have a gnu or similar toolchain installed. The rmagick-win32 gem is a |
| pre-compiled version of RMagick bundled with ImageMagick for use on        |
| Microsoft Windows systems. The rmagick-win32 gem is available on RubyForge.|
| See http://rmagick.rubyforge.org/install-faq.html for more information.    |
+----------------------------------------------------------------------------+
END_MSWIN
    end

    def assert_minimum_ruby_version!
      unless checking_for("Ruby version >= #{MIN_RUBY_VERS}") do
        version = RUBY_VERSION.tr('.', '').to_i
        version >= MIN_RUBY_VERS_NO
      end
        exit_failure "Can't install RMagick #{RMAGICK_VERS}. Ruby #{MIN_RUBY_VERS} or later required.\n"
      end
    end

    def assert_has_dev_libs!
      return unless RUBY_PLATFORM !~ /mswin|mingw/

      # check for pkg-config if Magick-config doesn't exist
      if $magick_config && `Magick-config --libs`[/\bl\s*(MagickCore|Magick)7?\b/]
      elsif $pkg_config && `pkg-config --libs MagickCore`[/\bl\s*(MagickCore|Magick)7?\b/]
      else
        exit_failure "Can't install RMagick #{RMAGICK_VERS}. " \
                   "Can't find the ImageMagick library or one of the dependent libraries. " \
                   "Check the mkmf.log file for more detailed information.\n"
      end
    end

    def create_header_file
      have_enum_values('StyleType', ['BoldStyle'], headers) # 7.0.8
      have_enum_values('CompressionType', ['ZstdCompression', # 7.0.8
                                           'WebPCompression'], headers) # 7.0.8

      headers = ['ruby.h', 'ruby/io.h']

      # Miscellaneous constants
      $defs.push("-DRUBY_VERSION_STRING=\"ruby #{RUBY_VERSION}\"")
      $defs.push("-DRMAGICK_VERSION_STRING=\"RMagick #{RMAGICK_VERS}\"")

      create_header
    end

    def create_makefile_file
      create_header_file
      # Prior to 1.8.5 mkmf duplicated the symbols on the command line and in the
      # extconf.h header. Suppress that behavior by removing the symbol array.
      $defs = []

      # Force re-compilation if the generated Makefile changed.
      $config_h = 'Makefile rmagick.h'

      create_makefile('RMagick2')
      print_summary
    end

    def print_summary
      summary = <<"END_SUMMARY"


#{'=' * 70}
      #{DateTime.now.strftime('%a %d%b%y %T')}
This installation of RMagick #{RMAGICK_VERS} is configured for
Ruby #{RUBY_VERSION} (#{RUBY_PLATFORM}) and ImageMagick #{$magick_version}
      #{'=' * 70}


END_SUMMARY

      Logging.message summary
      message summary
    end
  end
end

extconf = RMagick::Extconf.new
at_exit do
  msg = "Configured compile options: #{extconf.configured_compile_options}"
  Logging.message msg
  message msg + "\n"
end
extconf.create_makefile_file
