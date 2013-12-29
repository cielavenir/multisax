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

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end

require File.expand_path('../../lib/multisax',__FILE__)
