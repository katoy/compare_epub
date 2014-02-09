# -*- coding: utf-8 -*-

# 2012-05-31 katoy
#  2 つの epub の比較判定をする。
#  unzip した結果や、差分は 指定フォルダー (3番目のパラメータで指定) に出力される。
#   (default は "./work-diff")
#
#  現状では pandoc で生成した epub では 本文の文書変更が検知できるようになっている。
#  ignore_file?(), ignore_node?() の微調整が必要。

require  File.expand_path(File.dirname(__FILE__) + '/compare_epub/version')

require 'rubygems'
require 'fileutils'
require 'pathname'
require 'nokogiri/diff'  # gem install nokogiri-diff
require 'open-uri'
require 'zipruby'        # gem install nokogiri-diff

module CompareEpub

  # 比較対象としないファイル
  IGNORE_FILES = [
                 ]

  def ignore_file?(name)
    IGNORE_FILES.each do |f|
      return true if name.include?(f)
    end
    false
  end

  # 比較対象としない ノード
  def ignore_node?(filename, node)
    return ((node.name == 'content') && (node.parent.name == 'meta')) if filename.include?('toc.ncx')
    if filename.include?('content.opf')
      return (((node.name == 'text') && (node.parent.name == 'identifier')) ||
              ((node.name == 'text') && (node.parent.name == 'date'))
              )
    end
    false
  end

  def unzip_epubs(epub_0, epub_1, out_dir)
    [epub_0, epub_1].each do |f|
      unless File.exists?(f)
        STDERR.puts("ERROR: ファイルが存在していません。ファイル名：'#{f}'")
        return ans
      end
    end

    FileUtils.rm_rf("#{out_dir}/diff")

    [epub_0, epub_1].each do |epub|
      unzip_dir = out_dir + '/' + File.basename(epub) + '/'
      FileUtils.rm_rf(unzip_dir)

      Zip::Archive.open(epub) do |archives|
        archives.each do |a|
          d = File.dirname(a.name)
          FileUtils.makedirs(unzip_dir + d)
          unless a.directory?
            File.open(unzip_dir + a.name, 'w+b') do |f|
              f.print(a.read)
            end
          end
        end
      end
    end
  end

  def compare_tree(dir_0, dir_1, diff_out, diff_text)
    files = []
    # 対象ファイル名の一覧を得る。
    # TODO: リファクタリング
    [dir_0, dir_1].each do |dir|
      Dir.glob(dir + '/**/*').each do |f|
        # if (f.end_with?(".xml") or f.end_with?(".rels"))
        files << f.gsub(dir + '/', '')  unless File.directory?(f)
      end
    end
    files.sort!
    files.uniq!

    diffs = 0
    diffs_name = []
    adds_name = []
    miss_name = []

    files.each do|name|
      next if ignore_file?(name)

      f0 = "#{dir_0}/#{name}"
      f1 = "#{dir_1}/#{name}"
      f2 = "#{diff_out}/#{name}"

      unless FileTest.exists?(f0)
        adds_name << name  # added in src1
        next
      end

      unless FileTest.exists?(f1)
        miss_name << name  # missing in src1
        next
      end

      next if FileUtils.compare_file(f0, f1)

      doc0 = Nokogiri::XML(open(f0).read)
      doc1 = Nokogiri::XML(open(f1).read)

      is_same = true
      File.open(diff_text, 'w') do |f|
        doc0.diff(doc1) do |change, node|
          if change != ' '
            next if ignore_node?(name, node)
            f.print("#{change} #{node.name}:#{node.to_html}\n")
            is_same = false
          end
        end
      end
      if is_same
        FileUtils.rm_f(diff_text)
      else
        diffs += 1
        diffs_name << f2
        toDir = Pathname(f2).parent
        FileUtils.mkdir_p(toDir) unless File.exists?(toDir)
        FileUtils.mv(diff_text, "#{f2}.txt")
      end
      doc0 = doc1 = nil
      GC.start
    end

    {
      diffs_name: diffs_name,
      adds_name: adds_name,
      miss_name: miss_name
    }
  end

  def compare_epubs(epub_0, epub_1, out_dir)
    ans = 'false'

    begin
      unzip_epubs(epub_0, epub_1, out_dir)

      dir_0 = "#{out_dir}/#{File.basename(epub_0)}"
      dir_1 = "#{out_dir}/#{File.basename(epub_1)}"
      diff_out = "#{out_dir}/diff"
      ret = compare_tree(dir_0, dir_1, diff_out, "#{out_dir}/work_diff.txt")
      ans = 'true' if ret[:diffs_name].size == 0 && ret[:miss_name].size == 0 && ret[:adds_name].size == 0

    rescue => e
      STDERR.puts e.backtrace
      STDERR.puts e
      # ensure
      #
    end
    ans
  end

  def exec(argv)
    def show_usage
      puts('usage: ruby compare-epubs.rb epub_0 epub_1 [dir_unzipped]')
      puts(' output:')
      puts('      "true":  epub は一致')
      puts('      "false": epub は不一致')
      puts(' epub_0, epub_1: 比較する epub ファイル。')
      puts('   dir_unzipped: unzip 結果、差分結果を格納するフォルダ。')
    end

    if argv.size < 2
      show_usage
      return 1  # Error
    end

    epub_diff = 'work-diff'   # デフォルト値

    epub_0 = argv[0]
    epub_1 = argv[1]
    # TODO: もっと厳密にチェックすること。
    epub_diff = argv[2]  if argv.size > 2 && argv[2].length > 0 && argv[2] != '.'

    ans = 'false'
    if FileUtils.compare_file(epub_0, epub_1)
      ans = 'true'
    else
      ans = compare_epubs(epub_0, epub_1, epub_diff)
      # FileUtils.rm_rf(epub_diff) if argv.size == 3 # diff を指定省略したら 削除する
    end
    puts ans
    0  # success
  end
  # --- End of Fiel ---

end
