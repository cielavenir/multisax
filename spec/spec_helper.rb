$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'stringio'
require 'multisax'

if RUBY_VERSION<'1.9' #gee, StringIO needs to be hacked.
	class StringIO
		def stat
			Class.new{
				def pipe?() return false end
			}.new
		end
	end
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure{|config|
	config.color=true
}
