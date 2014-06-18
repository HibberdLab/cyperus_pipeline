# download all dependencies

mkdir ~/apps
cd ~/apps

# khmer
pip install --user khmer
# scripts are now in ~/.local/bin/
PATH=$PATH:~/.local/bin/

# SPADES BayesHammer
wget http://spades.bioinf.spbau.ru/release3.1.0/SPAdes-3.1.0-Linux.tar.gz
tar xvf SPAdes-3.1.0-Linux.tar.gz
cp -r ~/apps/SPAdes-3.1.0-Linux/* ~/.local/

# trimmomatic
wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.32.zip
unzip Trimmomatic-0.32.zip

# sga
# first we need google sparsehash
wget https://sparsehash.googlecode.com/files/sparsehash-2.0.2.tar.gz
tar xvf sparsehash-2.0.2.tar.gz
cd sparsehash-2.0.2/
./configure --prefix=$HOME/.local/
make && make install
SPARSEHASH_PATH=$HOME/.local/
# then bamtools
cd ~/apps
git clone https://github.com/pezmaster31/bamtools.git
mkdir build
cd build
cmake ..
make
BAMTOOLS_PATH=$HOME/apps/bamtools/
# then jemalloc
cd ~/apps
wget http://www.canonware.com/download/jemalloc/jemalloc-3.6.0.tar.bz2
tar xvf jemalloc-3.6.0.tar.bz2
cd jemalloc-3.6.0/
./configure --prefix=$HOME/.local/
make && make install
JEMALLOC_PATH=$HOME/.local
# finally, sga itself
git clone https://github.com/jts/sga.git
cd sga/src
./configure --prefix=$HOME/.local/ --with-sparsehash=$SPARSEHASH_PATH --with-bamtools=$BAMTOOLS_PATH --with-jemalloc=$JEMALLOC_PATH
make && make install

# gapcloser
cd ~/apps
wget http://downloads.sourceforge.net/project/soapdenovo2/GapCloser/bin/r6/GapCloser-bin-v1.12-r6.tgz
tar xvf ../GapCloser-bin-v1.12-r6.tgz
mv GapCloser ~/.local/bin/

# SOAPdenovo-trans
cd ~/apps
git clone https://github.com/cboursnell/SOAPdenovo-Trans.git
mv SOAPdenovo-Trans/SOAP* ~/.local/bin/

# IDBA
cd ~/apps
wget http://hku-idba.googlecode.com/files/idba-1.1.1.tar.gz
./configure --prefix=$HOME/.local/
make && make install

# Bowtie2
cd ~/apps
wget http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/2.2.3/bowtie2-2.2.3-linux-x86_64.zip
unzip bowtie2-2.2.3-linux-x86_64.zip
mv bowtie2-2.2.3/bowtie* ~/.local/bin/

# eXpress
cd ~/apps
wget http://bio.math.berkeley.edu/eXpress/downloads/express-1.5.1/express-1.5.1-linux_x86_64.tgz
tar xvf express-1.5.1-linux_x86_64.tgz
mv express-1.5.1-linux_x86_64/express ~/.local/bin/

# cd-hit-est
cd ~/apps
wget https://cdhit.googlecode.com/files/cd-hit-v4.6.1-2012-08-27.tgz
tar xvf cd-hit-v4.6.1-2012-08-27.tgz
cd cd-hit-v4.6.1-2012-08-27
make
mv cd-hit* ~/.local/bin/

# fastqc
cd ~/apps
wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.2.zip
unzip fastqc_v0.11.2.zip
cd FastQC
chmod +x fastqc
ln -s $PWD/fastqc $HOME/.local/bin/fastqc
