#!/usr/bin/env ruby
# encoding: utf-8

require('msgpack')

if ARGV.length != 1
  puts "usage: freq.rb genome-file"
  exit
end

if not File.exists?(ARGV[0])
  puts "error: file `#{ARGV[0]}` does not exist"
  exit
end

def load_freq(chr)
  fname = "rb-chr-#{chr}-CEU-r28-b36.msgpack.bin"
  return MessagePack.unpack(IO.read(fname))
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
