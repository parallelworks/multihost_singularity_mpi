#!/bin/bash
set -e
cd $(dirname $0)
./build_singularity.sh &> build_singularity.out
./install_openmpi.sh  &> install_openmpi.out
sbatch run_sbatch.sh