source "http://rubygems.org"

group :optional do
	gem 'libxml-ruby', :require=>nil
	if RUBY_VERSION<'1.9'
		gem 'nokogiri', '~> 1.5.0', :require=>nil
	else
		gem 'nokogiri', :require=>nil
	end
	gem 'ox', :require=>nil
end

group :development do
  gem "rspec", ">= 2.8.0"
  gem "rdoc", ">= 3.12"
  gem "bundler", ">= 1.0.0"
  gem "jeweler", ">= 1.8.4"
end
