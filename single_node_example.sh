#!/bin/bash
#SBATCH --exclusive
#SBATCH --nodes=1
#SBATCH --job-name=docker-hello-mpi
#SBATCH --output=docker-hello-mpi.out
#SBATCH --chdir=/home/Matthew.Shaxted/multihost_docker_mpi
#SBATCH --ntasks-per-node=2

sudo service docker start


# (Running on the first node)
sudo docker run -i -v `pwd`:`pwd` -w `pwd` avidalto/openmpi-ubuntu:v3 mpirun \
    --allow-run-as-root \
    -np 2 \
    mpi_hello_world > mpirun.out


