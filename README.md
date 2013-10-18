PlayStorePrivacyCrawler
=======================

A crawler to download and parse privacy policies from Android apps on Google Play Store

Requirements
------------
* ruby 1.9.3 (install using [rvm](https://rvm.io/rvm/install))
* [Bundler](http://bundler.io/#getting-started)
* [Graphviz](http://www.graphviz.org/Download..php) (__Optional__: for generating a pdf from the dot file) 
    * On OSX:
        ```
        brew install graphviz
        ```

Install
-------
```
git clone https://github.com/Gabro/PlayStorePrivacyCrawler.git ; cd PlayStorePrivacyCrawler
bundle install
```

Usage
-----
```
ruby crawler.rb com.rovio.angrybirds
```
