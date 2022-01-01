FROM ubuntu:18.04 as builder
# install the packages for dev
RUN apt update; apt install -y build-essential cmake git libgoogle-glog-dev 
# build mpich from source
ADD http://www.mpich.org/static/downloads/3.4.3/mpich-3.4.3.tar.gz /
RUN tar -zxvf /mpich-3.4.3.tar.gz
WORKDIR /mpich-3.4.3
RUN ./configure --with-device=ch3 --disable-fortran; make install
# build run_app of grape-lite
COPY . /libgrape-lite-src
WORKDIR /libgrape-lite-src/build
RUN rm -rf *; cmake ..; make -j
# default command (for test and demo)
ENTRYPOINT ["mpirun"]
CMD ["-n", "2", "/libgrape-lite-src/build/run_app", "--directed", \
"--vfile", "/libgrape-lite-src/dataset/p2p-31.v", \
"--efile", "/libgrape-lite-src/dataset/p2p-31.e", \
"--application", "sssp", "--sssp_source", "6", \
"--out_prefix", "/libgrape-lite-src/build/output_sssp"]