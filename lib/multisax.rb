# MultiSAX: Ruby Gem to handle multiple SAX libraries
#
# Copyright (c) 2013, T. Yamada under Ruby License (2-clause BSDL or Artistic).
#
# Check LICENSE terms.
#
# Note: MIT License is also applicable if that compresses LICENSE file.

module MultiSAX
	# VERSION string
	VERSION='0.0.3'

	# The class to handle XML libraries.
	class SAX
		@parser=nil
		@saxmodule=nil
		# Library loader.
		# Arguments are list (or Array) of libraries.
		#  if list is empty or :XML, the following are searched (order by speed):
		#  :ox, :libxml, :nokogiri, :rexmlstream, :rexmlsax2
		#  if list is :HTML, the following are searched (order by speed):
		#  :oxhtml, :nokogirihtml
		#  You can also specify libraries individually.
		#  If multiple selected, MultiSAX will try the libraries one by one and use the first usable one.
		def open(*list)
			return @parser if @parser
			list=[:ox,:libxml,:nokogiri,:rexmlstream,:rexmlsax2] if list.size==0||list==[:XML]
			list=[:oxhtml,:nokogirihtml] if list==[:HTML]
			list.each{|e_module|
				case e_module
					when :ox,:oxhtml
						#next if RUBY_VERSION<'1.9'
						begin
							require 'ox'
							require 'stringio' #this should be standard module.
						rescue LoadError;next end
						@parser=e_module
						methods=Ox::Sax.private_instance_methods(false)-Class.private_instance_methods(false)
						if methods[0].is_a?(String) #Hack for 1.8.x
							methods-=['value','attr_value']
						else
							methods-=[:value,:attr_value]
						end
						@saxmodule=Module.new{
							methods.each{|e|define_method(e){|*args|}}
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
						methods=Nokogiri::XML::SAX::Document.instance_methods(false)-Class.instance_methods(false)
						if methods[0].is_a?(String) #Hack for 1.8.x
							methods-=['start_element_namespace','end_element_namespace']
						else
							methods-=[:start_element_namespace,:end_element_namespace]
						end
						@saxmodule=Module.new{
							methods.each{|e|define_method(e){|*args|}}
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
		def reset() @parser=nil;@saxmodule=nil end
		# Returns which module is actually chosen.
		def parser() @parser end

		private
		#(private) Patches listener to accept library-specific APIs.
		def method_mapping(listener)
			#raise "MultiSAX::Sax open first" if !@parser
			case @parser
				when :ox,:oxhtml
					saxmodule=@saxmodule
					listener.instance_eval{
						extend saxmodule
						@saxwrapper_tag=nil
						@saxwrapper_attr={}
						def start_element(tag)
							if @after_error
								sax_tag_start(tag.to_s,{})
								@after_error=false
							else
								# I hope provided Listener's sax_tag_start will NOT be used elsewhere.
								#alias :attrs_done :attrs_done_normal
								@saxwrapper_tag=tag
								@saxwrapper_attr={}
							end
						end
						# These "instance methods" are actually injected to listener class using instance_eval.
						# i.e. not APIs. You cannot call these methods from outside.
						def attr(name,str)
							@saxwrapper_attr[name.to_s]=str
						end
						#--
						#alias :attr_value :attr
						#++
						def attrs_done_xmldecl
							sax_xmldecl(@saxwrapper_attr['version'],@saxwrapper_attr['encoding'],@saxwrapper_attr['standalone'])
						end
						def attrs_done_normal
							sax_tag_start(@saxwrapper_tag.to_s,@saxwrapper_attr)
						end
						#alias :attrs_done :attrs_done_xmldecl
						def attrs_done
							@saxwrapper_tag ? attrs_done_normal : attrs_done_xmldecl
						end
						def error(s,i,j) @after_error=true if s.end_with?('closed but not opened') end
						def end_element(tag) sax_tag_end(tag.to_s) end
						alias :cdata :sax_cdata
						alias :text :sax_text
						#--
						#alias :value :sax_text
						#++
						alias :comment :sax_comment
					}
				when :libxml
					listener.instance_eval{
						extend LibXML::XML::SaxParser::Callbacks
						alias :on_start_element_ns :sax_start_element_namespace_libxml
						#alias :on_start_element :sax_tag_start
						alias :on_end_element_ns :sax_end_element_namespace
						#alias :on_end_element :sax_tag_end
						alias :on_cdata_block :sax_cdata
						alias :on_characters :sax_text
						alias :on_comment :sax_comment
						#alias :xmldecl :sax_xmldecl
					}
				when :nokogiri,:nokogirihtml
					saxmodule=@saxmodule
					listener.instance_eval{
						extend saxmodule
						alias :start_element_namespace :sax_start_element_namespace_nokogiri
						def start_element(tag,attrs) sax_tag_start(tag,attrs.is_a?(Array) ? Hash[*attrs.flatten(1)] : attrs) end
						alias :end_element_namespace :sax_end_element_namespace
						alias :end_element :sax_tag_end
						alias :cdata_block :sax_cdata
						alias :characters :sax_text
						alias :comment :sax_comment
						alias :xmldecl :sax_xmldecl
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
					when :ox           then Ox.sax_parse(@listener,StringIO.new(source),:convert_special=>true)
					when :oxhtml       then Ox.sax_parse(@listener,StringIO.new(source),:convert_special=>true,:smart=>true)
					when :libxml       then parser=LibXML::XML::SaxParser.string(source);parser.callbacks=@listener;parser.parse
					when :nokogiri     then parser=Nokogiri::XML::SAX::Parser.new(@listener);parser.parse(source)
					when :nokogirihtml then parser=Nokogiri::HTML::SAX::Parser.new(@listener);parser.parse(source)
					when :rexmlstream  then REXML::Parsers::StreamParser.new(source,@listener).parse
					when :rexmlsax2    then parser=REXML::Parsers::SAX2Parser.new(source);parser.listen(@listener);parser.parse
				end
			else
				case @parser
					when :ox           then Ox.sax_parse(@listener,source,:convert_special=>true)
					when :oxhtml       then Ox.sax_parse(@listener,source,:convert_special=>true,:smart=>true)
					when :libxml       then parser=LibXML::XML::SaxParser.io(source);parser.callbacks=@listener;parser.parse
					when :nokogiri     then parser=Nokogiri::XML::SAX::Parser.new(@listener);parser.parse(source)
					when :nokogirihtml then parser=Nokogiri::HTML::SAX::Parser.new(@listener);parser.parse(source.read) # fixme
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
		# Cited from Nokogiri to convert Nokogiri::XML::SAX::Document into module.
		#  https://github.com/sparklemotion/nokogiri/blob/master/lib/nokogiri/xml/sax/document.rb
		def sax_start_element_namespace_nokogiri name, attrs = [], prefix = nil, uri = nil, ns = []
			# Deal with SAX v1 interface
			name = [prefix, name].compact.join(':')
			# modified in 0.0.2
			attributes = {}
			ns.each{|ns_prefix,ns_uri|
				attributes[['xmlns', ns_prefix].compact.join(':')]=ns_uri
			}
			attrs.each{|attr|
				attributes[[attr.prefix, attr.localname].compact.join(':')]=attr.value
			}
			sax_tag_start name, attributes
        end
		# libxml namespace handler
		def sax_start_element_namespace_libxml name, attrs, prefix = nil, uri = nil, ns = []
			# Deal with SAX v1 interface
			name = [prefix, name].compact.join(':')
			# modified in 0.0.2
			attributes = {}
			ns.each{|ns_prefix,ns_uri|
				attributes[['xmlns', ns_prefix].compact.join(':')]=ns_uri
			}
			attrs.each{|k,v|
				attributes[k]=v
			}
			sax_tag_start name, attributes
        end
		# Cited from Nokogiri
		def sax_end_element_namespace name, prefix = nil, uri = nil
			# Deal with SAX v1 interface
			sax_tag_end [prefix, name].compact.join(':')
		end
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
