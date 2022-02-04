require_relative 'converter'
require_relative '../diagram_processor'

module Asciidoctor
  module Diagram
    class ContextMapperBlockProcessor < DiagramBlockProcessor
      use_converter ContextMapperConverter
    end

    class ContextMapperBlockMacroProcessor < DiagramBlockMacroProcessor
      use_converter ContextMapperConverter
    end

    class ContextMapperInlineMacroProcessor < DiagramInlineMacroProcessor
      use_converter ContextMapperConverter
    end
  end
end
