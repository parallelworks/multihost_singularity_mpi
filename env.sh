# OpenMPI
export OMPI_DIR=/contrib/${USER}/ompi # Needs to be a shared directory!
export OMPI_VERSION=4.0.1
export OMPI_URL="https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-$OMPI_VERSION.tar.bz2"
export PATH=$OMPI_DIR/bin:$PATH
export LD_LIBRARY_PATH=$OMPI_DIR/lib:$LD_LIBRARY_PATH
export MANPATH=$OMPI_DIR/share/man:$MANPATH
# Singularity
export SINGULARITY_CONTAINER=/contrib/${USER}/openmpi.sif # Needs to be a shared directory