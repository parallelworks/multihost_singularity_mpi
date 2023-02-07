#!/bin/bash
source env.sh
sudo singularity build ${SINGULARITY_CONTAINER} openmpi.def 