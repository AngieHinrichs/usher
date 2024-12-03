brew install cmake boost protobuf wget rsync openmpi libtool automake autoconf nasm
wget https://github.com/intel/isa-l/archive/refs/tags/v2.30.0.tar.gz
tar -xvf v2.30.0.tar.gz
pushd isa-l-2.30.0
./autogen.sh
./configure --prefix=$(brew --prefix) --libdir=$(brew --prefix)/lib
make -j2
make install
popd

# create build directory
startDir=$pwd
cd $(dirname "$0")
mkdir -p ../build
cd ../build

# TBB
wget https://github.com/oneapi-src/oneTBB/releases/download/2019_U9/tbb2019_20191006oss_mac.tgz
tar -xvzf tbb2019_20191006oss_mac.tgz

# Build UShER
cmake -DTBB_DIR=${PWD}/tbb2019_20191006oss -DCMAKE_PREFIX_PATH=${PWD}/tbb2019_20191006oss/cmake ..
arch=$(uname -m)
echo "uname -m is '$arch'"
if [[ "$arch" == "arm64" ]]; then
    # can't build ripples-fast because it uses x86_64 machine instructions
    make -j2 VERBOSE=1 usher matUtils usher-sampled ripples ripplesUtils ripplesInit matOptimize \
        compareVCF output_final_protobuf transpose_vcf transposed_vcf_to_vcf transposed_vcf_to_fa \
        transposed_vcf_print_name
else
    make -j2 VERBOSE=1
fi

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
