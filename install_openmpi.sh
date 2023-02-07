#!/bin/bash
echo "Installing Open MPI"
source env.sh
rm -rf /tmp/ompi
mkdir -p /tmp/ompi
# Download
cd /tmp/ompi && wget -O openmpi-$OMPI_VERSION.tar.bz2 $OMPI_URL && tar -xjf openmpi-$OMPI_VERSION.tar.bz2
# Compile and install
cd /tmp/ompi/openmpi-$OMPI_VERSION && ./configure --prefix=$OMPI_DIR && make install