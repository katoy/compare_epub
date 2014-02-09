# -*- coding: utf-8 -*-

require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper.rb')

EPUB_0 = 'data/book.epub'
EPUB_1 = 'data/book1.epub'

describe 'compare_epub' do

  include CompareEpub

  specify 'compaare same file from CLI' do
    stdin, stdout, stderr, wait_thr = Open3.popen3('bin/compare_epub', EPUB_0, EPUB_0)
    exit_code = wait_thr.value

    expect(stdout.gets).to eq("true\n")
    expect(stderr.gets).to eq(nil)
    expect(exit_code).to eq(0)
  end

  specify 'compaare not same file from CLI' do
    stdin, stdout, stderr, wait_thr = Open3.popen3('bin/compare_epub', EPUB_0, EPUB_1)
    exit_code = wait_thr.value

    expect(stdout.gets).to eq("false\n")
    expect(stderr.gets).to eq(nil)
    expect(exit_code).to eq(0)
  end

  specify 'compaare same file' do
    ret = nil
    output = capture(:stdout) {
      ret = CompareEpub.exec([EPUB_0, EPUB_0])
    }
    expect(output).to eq("true\n")
    expect(ret).to eq(0)
  end

  specify 'compaare not same file' do
    ret = nil
    output = capture(:stdout) {
      ret = CompareEpub.exec([EPUB_0, EPUB_1])
    }
    expect(output).to eq("false\n")
    expect(ret).to eq(0)

    diff_text = "- text:Chapter two has just begun.\n+ text:Chapter two has just begun. 123\n"
    expect(`cat work-diff/diff/ch003.xhtml.txt`).to eq(diff_text)
    expect(`ls work-diff/diff`).to eq("ch003.xhtml.txt\n")
  end

  specify 'specify bat file_1' do
    output = capture(:stdout) {
      expect {
        CompareEpub.exec([EPUB_0, "np-exit"])
      }.to raise_error(Errno::ENOENT) { |e|
        expect(e.message).to eq 'No such file or directory - np-exit'
      }
    }
  end

  specify 'specify bat file_0' do
    output = capture(:stdout) {
      expect {
        CompareEpub.exec(["np-exit", EPUB_0])
      }.to raise_error(Errno::ENOENT) { |e|
        expect(e.message).to eq 'No such file or directory - np-exit'
      }
    }
  end

  specify 'help' do
    ret = nil
    output = capture(:stdout) {
      ret = CompareEpub.exec([])
    }
    help_text = "usage: ruby compare-epubs.rb epub_0 epub_1 [dir_unzipped]\n output:\n      \"true\":  epub は一致\n      \"false\": epub は不一致\n epub_0, epub_1: 比較する epub ファイル。\n   dir_unzipped: unzip 結果、差分結果を格納するフォルダ。\n"
    expect(output).to eq(help_text)
    expect(ret).to eq(1)
  end

end
# --- End of File ---
