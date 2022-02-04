module Asciidoctor
  module Diagram
    module ContextMapperClasspath
      JAR_FILES = Dir[File.join(File.dirname(__FILE__), '*.jar')].freeze
    end
  end
end