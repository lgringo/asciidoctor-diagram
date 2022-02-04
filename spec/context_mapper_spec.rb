require_relative 'test_helper'

CONTEXTMAPPER_CODE = <<-eos
ContextMap DDDSampleMap {
  contains CargoBookingContext
  contains VoyagePlanningContext
  contains LocationContext

  CargoBookingContext [SK]<->[SK] VoyagePlanningContext

  CargoBookingContext [D]<-[U,OHS,PL] LocationContext

  VoyagePlanningContext [D]<-[U,OHS,PL] LocationContext
}
eos

describe Asciidoctor::Diagram::ContextMapperInlineMacroProcessor do
  include_examples "inline_macro", :contextmapper, CONTEXTMAPPER_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::ContextMapperBlockMacroProcessor do
  include_examples "block_macro", :contextmapper, CONTEXTMAPPER_CODE, [:png, :svg]
end

describe Asciidoctor::Diagram::ContextMapperBlockProcessor do
  include_examples "block", :contextmapper, CONTEXTMAPPER_CODE, [:png, :svg]

  it "should support contextmapper options as attributes" do
    doc = <<-eos
:contextmapper-option-antialias: false
:contextmapper-option-round-corners: true
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[contextmapper, shadows=false, separation=false, round-corners=false, scale=2.3]
----
ContextMap DDDSampleMap {
  contains CargoBookingContext
  contains VoyagePlanningContext
  contains LocationContext

  CargoBookingContext [SK]<->[SK] VoyagePlanningContext

  CargoBookingContext [D]<-[U,OHS,PL] LocationContext

  VoyagePlanningContext [D]<-[U,OHS,PL] LocationContext
}
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil
    target = b.attributes['target']
    expect(target).to match(/\.png$/)
    expect(File.exist?(target)).to be true
  end

  it "should regenerate images when options change" do
    doc = <<-eos
= Hello, PlantUML!
Doc Writer <doc@example.com>

== First Section

[contextmapper, test, png, {opts}]
----
ContextMap DDDSampleMap {
  contains CargoBookingContext
  contains VoyagePlanningContext
  contains LocationContext

  CargoBookingContext [SK]<->[SK] VoyagePlanningContext

  CargoBookingContext [D]<-[U,OHS,PL] LocationContext

  VoyagePlanningContext [D]<-[U,OHS,PL] LocationContext
}
----
    eos

    d = load_asciidoc(doc.sub('{opts}', 'shadow=false'))
    b = d.find { |bl| bl.context == :image }
    target = b.attributes['target']
    mtime1 = File.mtime(target)

    sleep 1

    d = load_asciidoc(doc.sub('{opts}', 'round-corners=true'))

    mtime2 = File.mtime(target)

    expect(mtime2).to be > mtime1
  end

  it "should support UTF-8 characters" do
    doc = <<-eos
= Test

[contextmapper]
----
ContextMap DDDSampleMap {
  contains \u00AB
  contains \u00BB
  contains \u2026

  \u00AB [SK]<->[SK] \u00BB

  \u00AB [D]<-[U,OHS,PL] \u2026

  \u00BB [D]<-[U,OHS,PL] \u2026
}
----
    eos

    d = load_asciidoc doc
    expect(d).to_not be_nil

    b = d.find { |bl| bl.context == :image }
    expect(b).to_not be_nil

    expect(b.content_model).to eq :empty

    target = b.attributes['target']
    expect(target).to_not be_nil
    expect(target).to match(/\.png$/)
    expect(File.exist?(target)).to be true

    expect(b.attributes['width']).to_not be_nil
    expect(b.attributes['height']).to_not be_nil
  end

  it "should report syntax errors" do
    doc = <<-eos
= Hello, ContextMapper!
Doc Writer <doc@example.com>

== First Section

[contextmapper,format="svg"]
----
ContextMap DDDSampleMap {
  contains CargoBookingContext
  contains VoyagePlanningContext
  contains LocationContext

  CargoBookingContext [SK]<->[SK] VoyagePlanning

  CargoBookingContext [D]<-[U,OHS,PL] LocationContext

  VoyagePlanningContext [D]<-[U,OHS,PL] LocationContext
}
----
    eos

    expect {
      load_asciidoc doc
    }.to raise_error(/Ambiguous input/i)
  end
end