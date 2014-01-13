require 'rspec'
RSpec.configure{|config|
	config.color=true
}

require 'stringio'
if RUBY_VERSION<'1.9' #gee, :rexmlsax2 on Ruby 1.8 dislikes StringIO.
	class StringIO
		def stat
			Class.new{
				def pipe?() return false end
			}.new
		end
	end
end

if !defined?(RUBY_ENGINE)||RUBY_ENGINE=='ruby'
	require 'simplecov'
	SimpleCov.start do
		add_filter 'spec'
	end
end

require File.expand_path(File.dirname(__FILE__)+'/../lib/multisax')