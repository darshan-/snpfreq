#!/usr/bin/env ruby
# encoding: utf-8

((1..22).to_a.map {|i| i.to_s} + ["X", "Y", "M"]).each do |chr|
  ifname = "genotype_freqs_chr#{chr}_CEU_r28_nr.b36_fwd.txt"
  fh = {}

  puts "Reading #{ifname}..."
  File.open(ifname) do |f|
    f.readline # Discard header
    while ! f.eof?
      a = f.readline.split
      fh[a[0]] = {}

      fh[a[0]][a[10]] = a[11]
      fh[a[0]][a[13]] = a[14]
      fh[a[0]][a[16]] = a[17]
    end
  end

  ofname = "rb-chr-#{chr}-CEU-r28-b36.bin"
  puts "Writing #{ofname}..."
  File.open(ofname, 'w') do |f|
    f.write(Marshal.dump(fh))
  end
end
