## Xerces-Ruby support

From 0.0.6.1, multisax supports Xerces-Ruby unofficially. Official support won't be provided unless it is relicensed under permissive(BSD/MIT) or weak-copyleft(MPL) licenses.

Due to license issue, in multisax, you need to `MultiSAX::Sax.open(:xerces)` or `MultiSAX::Sax.open(*MultiSAX::XML_PARSERS_INSTALLABLE+[:xerces]+MultiSAX::XML_PARSERS_DEFAULT)` explicitly.

Here is the instruction to activate Xerces-Ruby.

----
- Install Xerces-C
  - OSX
      - MacPorts: `sudo port install xercesc`
      - Homebrew: `brew install xerces-c`
  - Debian: `sudo apt-get install libxerces-c-dev`
- Download and extract [xerces-ruby](http://www.geocities.co.jp/SiliconValley-SanJose/9156/xerces-ruby.html)
- Download [xerces-ruby.patch](https://gist.github.com/cielavenir/8401975)
- Convert SAXParse.cpp's charcode
  - `cd /path/to/xerces-ruby/`
  - `nkf --in-place -w SAXParse.cpp`
  - `nkf --in-place -w RubyDocumentHandler.cpp`
  - `nkf --in-place -w RubyDocumentHandler.hpp`
- Apply patch
  - `patch < xerces-ruby.patch`
- Run extconf.rb
  - `ruby extconf.rb --with-opt-dir=/opt/local`
- `make`
- Install libraries
  - `make install`
  - `sudo cp Xerces.rb  /Library/Ruby/Site/2.0.0/`
- Now you can `require 'Xerces'` in your Ruby script.

- Please note currently Xerces-Ruby cannot distinguish cdata and text, so both sax_cdata and sax_text are called. I (ciel) am NOT going to fix it.

- coverall.io includes :nocov: region as missing, resulting in low coverage, meh...
