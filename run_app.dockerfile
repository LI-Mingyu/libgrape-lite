FROM ubuntu:18.04
RUN apt update; apt install -y build-essential cmake git mpich libgoogle-glog-dev 
COPY . /libgrape-lite-src
WORKDIR /libgrape-lite-src/build
RUN rm -rf *; cmake ..; make -j
ENTRYPOINT ["mpirun"]
CMD ["-n", "2", "/libgrape-lite-src/build/run_app", "--directed", \
"--vfile", "/libgrape-lite-src/dataset/p2p-31.v", \
"--efile", "/libgrape-lite-src/dataset/p2p-31.e", \
"--application", "sssp", "--sssp_source", "6", \
"--out_prefix", "/libgrape-lite-src/build/output_sssp"]