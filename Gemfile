source "http://rubygems.org"

platforms :rbx do
	gem 'rubysl'
end

group :test do
	gem 'libxml-ruby'
	#if RUBY_VERSION>='1.9'
	#	gem 'nokogiri'
	#else
		gem 'nokogiri', '~> 1.5.0' #bah. So, please do not use bundle install if you are not developing multisax.
	#end
	gem 'ox'
end

group :development, :test do
	gem 'bundler', '>= 1.0'
	gem 'rake'
	gem 'rspec'
end
