require 'rspec'
RSpec.configure{|config|
	config.color=true
}

require 'stringio'
if RUBY_VERSION<'1.9' #gee, StringIO needs to be hacked.
	class StringIO
		def stat
			Class.new{
				def pipe?() return false end
			}.new
		end
	end
end

begin
	require 'simplecov'
	SimpleCov.start do
		add_filter 'spec'
	end
rescue LoadError # kill simplecov feature on rbx...
end

require File.expand_path('../../lib/multisax',__FILE__)
