# ChangeLog

## 0.0.7.1 (2015 Nov 24)
- Forgot to add date to changelog

## 0.0.7 (2015 Nov 24)
- Update oga wrapper.

## 0.0.6 (2014 Nov 19)
- Now supports oga >= 0.2.0.

## 0.0.5 (2014 Oct 7)
- Added oga gem support (Ruby 1.9.x or later required).
- Integrated Coverall.

## 0.0.4.2 (2014 Jan 14)
- Fixed regression in parsefile().

## 0.0.4.1 (2014 Jan 14)
- Fixed small stuff.

## 0.0.4 (2014 Jan 13)
- Integrated travis. Now Ruby/Rubinius/jruby supports are assured.
- Added xmlparser (expat bindings) gem support.

## 0.0.3 (2013 Nov 14)
- Fixed namespace handling.
- Now you can also select :oxhtml to parse HTML.
- Added shortcut :XML and :HTML.
- sax_tag_start()'s attrs is assured to be a Hash.
- Refined spec.

## 0.0.2 (2013 Nov 13)
- Now you can create an instance of MultiSAX::SAX.
  - Please note that passed class to MultiSAX is still modified directly.
  - So only MultiSAX::SAX instances are thread-safe.
  - MultiSAX::Sax is now an instance of MultiSAX::SAX (this is backward-compatible).
- You can specify :nokogirihtml explicitly to parse HTML.
- Fixed attrs with Ox (now String is passed, not Symbol)
- Moved to Bundler rather than Jeweler.

## 0.0.1 (2013 Jul 8)
- Added ChangeLog.
- Added Ruby 1.8.7 support.
  - Might work on lower version, but not guaranteed.
  - JRuby etc's supports depend on "require successfulness".
  - Nokogiri is supported up to 1.5.x on Ruby 1.8.x.
- MultiSAX::Sax.parse supports IO.
  - rexmlsax2's stringio support is limited on Ruby 1.8.x. Be careful.
  - Unless you directly specifies it, usually rexmlstream is selected.
- Added MultiSAX::Sax.parsefile().

## 0.0.0.5 (2013 Jun 21)
- Added a test case.

## 0.0.0.4 (2013 Jun 15)
- Provided rdoc.

## 0.0.0.3 (2013 Jun 14)
- Fixed @@parser getter.

## 0.0.0.2 (2013 Jun 14)
- Fixed Rakefile.

## 0.0.0.1 (2013 Jun 14)
- First release.
