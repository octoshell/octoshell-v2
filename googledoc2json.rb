#!/usr/bin/env ruby

require "nokogiri"
require "json"
require 'fileutils'

PREFIX='/home/serg/tmp/qwe1'

def html2json(html)
  doc = Nokogiri::HTML(html)
  
  ind=-1
  data={}
  header=[]
  doc.search('/html/body/div/table/tbody/tr').each{|tr|
    line=tr.search('./td').map{|td| td.content}
    if ind==-1 #header!
      header=line.reject{|x| x==''}.clone
      ind=1
      next
    elsif line[0].to_s=='' # empty line
      next
    end
    data[line[0]]={'index' => ind}
    header.each_with_index{|h,i|
      #next if i==0
      data[line[0]][h]=line[i]
    }
    ind+=1
  }
  data
end





if ARGV[0].to_s==''
  warn "Usage: googledoc2json.rb ZIP-file"
  exit 1
end

begin
  
  dir="tmp-#{$$}"
  FileUtils.mkdir(dir)
  FileUtils.chdir(dir)
  if ARGV[0][0]=='/'
    `unzip '#{ARGV[0]}'` or raise "Cannot uncompress #{ARGV[0]}"
  else
    `unzip '../#{ARGV[0]}'` or raise "Cannot uncompress #{ARGV[0]}"
  end

  json={}
  ['groups','classes','detailed_analysis',
  'mpip_rules','rules','thresholds',].each{|f|
    json[f]=html2json(File.open("#{PREFIX}/#{f}.html").read)
  }
  FileUtils.chdir '..'
  FileUtils.rm_rf dir
rescue Exception => e
  warn e
  exit 1
end

puts json.to_json

