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

fh = {}

#((1..22).to_a.map {|i| i.to_s} + ["X", "Y", "M"]).each do |chr|
def load_freq(chr)
  fname = "genotype_freqs_chr#{chr}_CEU_r28_nr.b36_fwd.txt"
  fh = {}

  File.open(fname) do |f|
    f.readline # Discard header
    while ! f.eof?
      a = f.readline.split
      fh[a[0]] = {}

      fh[a[0]][a[10]] = a[11]
      fh[a[0]][a[13]] = a[14]
      fh[a[0]][a[16]] = a[17]
    end
  end

  return fh
end

File.open(ARGV[0]) do |f|
  cur_chr = nil

  while ! f.eof?
    s = f.readline
    next if s[0] == "#"

    id, chr, position, gt = s.split

    hmgt = ""
    if gt.length == 2
      gt.insert(1, "/")
      hmgt = gt
    else
      hmgt = "#{gt}/#{gt}"
    end

    hmchr = chr
    hmchr = "M" if hmchr == "MT"

    if hmchr != cur_chr
      $stderr.puts "Loading frequency data for chromosome #{hmchr}..."
      fh = load_freq(hmchr)
      cur_chr = hmchr
      $stderr.puts "Attaching frequency data to genome..."
    end

    if gt.match("-")
      puts "** no call on #{id} (chr#{chr})"
      next
    end

    if fh[id].nil?
      puts "** #{id} not documented in frequency file"
      next
    end

    puts "#{id} (chr#{chr}) is #{gt} with frequency #{fh[id][hmgt]}"
  end
end
