#!/bin/bash
#SBATCH --exclusive
#SBATCH --nodes=2
#SBATCH --job-name=singularity-hello-mpi
#SBATCH --output=singularity-hello-mpi.out
#SBATCH --ntasks-per-node=1
source env.sh

# FIXME: I don't think we should need to run this!
for cnode in $(scontrol show hostname $SLURM_JOB_NODELIST); do
    ssh ${cnode} 'bash -s' < set_max_user_namespaces.sh
done

mpirun -n 2 singularity exec ${SINGULARITY_CONTAINER} /opt/mpitest