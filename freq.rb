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

def flip(n)
  return {"A" => "T", "T" => "A", "C" => "G", "G" => "C"}[n] || n
end

def flip_gt(gt)
  fgt = gt.dup

  fgt[0] = flip(fgt[0])

  if fgt.length >= 3
    fgt[2] = flip(fgt[2])

    if fgt[0] > fgt[2] # Genotypes present nucleotides alphabetically
      tmp = fgt[0]
      fgt[0] = fgt[2]
      fgt[2] = tmp
    end
  end

  return fgt
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

    freq = fh[id][hmgt]
    flag = ""

    fhmgt = flip_gt(hmgt)
    ffreq = fh[id][fhmgt]

    if fhmgt != hmgt && ! ffreq.nil?
      flag = " (potential misorientation; flip has frequency #{ffreq})"
    end

    if freq.nil?
      if ffreq.nil?
        $stderr.puts " *** #{id} has neither #{hmgt} nor #{fhmgt}"
        next
      else
        freq = ffreq
        flag = " (flipped)"
      end
    end

    puts "#{id} (chr#{chr}) is #{gt} with frequency #{freq}#{flag}"
  end
end
