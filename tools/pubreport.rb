#!/usr/bin/env ruby

require 'csv'
require 'yaml'

ymls = Dir.glob "../sections/**/section.yml"


CSV.open('pubreport.csv','w',
    :col_sep => "\t",
    :headers => ['T', 'Автор/руководитель','Название', 'кол-во страниц']
  ) do |csv|

  for y in ymls do
    sec = YAML.load_file(y)
    csv << [
      '▶',
      sec['heads'] ? (sec['heads'].map { |h| h['name'] } .join ' ') : 'CUSTOM',
      sec['name']
    ]
    for ar in sec['articles'] do
      csv << [ '▸', (ar['by'].join ' '), ar['title'], ar['meta_pages_count'] ]
    end
  end

end
