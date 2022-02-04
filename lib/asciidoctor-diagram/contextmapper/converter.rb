require 'set'

require_relative '../diagram_converter'
require_relative '../diagram_processor'
require_relative '../util/java'

module Asciidoctor
  module Diagram
    # @private
    class ContextMapperConverter
      include DiagramConverter

      OPTIONS = {
          :scale => lambda { |o, v| o << '--scale' << v if v },
          :tabs => lambda { |o, v| o << '--tabs' << v if v },
          :background => lambda { |o, v| o << '--background' << v if v },
          :antialias => lambda { |o, v| o << '--no-antialias' if v == 'false' },
          :separation => lambda { |o, v| o  << '--no-separation' if v == 'false'},
          :round_corners => lambda { |o, v| o  << '--round-corners' if v == 'true'},
          :shadows => lambda { |o, v| o  << '--no-shadows' if v == 'false'},
          :debug => lambda { |o, v| o  << '--debug' if v == 'true'},
          :fixed_slope => lambda { |o, v| o  << '--fixed-slope' if v == 'true'},
          :transparent => lambda { |o, v| o  << '--transparent' if v == 'true'}
      }

      CLASSPATH_ENV = 'DIAGRAM_CONTEXTMAPPER_CLASSPATH'
      CONTEXTMAPPER_JARS = if ENV.has_key?(CLASSPATH_ENV)
                        ENV[CLASSPATH_ENV].split(File::PATH_SEPARATOR)
                      else
                        begin
                          require 'asciidoctor-diagram/contextmapper/classpath'
                          ::Asciidoctor::Diagram::ContextMapperClasspath::JAR_FILES
                        rescue LoadError
                          raise "Could not load ContextMapper. Eiter require 'asciidoctor-diagram-contextmappermini' or specify the location of the ContextMapper JAR(s) using the 'DIAGRAM_CONTEXTMAPPER_CLASSPATH' environment variable."
                        end
                      end

      Java.classpath.concat Dir[File.join(File.dirname(__FILE__), '*.jar')]
      Java.classpath.concat CONTEXTMAPPER_JARS

      def supported_formats
        [:png, :svg]
      end

      def collect_options(source)
        options = {}
        
        OPTIONS.keys.each do |option|
          attr_name = option.to_s.tr('_', '-')
          options[option] = source.attr(attr_name) || source.attr(attr_name, nil, 'contextmapper-option')
        end
        
        options
      end

      def native_scaling?
        true
      end

      def convert(source, format, options)
        Java.load

        flags = []

        options.each do |option, value|
          OPTIONS[option].call(flags, value)
        end

        options_string = flags.join(' ')

        case format
        when :png
          mime_type = 'image/png'
        when :svg
          mime_type = 'image/svg+xml'
        else
          raise "Unsupported format: #{format}"
        end

        headers = {
            'Accept' => mime_type,
            'X-Options' => options_string
        }

        response = Java.send_request(
            :url => '/contextmapper',
            :body => source.to_s,
            :headers => headers
        )

        unless response[:code] == 200
          raise Java.create_error("ContextMapper image generation failed", response)
        end

        response[:body]
      end
    end
  end
end
