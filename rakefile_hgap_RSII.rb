ENV["projectdir"] ? @projectdir = ENV["projectdir"] : @projectdir = "HGAP_Assembly"
ENV["inputfile"] ? @inputfile = ENV["inputfile"] : nil

directory "lib"

file "lib/inputfiles.xml" => ["lib", "#{@inputfile}"] do
  sh "source smrtanalysis-2.3p5; fofnToSmrtpipeInput.py lib/inputfiles.fofn > lib/inputfiles.xml"
end

file "#{@projectdir}/data/polished_assembly.fastq.gz" -> ["lib/inputfiles.xml", "lib/settings.xml"] do
  sh "source smrtanalysis-2.3p5; smrtpipe.py --distribute -D CLUSTER_MANAGER=SLURM -D PARTITION=tsl-medium -D TMP=tmp -D NPROC=16 -D NJOBS=16 -D MAX_CHUNKS=64 --params=lib/settings.xml --output=#{@projectdir}  xml:lib/inputfiles.xml && rm -r tmp"
end
task :run_hgap => ["#{@projectdir}/data/polished_assembly.fastq.gz"]

task :default => [:run_hgap]
