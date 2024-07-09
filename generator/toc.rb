#!/usr/bin/env ruby

require 'csv'
require 'erb'

require_relative './misc.rb'
require_relative './generator.rb'

def gen_toc(sections, toctitle, confname, startpage)
  draft_page_numbers_warned = false
  toc = sections.map do |s|
    if s.status == true or draft_page_numbers_warned then '' else
      draft_page_numbers_warned = true
      "\\noindent{\\color{red}~Внимание! Номера страниц ниже могут измениться.}\n\n"
    end +
    "\\contentsline{section}{#{s.name}}{\\hyperlink{abspage-#{s.start_page}.1}{#{s.start_page}}}{}\\nopagebreak[4]\n" +
    if s.status == true then '' else "{\\color{red}~#{s.status}}\n" end +
    s.articles.map do |a|
      "\\contentsline{subsection}{\\textbf{#{a.by}#{if not a.by.end_with?('.') then '.' else '' end}}~#{a.title}}{\\hyperlink{abspage-#{a.start_page}.2}{#{a.start_page}}}{}"
    end.join("\n")
  end.join("\n\n")

  section_templ = ERB::new(File::read(File::join(File::dirname(__FILE__), 'toc.erb')))
  section_tex = section_templ.result binding

  File::open(File::join(File::dirname(sections[0].fullfolder), "_toc.tex"), "w:UTF-8") do |f|
    f.write section_tex
  end
end

def gen_bib procs
  File::open(File::join(File::dirname(procs.sections[0].fullfolder), "proceedings.bib"), "w:UTF-8") do |f|
    bib_templ = ERB::new procs.bibentry_erb
    procs.sections.each do |s|
      s.articles.each do |a|
        f.puts bib_templ.result a.get_binding
        f.puts
      end
    end
  end
end

def gen_pubcsv procs
  CSV.open(File::join(File::dirname(procs.sections[0].fullfolder), 'proceedings.csv'),'w',
    :col_sep => "\t",
    :headers => ['T', 'Автор/руководитель','Название', 'кол-во страниц', 'страницы']
  ) do |csv|

    procs.sections.each do |s|
      csv << [
        '▶',
        s.heads ? (s.heads.map { |h| h.name } .join ' ') : 'CUSTOM',
        s.name
      ]
      s.articles.each do |a|
        csv << [ '▸', a.by, a.title, a.pagescount, "%03d-%03d" % [a.start_page, a.start_page + a.pagescount - 1] ]
      end
    end
  end
end
