#!/usr/bin/env ruby

require 'optparse'

require_relative './misc.rb'
require_relative './metadata.rb'
require_relative './generator.rb'
require_relative './toc.rb'
require_relative './whole.rb'

OptionParser.new do |opts|
  opts.banner = "Usage: generator.rb [options]"

  opts.on("-s", "--sections [STRING]", "Folder with sections and proceedings.yml, current by default") do |v|
    OPTIONS[:sections] = File::expand_path(v)
  end
  opts.on("-t", "--tex-launcher [STRING]", "XeLaTeX CLI launcher, tectonic or xelatex") do |v|
    OPTIONS[:texlauncher] = v
  end
  opts.on("-p", "--pdf-tool [STRING]", "PDF tool to use, either pdftk or qpdf or combined to do the best") do |v|
    OPTIONS[:pdftool] = v
  end
end.parse!

if !OPTIONS.key?(:sections) then
  OPTIONS[:sections] = File::expand_path(File::join(File::dirname(File::expand_path(__FILE__)), '../sections'))
end

if !OPTIONS.key?(:texlauncher) then
  `which tectonic`
  if $?.success?
    OPTIONS[:texlauncher] = 'tectonic'
  else
    `which xelatex`
    if $?.success?
      OPTIONS[:texlauncher] = 'xelatex'
    else
      STDERR.puts "XeLaTeX launcher not specified, failed to detect either tectonic or xelatex"
      exit -1
    end
  end
end

if !OPTIONS.key?(:pdftool) then
  `which pdftk`
  pdftk_exists = $?.success?
  `which qpdf`
  qpdf_exists = $?.success?
  if pdftk_exists && qpdf_exists
    OPTIONS[:pdftool] = 'combined'
  elsif pdftk_exists
    OPTIONS[:pdftool] = 'pdftk'
  elsif qpdf_exists
      OPTIONS[:pdftool] = 'qpdf'
  else
      STDERR.puts "pdftool not specified, failed to detect either qpdf or pdftk"
      exit -1
  end
end

puts "Starting generator with options:"
p OPTIONS

proceedings = Proceedings::new

cpage = proceedings.content_start_page

proceedings.sections.each do |s|
  cpage = s.maketex(cpage)
end

gen_toc(proceedings.sections, "Содержание", proceedings.title, cpage)

gen_whole(proceedings.sections)

gen_bib(proceedings)
