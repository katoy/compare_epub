# -*- coding: utf-8 -*-

require 'rubygems'
require 'rspec'

require 'pry'

require 'simplecov'
require 'coveralls'
require 'simplecov-rcov'
require 'open3'

Coveralls.wear!

# simplecov, rcov, coderails の３通りの書式のレポートを生成する。
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::RcovFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

SimpleCov.start do
  add_filter 'spec'
end

require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'compare_epub.rb')

require 'stringio'

RSpec.configure do |config|

  include CompareEpub

  config.expect_with :rspec do |c|
    c.syntax = :expect    # disables `should`
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    result
  end

end
