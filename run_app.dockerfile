FROM ubuntu:18.04 as builder
# install the packages for dev
RUN apt update; apt install -y build-essential git libgoogle-glog-dev libunwind-dev
# cmake >= 3.10 cannot find_package(MPI) as LIBRARY_SUFFIXES ".a" for LINKER_FLAGS "-static"
ADD https://github.com/Kitware/CMake/archive/refs/tags/v3.9.6.tar.gz /
RUN tar -xf /v3.9.6.tar.gz --directory=/
WORKDIR /CMake-3.9.6
RUN ./configure; make install
# build mpich from source
ADD http://www.mpich.org/static/downloads/3.4.3/mpich-3.4.3.tar.gz /
RUN tar -xf /mpich-3.4.3.tar.gz --directory=/
WORKDIR /mpich-3.4.3
RUN ./configure --with-device=ch3 --disable-fortran; make install
# build run_app of grape-lite
COPY . /libgrape-lite-src
WORKDIR /libgrape-lite-src/build
RUN rm -rf *; cmake ..; make -j

FROM ubuntu:18.04
COPY --from=builder /libgrape-lite-src/build/run_app /libgrape-lite-src/build/run_app
COPY --from=builder /libgrape-lite-src/dataset /libgrape-lite-src/dataset
COPY --from=builder /usr/local/bin/mpiexec.hydra /usr/local/bin/mpirun
COPY --from=builder /usr/local/bin/hydra_pmi_proxy /usr/local/bin/hydra_pmi_proxy
# default command (for test and demo)
ENTRYPOINT ["mpirun"]
CMD ["-n", "2", "/libgrape-lite-src/build/run_app", "--directed", \
"--vfile", "/libgrape-lite-src/dataset/p2p-31.v", \
"--efile", "/libgrape-lite-src/dataset/p2p-31.e", \
"--application", "sssp", "--sssp_source", "6", \
"--out_prefix", "/libgrape-lite-src/build/output_sssp"]