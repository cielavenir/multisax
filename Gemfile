source "http://rubygems.org"

platforms :rbx do
	gem 'rubysl'
	gem 'racc' # nokogiri
end

#This clause is broken. So, please do not use bundle install if you are not developing multisax.
group :test do
	#if RUBY_VERSION>='1.9'
	#	gem 'nokogiri'
	#else
		gem 'nokogiri', '~> 1.5.0'
	#end
	platforms :ruby do
		gem 'libxml-ruby'
		gem 'ox'
	end
end

group :development, :test do
	gem 'bundler', '>= 1.0'
	gem 'rake'
	gem 'rspec'
end
