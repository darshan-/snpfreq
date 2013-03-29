#!/usr/bin/env ruby
# encoding: utf-8

if ARGV.length != 1
  puts "usage: freq.rb genome-file"
  exit
end

if not File.exists?(ARGV[0])
  puts "error: file `#{ARGV[0]}` does not exist"
  exit
end

File.open(ARGV[0]) do |f|
  while ! f.eof?
    s = f.readline
    next if s[0] == "#"

    id, chr, position, gt = s.split
    hmgt = gt.insert(1, "/").chomp("/")
    hmchr = chr
    hmchr = "M" if hmchr == "MT"
    freq_file = "genotype_freqs_chr#{hmchr}_CEU_r28_nr.b36_fwd.txt"

    if gt.match("-")
      puts "** no call on #{id} (chr#{chr})"
      next
    end

    freqs = `grep #{id} #{freq_file}`

    if $?.exitstatus > 0
      puts "** #{id} not documented in #{freq_file}"
      next
    end

    freqa = freqs.split

    if freqa[0] != id
      puts "** Something went wrong finding #{id} in #{freq_file}"
      next
    end

    aag = freqa[10]
    aaf = freqa[11]
    amg = freqa[13]
    amf = freqa[14]
    mmg = freqa[16]
    mmf = freqa[17]

    freq = ""

    if hmgt == aag
      freq = aaf
    elsif hmgt == amg
      freq = amf
    elsif hmgt == mmg
      freq = mmf
    else
      freq = "unknown"
    end

    puts "#{id} (chr#{chr}) is #{hmgt} with frequency #{freq}"
  end
end
