require File.expand_path(File.dirname(__FILE__)+'/spec_helper')

class MultiSAXTester
	include MultiSAX::Callbacks
	def initialize
		@result=[]
		@attrib=nil
	end
	def sax_tag_start(tag,attrs)
		@result<<tag
		@attrib=attrs['class'] if tag=='span'
	end
	def sax_tag_end(tag)
		@result<<tag
	end
	def sax_text(text)
		text.strip!
		@result<<text if text.size>0
	end
	def sax_cdata(text)
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
<ns xmlns:zzz="http://example.com/">
<zzz:hello><![CDATA[sax$]]><span class="foo">world</span></zzz:hello>
</ns>
EOM
xml_answer=['ns','zzz:hello','sax$','span','world','span','zzz:hello','ns']

describe "[XML] MultiSAX::Sax.parse(String)" do
	it "fails on :unknown" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:unknown).should be_falsey
	end
	it "uses :rexmlstream" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:rexmlstream)
		MultiSAX::Sax.parser.should eq :rexmlstream
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :rexmlsax2" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:rexmlsax2)
		MultiSAX::Sax.parser.should eq :rexmlsax2
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :ox" do
		pending 'ox is not supported by jruby' if defined?(RUBY_ENGINE)&&RUBY_ENGINE=='jruby'
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:ox)
		MultiSAX::Sax.parser.should eq :ox
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :libxml" do
		pending 'libxml is not supported by jruby' if defined?(RUBY_ENGINE)&&RUBY_ENGINE=='jruby'
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:libxml)
		MultiSAX::Sax.parser.should eq :libxml
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		#listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :nokogiri" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:nokogiri)
		MultiSAX::Sax.parser.should eq :nokogiri
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :oga" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:oga)
		MultiSAX::Sax.parser.should eq :oga
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :xmlparser" do
		pending 'xmlparser is not supported by jruby' if defined?(RUBY_ENGINE)&&RUBY_ENGINE=='jruby'
		pending 'xmlparser is not supported by rubinius' if defined?(RUBY_ENGINE)&&RUBY_ENGINE=='rbx'
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:xmlparser)
		MultiSAX::Sax.parser.should eq :xmlparser
		listener=MultiSAX::Sax.parse(input_xml,MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
end

describe "[XML] MultiSAX::Sax.parse(IO)" do
	it "uses :rexmlstream" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:rexmlstream)
		MultiSAX::Sax.parser.should eq :rexmlstream
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :rexmlsax2" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:rexmlsax2)
		MultiSAX::Sax.parser.should eq :rexmlsax2
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :ox" do
		pending 'ox is not supported by jruby' if defined?(RUBY_ENGINE)&&RUBY_ENGINE=='jruby'
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:ox)
		MultiSAX::Sax.parser.should eq :ox
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :libxml" do
		pending 'libxml is not supported by jruby' if defined?(RUBY_ENGINE)&&RUBY_ENGINE=='jruby'
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:libxml)
		MultiSAX::Sax.parser.should eq :libxml
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		#listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :nokogiri" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:nokogiri)
		MultiSAX::Sax.parser.should eq :nokogiri
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :oga" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:oga)
		MultiSAX::Sax.parser.should eq :oga
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
	it "uses :xmlparser" do
		pending 'xmlparser is not supported by jruby' if defined?(RUBY_ENGINE)&&RUBY_ENGINE=='jruby'
		pending 'xmlparser is not supported by rubinius' if defined?(RUBY_ENGINE)&&RUBY_ENGINE=='rbx'
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:xmlparser)
		MultiSAX::Sax.parser.should eq :xmlparser
		listener=MultiSAX::Sax.parse(StringIO.new(input_xml),MultiSAXTester.new)
		listener.result.should eq xml_answer
		listener.attrib.should eq 'foo'
		listener.xmlencoding.should eq 'UTF-8'
	end
end

# broken intentionally
# nokogiri-java wants head tag...
input_html=<<"EOM"
<html>
<head></head>
<body>
<span class="foo">hello
</body>
</html>
EOM
html_answer=['html','head','head','body','span','hello','span','body','html']

describe "[HTML] MultiSAX::Sax.parse(String)" do
	it "uses :oxhtml" do
		pending 'ox is not supported by jruby' if defined?(RUBY_ENGINE)&&RUBY_ENGINE=='jruby'
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:oxhtml)
		MultiSAX::Sax.parser.should eq :oxhtml
		listener=MultiSAX::Sax.parse(input_html,MultiSAXTester.new)
		listener.result.should eq html_answer
		listener.attrib.should eq 'foo'
	end
	it "uses :nokogirihtml" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:nokogirihtml)
		MultiSAX::Sax.parser.should eq :nokogirihtml
		listener=MultiSAX::Sax.parse(input_html,MultiSAXTester.new)
		listener.result.should eq html_answer
		listener.attrib.should eq 'foo'
	end
	it "uses :ogahtml" do
		pending 'oga does not like broken HTML'
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:ogahtml)
		MultiSAX::Sax.parser.should eq :ogahtml
		listener=MultiSAX::Sax.parse(input_html,MultiSAXTester.new)
		listener.result.should eq html_answer
		listener.attrib.should eq 'foo'
	end
end

describe "[HTML] MultiSAX::Sax.parse(IO)" do
	it "uses :oxhtml" do
		pending 'ox is not supported by jruby' if defined?(RUBY_ENGINE)&&RUBY_ENGINE=='jruby'
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:oxhtml)
		MultiSAX::Sax.parser.should eq :oxhtml
		listener=MultiSAX::Sax.parse(StringIO.new(input_html),MultiSAXTester.new)
		listener.result.should eq html_answer
		listener.attrib.should eq 'foo'
	end
	it "uses :nokogirihtml" do
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:nokogirihtml)
		MultiSAX::Sax.parser.should eq :nokogirihtml
		listener=MultiSAX::Sax.parse(StringIO.new(input_html),MultiSAXTester.new)
		listener.result.should eq html_answer
		listener.attrib.should eq 'foo'
	end
	it "uses :ogahtml" do
		pending 'oga does not like broken HTML'
		MultiSAX::Sax.reset
		MultiSAX::Sax.open(:ogahtml)
		MultiSAX::Sax.parser.should eq :ogahtml
		listener=MultiSAX::Sax.parse(StringIO.new(input_html),MultiSAXTester.new)
		listener.result.should eq html_answer
		listener.attrib.should eq 'foo'
	end
end
