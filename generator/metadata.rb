#!/usr/bin/env ruby

require 'yaml'

require_relative './misc.rb'

class Chairman
  attr_reader :name, :photo, :title

  def initialize(chdic, sec)
    @section = sec
    @name = chdic['name']
    @photo = chdic['photo']
    @title = chdic['title']
  end
end

class Article
  attr_reader :section, :title, :by, :file, :fullfile, :pagescount, :lang
  attr_accessor :start_page

  def getpagescount
    pdf_tool.get_page_count @fullfile
  end

  def by()
    # Joins to string
    @author_list.map { | a | a.gsub /\s+/, '\\,' }.join ', '
  end

  def initialize(ardic, sec)
    @section = sec
    @title = ardic['title']
    @author_list = ardic['by']
    @file = ardic['file']
    @lang = ardic['lang'] ? ardic['lang'] : 'russian'
    @fullfile = File::join(sec.fullfolder, @file)
    @pagescount = self.getpagescount
    @start_page = nil
  end

  # --- ERB functions ---

  def get_binding
    binding
  end

  def get_translit_surname_0
    transliterate surname_n_p2surname(@author_list[0])
  end

  def get_bibtex_authors
    @author_list.map { | a | surname_n_p2bibtex a } .join(' and ')
  end
end

class Section
  attr_reader :fullfolder, :foldername, :pdfname, :name, :status, :heads, :articles, :confname, :custom_half_title
  attr_accessor :start_page

  def initialize(fullfolder, confname)
    secdic = YAML::load_file(File::join(fullfolder, 'section.yml'))
    @fullfolder = fullfolder
    @foldername = File::basename fullfolder
    @pdfname = "_section--#{@foldername}.pdf"
    @name = secdic['name']
    @status = secdic['status']
    @confname = confname
    @heads =
      if secdic.has_key?('heads') and secdic['heads'] then
        secdic['heads'].map { |h| Chairman::new(h, self) }
      else
        []
      end
    @articles =
      if secdic.has_key?('articles') and secdic['articles'] then
        secdic['articles'].map { |a| Article::new(a, self) }
      else
        []
      end
    @custom_half_title =
      if secdic.has_key?('custom_half_title') and secdic['custom_half_title'] then
        secdic['custom_half_title']
      else
        nil
      end
  end
end

class Proceedings
  attr_reader :title, :sections, :content_start_page, :bibentry_erb

  def initialize
    sectionsfolder = OPTIONS[:sections]
    procmeta = YAML::load_file(File::join(sectionsfolder, 'proceedings.yml'))
    @sectionsfolder = sectionsfolder
    @title = procmeta['title']
    @bibentry_erb = procmeta['bibentry_erb']
    start_page_count = pdf_tool.get_page_count(File::join(sectionsfolder, '_a_begin.pdf'))
    @content_start_page = start_page_count + ( start_page_count.odd? ? 2 : 1 )
    @sections = procmeta['sections'].map do |f|
      Section::new(File::expand_path(File::join(sectionsfolder, f)), @title)
    end
  end
end
