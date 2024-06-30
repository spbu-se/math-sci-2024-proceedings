#!/usr/bin/env ruby

require_relative './misc.rb'

class Section
  def maketex(start_page)
    @start_page = start_page
    emptypage = "\\mbox{}\\newpage"

    chairman_texs = @heads.map do |h|
      <<~HEAD_TEMPLATE
      \\vspace{5mm}
      \\includegraphics[height=5cm]{../../portraits/#{h.photo}}\\\\
      \\vspace{2mm}
      {\\large \\textbf{\\textsf{#{h.name}}}}\\\\
      \\textsf{#{h.title}}

      HEAD_TEMPLATE
    end

    warning = if @status == true then '' else "{\\Huge \\color{red}~#{@status}}\n" end

    cur_page = start_page + 2

    section_articles_templ = ERB::new(File::read(File::join(File::dirname(__FILE__), 'section_articles.erb')))
    articles_tex = section_articles_templ.result binding

    add_empty = cur_page.even?

    finalemptypage = if add_empty then # last is odd
      cur_page += 1
      emptypage
    else
      ''
    end

    section_templ = ERB::new(File::read(File::join(File::dirname(__FILE__), 'section_tex.erb')))
    section_tex = section_templ.result binding

    File::open(File::join(@fullfolder, "_section-overlay.tex"), "w:UTF-8") do |f|
      f.write section_tex 
    end

    win = is_os_windows?
    suffix, hashbang = win ? [ 'bat', '' ] : [ 'sh', '#!/bin/bash' ]

    File::open(File::join(@fullfolder, "_section-compile.#{suffix}"), "w:UTF-8") do |f|
      pdfs = ['../../generator/a5-empty.pdf'] * 2 +
        @articles.map { |a| File::basename(a.fullfile) } +
        if add_empty then ['../../generator/a5-empty.pdf'] else [] end

      f.puts <<~COMPILE
        #{hashbang}
        #{OPTIONS[:texlauncher]} _section-overlay.tex
        #{OPTIONS[:texlauncher] == 'tectonic' ? '# ' : ''}#{OPTIONS[:texlauncher]} _section-overlay.tex

        #{pdf_tool.join_pdfs_cmd pdfs, '_section-articles.pdf'}
        #{pdf_tool.overlay_pdfs_cmd '_section-articles.pdf', '_section-overlay.pdf', @pdfname}

        #{win ? 'move' : 'mv'} #{@pdfname} ..
        COMPILE

      # generate separate article files
      cur_art_start_page = 3
      @articles.each do |a|
        next_art_start_page = cur_art_start_page + a.pagescount
        f.puts pdf_tool.overlay_pdf_with_pages_cmd(
          File::basename(a.fullfile),
          '_section-overlay.pdf',
          (cur_art_start_page...next_art_start_page), # yes, not including
          "../_sep_arts/#{'%03d' % a.start_page}-#{'%03d' % (a.start_page + a.pagescount - 1)}.pdf"
        )
        cur_art_start_page = next_art_start_page
      end
    end

    if not win
      File::u_plus_x File::join(@fullfolder, "_section-compile.sh")
    end
    cur_page
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
