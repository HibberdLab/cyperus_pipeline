#!/usr/bin/env ruby

#
# khmer-batch
#
# Take in a set of fastq files and run khmer normalize-by-median.py on each
#   storing the hashtable at each step and using it for the next step
#
# Make sure normalize-by-median.py is in your PATH or specify the location
# with the --script option
#
# Chris Boursnell (cmb211@cam.ac.uk) && Richard Smith (rds45@cam.ac.uk)
# created: 08/07/2013
# last modified: 14/07/2013
#

require 'rubygems'
require 'trollop'

opts = Trollop::options do
  version "v0.0.1a"
  opt :input, "A file of fastq files, 1 per line", :type => String
  opt :files, "A list of colon separated input fastq files", :type => String
  opt :script, "Specify the location of the khmer normalize-by-median.py script if it is not in your PATH", :default => "normalize-by-median.py", :type => String
  opt :paired, "If the input fastq files are interleaved paired reads"
  opt :interleave, "Do the input fastq files need to be interleaved"
  opt :continue, "Continue a previous run using existing table.kh"
  opt :memory, "Maximum amount of memory to be used by khmer in gigabytes", :default => 4.0, :type => :float
  opt :kmer, "K value to use in khmer", :default => 21, :type => :int
  opt :buckets, "Number of buckets", :default => 4, :type => :int
  opt :cleanup, "Remove input files after they are processed"
  opt :gzip, "gzip input and output files after they are processed"
  opt :dsrc, "compress input and output files with dsrc after they are processed"
  opt :test, "Don't run the command"
  opt :verbose, "Be verbose"
end

filelist=[]
# check inputs
if opts.input and opts.files
  abort "Choose either --input or --files but not both"
elsif opts.input
  if !File.exists?(opts.input)
    abort "Can't find file \"#{opts.input}\""
  end
  File.open(opts.input, "r").each_line do |line|
    if !line.nil?
      filelist << line.chomp
    end
  end
elsif opts.files
  filelist = opts.files.split(":")
  filelist.map! { |file|  File.expand_path(file)}
  filelist.each do |file|
    if !File.exists?(file)
      abort "Can't find file \"#{file}\""
    end
  end
end


if opts.interleave
  newfilelist=[]
  # check there are an even number of files in the list
  if filelist.length % 2 == 1
    abort "There needs to be an even number of fastq files in the list if you want to interleave them"
  end
  (0..filelist.length-1).step(2) do |i|
    #if File.exists?("#{filelist[i]}") and File.exists?("#{filelist[i+1]}")
    puts "Interleaving #{filelist[i]} and #{filelist[i+1]}" if opts.verbose
    cmd = "paste #{filelist[i]} #{filelist[i+1]} | paste - - - - | awk -v FS=\"\t\" -v OFS=\"\n\" \'{print(\"@read\"NR\":1\",$3,$5,$7,\"@read\"NR\":2\",$4,$6,$8)}\' > #{filelist[i]}.in"
    # puts cmd if opts.verbose
    `#{cmd}` if !opts.test
    if opts.cleanup
      File.delete(filelist[i]) 
      File.delete(filelist[i+1])
    elsif opts.gzip
      `gzip #{filelist[i]} #{filelist[i+1]}`  if !opts.test
    elsif opts.dsrc
      puts "compressing #{filelist[i]}" if opts.verbose
      `dsrc e #{filelist[i]} #{filelist[i]}.dsrc`  if !opts.test
      puts "compressing #{filelist[i+1]}" if opts.verbose
      `dsrc e #{filelist[i+1]} #{filelist[i+1]}.dsrc` if !opts.test
      `rm #{filelist[i]}` if !opts.test
      `rm #{filelist[i+1]}` if !opts.test
    end
    newfilelist << "#{filelist[i]}.in"
    #end
  end
  filelist = newfilelist
end

# build the command
first = true
if opts.continue
  first = false
end

n = opts.buckets
x = (opts.memory/opts.buckets*1e9).to_i

pair=""
if opts.paired or opts.interleave
  pair = "-p"
end


# run
filelist.each do |file|
  puts "processing: #{file}" if opts.verbose
  filepath = File.dirname(file)
  filename = File.basename(file)
  Dir.chdir(filepath) do |dir|
    puts "changing working directory to #{dir}" if opts.verbose
    if first
      cmd = "#{opts.script} #{pair} -k #{opts.kmer} -N #{n} -x #{x} --savehash table.kh #{filename}"
      puts "running: #{cmd}" if opts.verbose
      puts `#{cmd}` if !opts.test
      first = false
    else
      cmd = "#{opts.script} #{pair} -k #{opts.kmer} -N #{n} -x #{x} --loadhash table.kh --savehash table2.kh #{filename}"
      puts "running #{cmd}" if opts.verbose
      puts `#{cmd}` if !opts.test
      `mv table2.kh table.kh` if !opts.test
    end
    if opts.cleanup
      File.delete(file) if !opts.test
    elsif opts.gzip
      `gzip #{file}` if !opts.test
    elsif opts.dsrc
      puts "compressing #{file}" if opts.verbose
      `dsrc #{file} #{file}.dsrc` if !opts.test
      `rm #{file}` if !opts.test
    end
  end
end

file = filelist[0]
filepath = File.dirname(file)
filename = File.basename(file)
Dir.chdir(filepath) do |dir|
  `rm table.kh` if !opts.test
end

