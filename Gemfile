source "http://rubygems.org"

group :test do
	gem 'libxml-ruby'
	if RUBY_VERSION>='1.9'
		gem 'nokogiri'
	else
		gem 'nokogiri', '~> 1.5.0'
	end
	gem 'ox'
end

group :development, :test do
	gem 'bundler', '>= 1.0'
	gem 'rake'
	gem 'rspec'
end
