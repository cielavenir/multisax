# MultiSAX: Ruby Gem to handle multiple SAX libraries
#
# Copyright (c) 2013, T. Yamada under Ruby License (2-clause BSDL or Artistic).
#
# Check LICENSE terms.
#
# Note: MIT License is also applicable if that compresses LICENSE file.

module MultiSAX
	# VERSION string
	VERSION='0.0.5'

	# The class to handle XML libraries.
	class SAX
		# constructor
		def initialize
			@parser=nil
		end
		# Library loader.
		# Arguments are list (or Array) of libraries.
		#  if list is empty or :XML, the following are searched (order by speed):
		#  :ox, :libxml, :nokogiri, :xmlparser, :rexmlstream, :rexmlsax2
		#  if list is :HTML, the following are searched (order by speed):
		#  :oxhtml, :nokogirihtml
		#  You can also specify libraries individually.
		#  If multiple selected, MultiSAX will try the libraries one by one and use the first usable one.
		def open(*list)
			return @parser if @parser
			list=[:ox,:libxml,:nokogiri,:xmlparser,:rexmlstream,:rexmlsax2] if list.size==0||list==[:XML]
			list=[:oxhtml,:nokogirihtml] if list==[:HTML]
			list.each{|e_module|
				case e_module
					when :ox,:oxhtml
						begin
							require 'ox'
							require 'stringio' #this should be standard module.
						rescue LoadError;next end
						@parser=e_module
						@saxhelper=Class.new(Ox::Sax){
							def __init__(obj)
								@obj=obj
								@saxwrapper_tag=nil
								@saxwrapper_attr={}
								self
							end
							def end_element(tag) @obj.sax_tag_end(tag.to_s) end
							def cdata(txt) @obj.sax_cdata(txt) end
							def text(txt) @obj.sax_text(txt) end
							def comment(txt) @obj.sax_comment(txt) end

							def start_element(tag)
								if @after_error
									@obj.sax_tag_start(tag.to_s,{})
									@after_error=false
								else
									# I hope provided Listener's sax_tag_start will NOT be used elsewhere.
									#alias :attrs_done :attrs_done_normal
									@saxwrapper_tag=tag
									@saxwrapper_attr={}
								end
							end
							def attr(name,str)
								@saxwrapper_attr[name.to_s]=str
							end
							def attrs_done_xmldecl
								@obj.sax_xmldecl(@saxwrapper_attr['version'],@saxwrapper_attr['encoding'],@saxwrapper_attr['standalone'])
							end
							def attrs_done_normal
								@obj.sax_tag_start(@saxwrapper_tag.to_s,@saxwrapper_attr)
							end
							def attrs_done
								@saxwrapper_tag ? attrs_done_normal : attrs_done_xmldecl
							end
							def error(s,i,j) @after_error=true if s.end_with?('closed but not opened') end
						}
						break
					when :libxml
						begin
							require 'libxml'
						rescue LoadError;next end
						@parser=e_module;break
					when :nokogiri,:nokogirihtml
						#nokogiri 1.5.x are supported on Ruby 1.8.7.
						#next if RUBY_VERSION<'1.9'
						begin
							require 'nokogiri'
						rescue LoadError;next end
						@parser=e_module
						@saxhelper=Class.new(Nokogiri::XML::SAX::Document){
							def __init__(obj)
								@obj=obj
								self
							end
							def start_element(tag,attrs) @obj.sax_tag_start(tag,attrs.is_a?(Array) ? Hash[*attrs.flatten(1)] : attrs) end
							def end_element(tag) @obj.sax_tag_end(tag) end
							def xmldecl(version,encoding,standalone) @obj.sax_xmldecl(version,encoding,standalone) end
							def characters(txt) @obj.sax_text(txt) end
							def cdata(txt) @obj.sax_cdata(txt) end
							def comment(txt) @obj.sax_comment(txt) end
						}
						break
					when :xmlparser
						begin
							require 'xml/saxdriver'
						rescue LoadError;next end
						@parser=e_module
						@saxhelper=Class.new(XMLParser){
							def __init__(obj)
								@obj=obj
								@cdata=false
								self
							end
							def startElement(tag,attrs) @obj.sax_tag_start(tag,attrs) end
							def endElement(tag) @obj.sax_tag_end(tag) end
							def comment(txt) @obj.sax_comment(txt) end
							def xmlDecl(version,encoding,standalone) @obj.sax_xmldecl(version,encoding,standalone) end
							def character(txt)
								if @cdata
									@obj.sax_cdata(txt)
								else
									@obj.sax_text(txt)
								end
							end
							def startCdata
								@cdata=true
							end
							def endCdata
								@cdata=false
							end
						}
						break
					when :rexmlstream
						begin
							require 'rexml/document'
							require 'rexml/parsers/streamparser'
							require 'rexml/streamlistener'
						rescue LoadError;next end
						@parser=e_module;break
					when :rexmlsax2
						begin
							require 'rexml/document'
							require 'rexml/parsers/sax2parser'
							require 'rexml/sax2listener'
						rescue LoadError;next end
						@parser=e_module;break
				end
			}
			return @parser
		end
		# Reset MultiSAX state so that you can re-open() another library.
		def reset() @parser=nil end
		# Returns which module is actually chosen.
		def parser() @parser end

		private
		#(private) Patches listener to accept library-specific APIs.
		def method_mapping(listener)
			#raise "MultiSAX::Sax open first" if !@parser
			case @parser
				when :libxml
					listener.instance_eval{
						extend LibXML::XML::SaxParser::Callbacks
						#alias :on_start_element_ns :sax_start_element_namespace_libxml
						alias :on_start_element :sax_tag_start
						#alias :on_end_element_ns :sax_end_element_namespace
						alias :on_end_element :sax_tag_end
						alias :on_cdata_block :sax_cdata
						alias :on_characters :sax_text
						alias :on_comment :sax_comment
						#alias :xmldecl :sax_xmldecl
					}
				when :rexmlstream
					listener.instance_eval{
						extend REXML::StreamListener
						alias :tag_start :sax_tag_start
						alias :tag_end :sax_tag_end
						alias :cdata :sax_cdata
						alias :text :sax_text
						alias :comment :sax_comment
						alias :xmldecl :sax_xmldecl
					}
				when :rexmlsax2
					listener.instance_eval{
						extend REXML::SAX2Listener
						def start_element(uri,tag,qname,attrs) sax_tag_start(qname,attrs) end
						def end_element(uri,tag,qname) sax_tag_end(qname) end
						alias :cdata :sax_cdata
						alias :characters :sax_text
						alias :comment :sax_comment
						alias :xmldecl :sax_xmldecl
					}
			end
			listener
		end

		public
		# The main parsing method.
		# Listener can be Class.new{include MultiSAX::Callbacks}.new. Returns the listener after SAX is applied.
		# If you have not called open(), this will call it using default value (all libraries).
		#  From 0.0.1, source can be IO as well as String.
		#  SAX's listeners are usually modified destructively.
		#  So instances shouldn't be provided.
		def parse(source,listener)
			if !@parser && !open
				raise "Failed to open SAX library. REXML, which is a standard Ruby module, might be also corrupted."
			end
			@listener=listener
			method_mapping(@listener)
			if source.is_a?(String)
				case @parser
					when :ox           then Ox.sax_parse(@saxhelper.new.__init__(@listener),StringIO.new(source),:convert_special=>true)
					when :oxhtml       then Ox.sax_parse(@saxhelper.new.__init__(@listener),StringIO.new(source),:convert_special=>true,:smart=>true)
					when :libxml       then parser=LibXML::XML::SaxParser.string(source);parser.callbacks=@listener;parser.parse
					when :nokogiri     then parser=Nokogiri::XML::SAX::Parser.new(@saxhelper.new.__init__(@listener));parser.parse(source)
					when :nokogirihtml then parser=Nokogiri::HTML::SAX::Parser.new(@saxhelper.new.__init__(@listener));parser.parse(source)
					when :xmlparser    then @saxhelper.new.__init__(@listener).parse(source)
					when :rexmlstream  then REXML::Parsers::StreamParser.new(source,@listener).parse
					when :rexmlsax2    then parser=REXML::Parsers::SAX2Parser.new(source);parser.listen(@listener);parser.parse
				end
			else
				case @parser
					when :ox           then Ox.sax_parse(@saxhelper.new.__init__(@listener),source,:convert_special=>true)
					when :oxhtml       then Ox.sax_parse(@saxhelper.new.__init__(@listener),source,:convert_special=>true,:smart=>true)
					when :libxml       then parser=LibXML::XML::SaxParser.io(source);parser.callbacks=@listener;parser.parse
					when :nokogiri     then parser=Nokogiri::XML::SAX::Parser.new(@saxhelper.new.__init__(@listener));parser.parse(source)
					when :nokogirihtml then parser=Nokogiri::HTML::SAX::Parser.new(@saxhelper.new.__init__(@listener));parser.parse(source.read) # fixme
					when :xmlparser    then @saxhelper.new.__init__(@listener).parse(source)
					when :rexmlstream  then REXML::Parsers::StreamParser.new(source,@listener).parse
					when :rexmlsax2    then parser=REXML::Parsers::SAX2Parser.new(source);parser.listen(@listener);parser.parse
				end
			end
			@listener
		end

		# Parses file as XML. Error handling might be changed in the future.
		def parsefile(filename,listener)
			#begin
				return nil unless FileTest::readable?(filename)
				File.open(filename,'rb'){|f|
					parse(f,listener)
				}
			#rescue
			#	return nil
			#end
			@listener
		end
	end

	# This class provides singleton interface to MultiSAX::SAX.
	class Sax
		@@multisax_singleton=SAX.new
		# MultiSAX::SAX#open
		def self.open(*list) @@multisax_singleton.open(*list) end
		# MultiSAX::SAX#reset
		def self.reset() @@multisax_singleton.reset() end
		# MultiSAX::SAX#parser
		def self.parser() @@multisax_singleton.parser() end
		# MultiSAX::SAX#parse
		def self.parse(source,listener) @@multisax_singleton.parse(source,listener) end
		# MultiSAX::SAX#parsefile
		def self.parsefile(filename,listener) @@multisax_singleton.parsefile(filename,listener) end
	end

	# MultiSAX callbacks.
	# MultiSAX::SAX listener should include this module.
	module Callbacks
		# Start of tag
		def sax_tag_start(tag,attrs) end
		# End of tag
		def sax_tag_end(tag) end
		# Comment
		def sax_comment(text) end
		# CDATA
		def sax_cdata(text) end
		# Text
		def sax_text(text) end
		# XML declaration (not available if parser is :libxml)
		def sax_xmldecl(version,encoding,standalone) end
	end
end
