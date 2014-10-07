source "http://rubygems.org"

platforms :rbx do
	gem 'rubysl'
	gem 'racc' # nokogiri
end

group :test do
	if RUBY_VERSION>='1.9'
		gem 'nokogiri', '~> 1.6.0' # Used workaround here; actually 1.7.x should also be OK...
	else
		gem 'nokogiri', '~> 1.5.0'
	end
	if RUBY_VERSION>='1.9.3'
		gem 'oga'
	end
	platforms :ruby do
		gem 'libxml-ruby'
		gem 'ox'
		gem 'xmlparser'
	end
end

group :development, :test do
	if RUBY_VERSION<'1.9'
		gem 'mime-types', '~> 1.0'
		gem 'rest-client', '~> 1.6.0'
	end
	gem 'bundler', '>= 1.0'
	gem 'rake'
	gem 'rspec'
	gem 'simplecov'
	gem 'coveralls', :require => false
end
