source "http://rubygems.org"

platforms :rbx do
	gem 'rubysl'
end

group :test do
	#if RUBY_VERSION>='1.9'
	#	gem 'nokogiri'
	#else
		#bah. So, please do not use bundle install if you are not developing multisax.
		gem 'nokogiri', '~> 1.5.0'
	#end
	if !defined?(RUBY_ENGINE)||RUBY_ENGINE!='jruby'
		gem 'libxml-ruby'
		gem 'ox'
	end
end

group :development, :test do
	gem 'bundler', '>= 1.0'
	gem 'rake'
	gem 'rspec'
end
