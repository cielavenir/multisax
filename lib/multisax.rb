# MultiSAX: Ruby Gem to handle multiple SAX libraries
#
# Copyright (c) 2013, T. Yamada under Ruby License (2-clause BSDL or Artistic).
#
# Check LICENSE terms.
#
# Note: MIT License is also applicable if that compresses LICENSE file.

module MultiSAX
	#VERSION=''

	# The class to handle XML libraries.
	class Sax
		@@parser=nil
		@@saxmodule=nil
		# Library loader.
		# Arguments are list (or Array) of libraries.
		#  Currently the following are supported (order by speed):
		#  :ox, :libxml, :nokogiri, :rexmlstream, :rexmlsax2
		#  If multiple selected, MultiSAX will try the libraries one by one and use the first usable one.
		def self.open(*list)
			return @@parser if @@parser
			list=[:ox,:libxml,:nokogiri,:rexmlstream,:rexmlsax2] if list.size==0
			list=list.first if list.first.is_a?(Array)
			list.each{|e_module|
				case e_module
					when :ox
						begin
							require 'ox'
							require 'stringio' #this should be standard module.
						rescue LoadError;next end
						@@parser=e_module
						methods=Ox::Sax.private_instance_methods(false)-Class.private_instance_methods(false)
						methods-=[:value,:attr_value]
						@@saxmodule=Module.new{
							methods.each{|e|define_method(e){|*a|}}
						}
						break
					when :libxml
						begin
							require 'libxml'
						rescue LoadError;next end
						@@parser=e_module;break
					when :nokogiri
						begin
							require 'nokogiri'
						rescue LoadError;next end
						@@parser=e_module
						methods=Nokogiri::XML::SAX::Document.instance_methods(false)-Class.instance_methods(false)
						methods-=[:start_element_namespace,:end_element_namespace]
						@@saxmodule=Module.new{
							methods.each{|e|define_method(e){|*a|}}
						}
						break
					when :rexmlstream
						begin
							require 'rexml/document'
							require 'rexml/parsers/streamparser'
							require 'rexml/streamlistener'
						rescue LoadError;next end
						@@parser=e_module;break
					when :rexmlsax2
						begin
							require 'rexml/document'
							require 'rexml/parsers/sax2parser'
							require 'rexml/sax2listener'
						rescue LoadError;next end
						@@parser=e_module;break
				end
			}
			return @@parser
		end
		# Reset MultiSAX state so that you can re-open() another library.
		def self.reset() @@parser=nil;@@saxmodule=nil end
		# Returns which module is actually chosen.
		def self.parser() @@parser end

		#--
		#def initialize(listener)
		#++

		# The main parsing method.
		# Listener can be Class.new{include MultiSAX::Callbacks}.new. Returns the listener after SAX is applied.
		# If you have not called open(), this will call it using default value (all libraries).
		#  SAX's listeners are usually modified destructively.
		#  So instances shouldn't be provided.
		def self.parse(body,listener)
			#self.class.open if !@@parser
			self.open if !@@parser
			raise "Failed to open SAX library. REXML, which is a standard Ruby module, might be also corrupted." if !@@parser
			@listener=listener

			#Here comes method mapping.
			case @@parser
				when :ox
					@listener.instance_eval{
						extend @@saxmodule
						@saxwrapper_attr=[]
						def start_element(tag)
							# I hope provided Listener's sax_tag_start will NOT be used elsewhere.
							alias :attrs_done :attrs_done_normal
							@saxwrapper_tag=tag
							@saxwrapper_attr=[]
						end
						# These "instance methods" are actually injected to listener class using instance_eval.
						# i.e. not APIs. You cannot call these methods from outside.
						def attr(name,str)
							@saxwrapper_attr<<[name,str]
						end
						#--
						#alias :attr_value :attr
						#++
						def attrs_done_xmldecl
							version=@saxwrapper_attr.assoc(:version)
							version&&=version[1]
							encoding=@saxwrapper_attr.assoc(:encoding)
							encoding&&=encoding[1]
							standalone=@saxwrapper_attr.assoc(:standalone)
							standalone&&=standalone[1]
							sax_xmldecl(version,encoding,standalone)
						end
						def attrs_done_normal
							sax_tag_start(@saxwrapper_tag.to_s,@saxwrapper_attr)
						end
						alias :attrs_done :attrs_done_xmldecl
						def end_element(tag) sax_tag_end(tag.to_s) end
						alias :cdata :sax_cdata
						alias :text :sax_text
						#--
						#alias :value :sax_text
						#++
						alias :comment :sax_comment
					}
				when :libxml
					@listener.instance_eval{
						extend LibXML::XML::SaxParser::Callbacks
						alias :on_start_element :sax_tag_start
						alias :on_end_element :sax_tag_end
						alias :on_cdata_block :sax_cdata
						alias :on_characters :sax_text
						alias :on_comment :sax_comment
						#alias :xmldecl :sax_xmldecl
					}
				when :nokogiri
					@listener.instance_eval{
						extend @@saxmodule
						alias :start_element_namespace :sax_start_element_namespace
						alias :start_element :sax_tag_start
						alias :end_element_namespace :sax_end_element_namespace
						alias :end_element :sax_tag_end
						alias :cdata_block :sax_cdata
						alias :characters :sax_text
						alias :comment :sax_comment
						alias :xmldecl :sax_xmldecl
					}
				when :rexmlstream
					@listener.instance_eval{
						extend REXML::StreamListener
						alias :tag_start :sax_tag_start
						alias :tag_end :sax_tag_end
						alias :cdata :sax_cdata
						alias :text :sax_text
						alias :comment :sax_comment
						alias :xmldecl :sax_xmldecl
					}
				when :rexmlsax2
					@listener.instance_eval{
						extend REXML::SAX2Listener
						def start_element(uri,tag,qname,attrs) sax_tag_start(tag,attrs) end
						def end_element(uri,tag,qname) sax_tag_end(tag) end
						alias :cdata :sax_cdata
						alias :characters :sax_text
						alias :comment :sax_comment
						alias :xmldecl :sax_xmldecl
					}
			end
		#end
		#def parse(body)
			#Here comes parsing mapping.
			case @@parser
				when :ox          then Ox.sax_parse(@listener,StringIO.new(body),:convert_special=>true)
				when :libxml      then parser=LibXML::XML::SaxParser.string(body);parser.callbacks=@listener;parser.parse
				when :nokogiri    then parser=Nokogiri::XML::SAX::Parser.new(@listener);parser.parse(body)
				when :rexmlstream then REXML::Parsers::StreamParser.new(body,@listener).parse
				when :rexmlsax2   then parser=REXML::Parsers::SAX2Parser.new(body);parser.listen(@listener);parser.parse
			end
			@listener
		end
	end

	# MultiSAX callbacks.
	# MultiSAX::Sax listener should include this module.
	module Callbacks
		# Cited from Nokogiri to convert Nokogiri::XML::SAX::Document into module.
		#  https://github.com/sparklemotion/nokogiri/blob/master/lib/nokogiri/xml/sax/document.rb
		def sax_start_element_namespace name, attrs = [], prefix = nil, uri = nil, ns = []
			# Deal with SAX v1 interface
			name = [prefix, name].compact.join(':')
			attributes = ns.map { |ns_prefix,ns_uri|
				[['xmlns', ns_prefix].compact.join(':'), ns_uri]
			} + attrs.map { |attr|
				[[attr.prefix, attr.localname].compact.join(':'), attr.value]
			}
			sax_tag_start name, attributes
        end
		def sax_end_element_namespace name, prefix = nil, uri = nil
			# Deal with SAX v1 interface
			sax_tag_end [prefix, name].compact.join(':')
		end
		def sax_tag_start(tag,attr) end
		def sax_tag_end(tag) end
		def sax_comment(text) end
		def sax_cdata(text) end
		def sax_text(text) end
		def sax_xmldecl(version,encoding,standalone) end
	end
end
