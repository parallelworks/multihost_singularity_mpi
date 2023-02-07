# MULTIHOST HELLO DOCKER MPI
This repository is an example of running OpenMPI in multiple hosts using Singularity.


## Instructions:
- Edit `env.sh` to set up OpenMPI and Singularity build parameters 
- Execute `./build_singularity.sh` to build the singularity container
- Execute `./install_openmpi.sh` to build and install OpenMPI
- Execute `./run_sbatch.sh` to run a hello world mpi slurm job
- Execute `./run_all.sh` to execute all of the above
