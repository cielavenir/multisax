# multisax
A module which allows multiple SAX library transparently.

[![Build Status](https://travis-ci.org/cielavenir/multisax.png)](https://travis-ci.org/cielavenir/multisax) [![Code Climate](https://codeclimate.com/github/cielavenir/multisax.png)](https://codeclimate.com/github/cielavenir/multisax)

## Binary distribution
* https://rubygems.org/gems/multisax

## (Embeddable) Minimalistic Edition
* https://gist.github.com/cielavenir/7691221
  * multisax_mini.rb:  :libxml/:rexmlstream/:rexmlsax2
  * multisax_mini2.rb: :libxml/:rexmlstream

## Install
* gem install multisax
* Optional XML libraries:
* gem install ox
* gem install libxml-ruby
* gem install nokogiri

## Usage
* Please check spec/multisax.spec as an example.
* Complex usage:

```rb
require 'multisax'
listener=MultiSAX::Sax.parse(xml,Class.new{
	include MultiSAX::Callbacks
	def initialize
		@content=Hash.new{|h,k|h[k]=[]}
		@current_tag=[]
	end
	attr_reader :content

	def sax_tag_start(tag,attrs)
		@current_tag.push(tag)
	end
	def sax_tag_end(tag)
		if (t=@current_tag.pop)!=tag then raise "xml is malformed /#{t}" end
	end
	def sax_cdata(text)
		@content[@current_tag.last] << text
	end
	def sax_text(text)
		text.strip!
		@content[@current_tag.last] << text if text.size>0
	end
	def sax_comment(text)
	end
}.new)
listener.content.each{...}
```

## Contributing to multisax
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright
Copyright (c) 2013 T. Yamada under Ruby License (2-clause BSDL or Artistic).
See LICENSE.txt for further details.