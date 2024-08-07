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

def wherewhich
  is_os_windows? ? 'where' : 'which'
end

RU_TRANSLIT = {
  'а' => 'a', 'б' => 'b', 'в' => 'v', 'г' => 'g', 'д' => 'd',
  'е' => 'e', 'ё' => 'e', 'ж' => 'j', 'з' => 'z', 'и' => 'i',
  'к' => 'k', 'л' => 'l', 'м' => 'm', 'н' => 'n', 'о' => 'o',
  'п' => 'p', 'р' => 'r', 'с' => 's', 'т' => 't', 'у' => 'u',
  'ф' => 'f', 'х' => 'h', 'ц' => 'c', 'ч' => 'ch', 'ш' => 'sh',
  'щ' => 'shch', 'ы' => 'y', 'э' => 'e', 'ю' => 'u', 'я' => 'ya',
  'й' => 'i', 'ъ' => '', 'ь' => ''
}

# Транслит, почти как в
# https://stackoverflow.com/a/60813973/539470
def transliterate cyrillic_string
  translit = ""
  cyrillic_string.downcase.each_char do |char|
    translit += RU_TRANSLIT[char] ? RU_TRANSLIT[char] : ( (char.match?(/[a-z]/)) ? char : '_' )
  end

  translit.gsub(/[^a-z0-9_]+/, '_'). # не алфавитно-цифровые в подчёркивание
    gsub(/^[-_]*|[-_]*$/, '') # ну и почистим
end

# Заменяет "Фамилия И.О." и "Фамилия И. О." на "Фамилия"
def surname_n_p2surname surname_n_p
  surname_n_p[... surname_n_p.index(/\s/)]
end

# Заменяет "Фамилия И.О." и "Фамилия И. О." на "Фамилия, И. О.", как в BibTeX
def surname_n_p2bibtex surname_n_p
  surname_n_p.gsub('.', '. ').sub(' ', ', ').gsub(/\s+/, ' ').rstrip
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
    "pdftk \"#{bottom}\" multistamp \"#{top}\" output \"#{target}\""
  end

  def overlay_pdf_with_pages_cmd bottom, top, top_range, target
    sep = $/
    "pdftk \"#{top}\" cat #{top_range.min}-#{top_range.max} output _section_tmp.pdf" +
    sep +
    self.overlay_pdfs_cmd(bottom, '_section_tmp.pdf', target)
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

# Uses the tool that suits better,
# usually qpdf which is several times faster
class CombinedPDFTool < PDFTool

  def initialize
    @qpdf_tool = QpdfPDFTool.new
    @pdftk_tool = PDFtkPDFTool.new
  end

  def get_page_count file_name
    @qpdf_tool.get_page_count file_name
  end

  # The only thing pdftk does better is concatenating, as
  # qpdf loses TOC.
  # https://github.com/qpdf/qpdf/issues/94#issuecomment-1877573490
  def join_pdfs_cmd sources, target
    @pdftk_tool.join_pdfs_cmd sources, target
  end

  def overlay_pdfs_cmd bottom, top, target
    @pdftk_tool.overlay_pdfs_cmd bottom, top, target
  end

  def overlay_pdf_with_pages_cmd bottom, top, top_range, target
    @qpdf_tool.overlay_pdf_with_pages_cmd bottom, top, top_range, target
  end

end

def pdf_tool
  case OPTIONS[:pdftool]
  when 'combined'
    CombinedPDFTool.new
  when 'pdftk'
    PDFtkPDFTool.new
  when 'qpdf'
    QpdfPDFTool.new  else
    raise 'No idea what pdf tool to use'
  end
end
