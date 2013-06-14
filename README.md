= multisax

* Please check spec/multisax.spec as an example.
* Complex usage:
```ruby
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

* Optional XML libraries:
* gem install ox
* gem install libxml-ruby
* gem install nokogiri

== Contributing to multisax
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2013 cielavenir. See LICENSE.txt for
further details.
