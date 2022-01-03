FROM ubuntu:18.04 as builder
# install the packages for dev
RUN apt update; apt install -y build-essential cmake libgoogle-glog-dev openmpi-bin libopenmpi-dev openssh-client
# build run_app of grape-lite
COPY . /libgrape-lite-src
WORKDIR /libgrape-lite-src/build
RUN rm -rf *; cmake ..; make -j

#FROM ubuntu:18.04
#RUN apt update; apt install -y libunwind8 libgomp1
#COPY --from=builder /libgrape-lite-src/build/run_app /libgrape-lite-src/build/run_app
#COPY --from=builder /libgrape-lite-src/dataset /libgrape-lite-src/dataset
#COPY --from=builder /usr/local/bin/mpiexec.hydra /usr/local/bin/mpirun
#COPY --from=builder /usr/local/bin/hydra_pmi_proxy /usr/local/bin/hydra_pmi_proxy
# default command (for test and demo)
# ENTRYPOINT ["mpirun"]
# CMD ["-n", "2", "/libgrape-lite-src/build/run_app", "--directed", \
CMD ["/libgrape-lite-src/build/run_app", "--directed", \
"--vfile", "/libgrape-lite-src/dataset/p2p-31.v", \
"--efile", "/libgrape-lite-src/dataset/p2p-31.e", \
"--application", "sssp", "--sssp_source", "6", \
"--out_prefix", "/libgrape-lite-src/build/output_sssp"]