#!/usr/bin/env ruby

OPTIONS = {}

def File::u_plus_x file_name
  File::chmod(File::stat(file_name).mode | 0700, file_name)
end

# Inspired by https://github.com/rdp/os/blob/9ee80f9ec0f59ecc731ecdc7c2a8f88180e385f5/lib/os.rb#LL18C3-L28C6

def is_os_windows?
  if RUBY_PLATFORM =~ /cygwin/ # i386-cygwin
    false
  elsif ENV['OS'] == 'Windows_NT'
    true
  else
    false
  end
end

class PDFTool

  def get_page_count file_name
    raise NotImplementedError.new("Either qpdf or pdftk, not this abstract one!")
  end

  def join_pdfs_cmd sources, target
    raise NotImplementedError.new("Either qpdf or pdftk, not this abstract one!")
  end

  def overlay_pdfs_cmd bottom, top, target
    raise NotImplementedError.new("Either qpdf or pdftk, not this abstract one!")
  end

  def overlay_pdf_with_pages_cmd bottom, top, top_range, target
    raise NotImplementedError.new("Either qpdf or pdftk, not this abstract one!")
  end

end

class PDFtkPDFTool < PDFTool

  def get_page_count file_name
    output = `pdftk "#{file_name}" dump_data`
    /NumberOfPages:\s+(?<npages>\d+)/ =~ output
    if npages
      npages.to_i
    else
      raise "No number of pages in #{file_name}"
      nil
    end
  end

  def join_pdfs_cmd sources, target
    "pdftk #{sources.map{|f| "\"#{f}\""}.join ' '} cat output \"#{target}\""
  end

  def overlay_pdfs_cmd bottom, top, target
    "pdftk \"#{top}\" multibackground \"#{bottom}\" output \"#{target}\""
  end

  def overlay_pdf_with_pages_cmd bottom, top, top_range, target
    'echo "Do not know yet how to take a part of overlay with pdftk..."'
  end

end

class QpdfPDFTool < PDFTool

  def get_page_count file_name
    npages = `qpdf --show-npages "#{file_name}"`
    if npages
      npages.to_i
    else
      raise "No number of pages in #{file_name}"
      nil
    end
  end

  def join_pdfs_cmd sources, target
    "qpdf --empty --pages #{sources.map{|f| "\"#{f}\" 1-z"}.join ' '} -- \"#{target}\""
  end

  def overlay_pdfs_cmd bottom, top, target
    "qpdf \"#{top}\" --underlay \"#{bottom}\" -- \"#{target}\""
  end

  def overlay_pdf_with_pages_cmd bottom, top, top_range, target
    "qpdf \"#{bottom}\" --overlay \"#{top}\" --from=#{top_range.min}-#{top_range.max} -- \"#{target}\""
  end

end

def pdf_tool
  case OPTIONS[:pdftool]
  when 'qpdf'
    QpdfPDFTool.new
  when 'pdftk'
    PDFtkPDFTool.new
  else
    raise 'No idea what pdf tool to use'
  end
end
