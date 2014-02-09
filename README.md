# CompareEpub

[![Build Status](https://travis-ci.org/katoy/compare_epub.png?branch=master)](https://travis-ci.org/katoy/compare_epub)
[![Dependency Status](https://gemnasium.com/katoy/compare_epub.png)](https://gemnasium.com/katoy/compare_epub)
[![Coverage Status](https://coveralls.io/repos/katoy/compare_epub/badge.png?branch=master)](https://coveralls.io/r/katoy/compare_epub?branch=master)

This is a tool for compareing epub files.

これは  epub を比較するツールです。

使用例:
-------

```
  $ bin/compaare_epub data/book.epub data/book1.epub
  false
  $ ls work-diff/diff/
  ch003.xhtml.txt
  $ cat work-diff/diff/ch003.xhtml.txt
  - text:Chapter two has just begun.
  + text:Chapter two has just begun. 123
```

book.epub, bool1.epub は、 それぞれ pandoc をつかって book.txt, book1.txt から生成した epub ファイルです。  
差は diff data/book.txt data/book1.txt で確認できます。  

```
  $ diff data/book.txt data/book1.txt
  12a13,14
  > 123
  >
```

book.epub, book1.epub は epubcheck でのチェックをパスします。

```
  $ epubcheck book.epub
  Epubcheck Version 3.0.1

  Validating against EPUB version 2.0
  No errors or warnings detected.

  $ epubcheck book1.epub
  Epubcheck Version 3.0.1

  Validating against EPUB version 2.0
  No errors or warnings detected.
```


動作概要:
----------

epub ファイルを zip 解凍して、xml の  dom レベルで比較をしています。  
いくつかの要素は比較対象から除外をしています。 (作成日時など)  


## Contributing

1. Fork it ( http://github.com/<my-github-username>/compare_epub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
