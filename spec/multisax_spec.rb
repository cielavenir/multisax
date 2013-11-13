require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class MultiSAXTester
	include MultiSAX::Callbacks
	def initialize
		@result=[]
		@attrib=nil
	end
	def sax_tag_start(tag,attrs)
		@result<<tag
		@attrib=attrs['foo'] if tag=='sax'
	end
	def sax_tag_end(tag)
		@result<<tag
	end
	def sax_text(text)
		text.strip!
		@result<<text if text.size>0
	end
	def sax_xmldecl(version,encoding,standalone)
		@xmlencoding=encoding
	end
	attr_reader :result,:attrib,:xmlencoding
end
input_xml=<<"EOM"
<?xml version="1.0" encoding="UTF-8"?>
<hello><sax foo="bar">world</sax></hello>
EOM
answer=['hello','sax','world','sax','hello']

describe "MultiSAX::Sax.parse (String)" do
	it "fails on :unknown" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:unknown).should be_false
	end
	it "uses :rexmlstream" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:rexmlstream)
		MultiSAX::Sax.parser.should eq :rexmlstream
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq answer
		listener.attrib.should eq 'bar'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :rexmlsax2" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:rexmlsax2)
		MultiSAX::Sax.parser.should eq :rexmlsax2
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq answer
		listener.attrib.should eq 'bar'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :ox" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:ox)
		MultiSAX::Sax.parser.should eq :ox
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq answer
		listener.attrib.should eq 'bar'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :libxml" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:libxml)
		MultiSAX::Sax.parser.should eq :libxml
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq answer
		listener.attrib.should eq 'bar'
		#listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :nokogiri" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:nokogiri)
		MultiSAX::Sax.parser.should eq :nokogiri
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq answer
		listener.attrib.should eq 'bar'
		listener.xmlencoding.should eq 'UTF-8'
	end
end

describe "MultiSAX::Sax.parse (IO)" do
	it "uses :rexmlstream" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:rexmlstream)
		MultiSAX::Sax.parser.should eq :rexmlstream
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq answer
		listener.attrib.should eq 'bar'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :rexmlsax2" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:rexmlsax2)
		MultiSAX::Sax.parser.should eq :rexmlsax2
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq answer
		listener.attrib.should eq 'bar'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :ox" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:ox)
		MultiSAX::Sax.parser.should eq :ox
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq answer
		listener.attrib.should eq 'bar'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :libxml" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:libxml)
		MultiSAX::Sax.parser.should eq :libxml
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq answer
		listener.attrib.should eq 'bar'
		#listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :nokogiri" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:nokogiri)
		MultiSAX::Sax.parser.should eq :nokogiri
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq answer
		listener.attrib.should eq 'bar'
		listener.xmlencoding.should eq 'UTF-8'
	end
end
