require 'asciidoctor/extensions'
require_relative 'contextmapper/extension'

Asciidoctor::Extensions.register do
  block Asciidoctor::Diagram::ContextMapperBlockProcessor, :contextmapper
  block_macro Asciidoctor::Diagram::ContextMapperBlockMacroProcessor, :contextmapper
  inline_macro Asciidoctor::Diagram::ContextMapperInlineMacroProcessor, :contextmapper
end
