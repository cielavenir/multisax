require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class MultiSAXTester
	include MultiSAX::Callbacks
	def initialize
		@result=[]
	end
	def sax_tag_start(tag,attrs)
		@result<<tag
	end
	def sax_tag_end(tag)
		@result<<tag
	end
	def sax_text(text)
		text.strip!
		@result<<text if text.size>0
	end
	attr_reader :result
end
input_xml=<<"EOM"
<?xml version="1.0" encoding="utf-8"?>
<hello><sax>world</sax></hello>
EOM
answer=['hello','sax','world','sax','hello']

describe "Multisax" do
	it "rexmlstream" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:rexmlstream)
		MultiSAX::Sax.parse(input_xml,MultiSAXTester.new).result.should eq answer
	end
	it "rexmlsax2" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:rexmlsax2)
		MultiSAX::Sax.parse(input_xml,MultiSAXTester.new).result.should eq answer
	end
	it "ox" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:ox)
		MultiSAX::Sax.parse(input_xml,MultiSAXTester.new).result.should eq answer
	end
	it "libxml" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:libxml)
		MultiSAX::Sax.parse(input_xml,MultiSAXTester.new).result.should eq answer
	end
	it "nokogiri" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:nokogiri)
		MultiSAX::Sax.parse(input_xml,MultiSAXTester.new).result.should eq answer
	end
end
