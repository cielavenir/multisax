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
  gem "rspec"
  gem "bundler"
end
