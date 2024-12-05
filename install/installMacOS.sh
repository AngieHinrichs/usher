arch=$(uname -m)
echo "uname -m is '$arch'"
set -beEu -o pipefail

brew install cmake boost protobuf wget rsync openmpi libtool automake autoconf nasm isa-l tbb

# create build directory
startDir=$PWD
cd $(dirname "$0")
mkdir -p ../build
cd ../build

# Build UShER
cmake ..

# can't build ripples-fast because it uses GNU Built-in Functions
# (https://gcc.gnu.org/onlinedocs/gcc-5.3.0/gcc/x86-Built-in-Functions.html)
# but compiler is Clang on github macos-13 runner
make -j2 VERBOSE=1 usher matUtils usher-sampled ripples ripplesUtils ripplesInit matOptimize \
    compareVCF output_final_protobuf transpose_vcf transposed_vcf_to_vcf transposed_vcf_to_fa \
    transposed_vcf_print_name

# install faToVcf
rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/macOSX.x86_64/faToVcf .
chmod +x faToVcf

# install mafft
if ! command -v mafft &> /dev/null; then 
wget https://mafft.cbrc.jp/alignment/software/mafft-7.471-mac.zip
unzip mafft-7.471-mac.zip
cd mafft-mac/
mv mafft.bat /usr/local/bin/mafft; mv mafftdir /usr/local/bin/
cd ..
rm -rf mafft-mac
fi

cd $startDir
