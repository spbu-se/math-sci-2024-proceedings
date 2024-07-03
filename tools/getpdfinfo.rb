#!/usr/bin/env ruby

require 'yaml'
require 'rexml/document'
require 'rexml/xpath'

=begin YAML:
  - title: Визуализация сетевых атак в задачах подготовки кадров в сфере кибербезопасности	
    meta_pages_count: XXX
    by:
      - Author A. B.
      - Author A. B.
    file:  s1_1.pdf
=end

def file_meta file
  pxml = `pdfinfo -meta #{file}`
  doc = REXML::Document.new(pxml)
  
  titles = REXML::XPath.match(doc,
    '//dc:title/rdf:Alt/rdf:li/text()'
  )
  authors = REXML::XPath.match(doc,
    '//dc:creator/rdf:Seq/rdf:li/text()'
  )
  npages = REXML::XPath.match(doc,
    '//xmpTPg:NPages/text()'
  )
  
  if
    titles.length() != 1 ||
    authors.length() < 1 ||
    npages.length() != 1
  then
    STDERR.puts "File: #{file}"
    STDERR.puts "Title(s): #{titles}"
    STDERR.puts "Author(s): #{authors}"
    STDERR.puts "Pages: #{npages}"
    abort("")
  end
  
  {
    'title' => titles[0].to_s.gsub(/[[:space:]]/, ' '),
    'file' => file.to_s,
    'meta_pages_count' => Integer(npages[0].to_s),
    'by' => authors.map(&:to_s)
  }
end

files = ARGV.map { |a| Dir.glob a }.flatten

articles_data = {
  'articles' => files.map { |f| file_meta f }
}

# p articles_data

STDOUT.write articles_data.to_yaml(:options => {:line_width => 512})
STDOUT.flush
