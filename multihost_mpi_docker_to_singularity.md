# Converting Docker to Singularity for Multihost MPI Simulation
Welcome to our tutorial on converting a Docker container to a Singularity container for running MPI simulations across multiple nodes within a SLURM-based cluster. Before we begin, please ensure that you are logged into the controller node of your cloud cluster. If you need instructions for logging in, you can find them [here](https://parallelworks.com/docs/compute/logging-in-controller).


In this tutorial, we will demonstrate how to convert a Docker container into a Singularity container and use it to run simulations that harness the power of MPI for parallel computing. We will be focusing on running the OpenFOAM cyclone tutorial as a sample case using the official OpenFOAM Docker container(https://hub.docker.com/r/openfoam/openfoam11-paraview510). Keep in mind that this Docker container already has OpenFOAM precompiled. To achieve this, we will adopt the Hybrid Approach for creating the Singularity container. If you're working with software that requires compilation, you can explore the Bind Approach, which is detailed [here](https://docs.sylabs.io/guides/3.7/user-guide/mpi.html#singularity-and-mpi-applications).

Now, let's dive into the process of converting the Docker container to a Singularity container and running your  MPI simulations efficiently on your cluster using multiple nodes.

## Running OpenFOAM with Docker
Let's first dive into running OpenFOAM simulations inside the Docker container on the controller node of your cloud cluster. Here's how to get started:

1. **Start an Interactive Shell**: Launch an interactive shell within the Docker container with the following command.

```
sudo docker run -it openfoam/openfoam11-paraview510 /bin/bash
```

2. **Copy the Cyclone Tutorial**: Copy the Cyclone tutorial to your home directory. This tutorial is a sample case that we'll be working with.

```
cp -r /opt/openfoam11/tutorials/incompressibleDenseParticleFluid/cyclone .
```


3. **Change Directory**: Navigate to the Cyclone tutorial directory.
```
cd cyclone
```

4. **Configure Decomposition Parameters**: Edit the `system/decomposeParDict` file to set the `numberOfSubdomains` and `simpleCoeffs` parameters. These parameters define how the mesh will be divided among MPI processes. Make sure that `numberOfSubdomains` is not larger than the number of cores in the controller node and matches the multiplication of the coefficients in the `simpleCoeffs` parameter.

Here's an example for a controller node with 4 cores where the mesh is divided into 4 subdomains:

```
/*--------------------------------*- C++ -*----------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     | Website:  https://openfoam.org
    \\  /    A nd           | Version:  10
     \\/     M anipulation  |
\*---------------------------------------------------------------------------*/
FoamFile
{
    format      ascii;
    class       dictionary;
    location    "system";
    object      decomposeParDict;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

numberOfSubdomains 4;

method          simple;

simpleCoeffs
{
    n               (2 2 1);
}
```

5. **Mesh Processing**: Execute the following commands to create and split the mesh.

```
blockMesh
snappyHexMesh -overwrite
decomposePar
```

6. **Parallel Simulation with OpenMPI**: Run the solver in parallel using OpenMPI. In this example, we use 4 MPI processes.

```
mpirun -np 4 foamRun -parallel
```

7. **Monitoring and Stopping**: Monitor the simulation to ensure it's running as expected. To cancel the job, use the key combination C-x C-c.

That's it! You've successfully run an OpenFOAM simulation within the Docker container on your cloud cluster's controller node.

## Converting the Docker Container to a Singularity Container
To convert a Docker container into a Singularity container, follow these steps. Please note that root access is required for this process.


1. **Singularity Definition File**: Create a Singularity definition file named openfoam.def with the following simple definition. For more information on creating this file, you can refer to this [link](https://docs.sylabs.io/guides/3.7/user-guide/definition_files.html).

```
BootStrap: docker
From: openfoam/openfoam11-paraview510

%help
  This Singularity container of the openfoam/openfoam11-paraview510 docker repository

```

2. **Build the Singularity Container**: Use the command below to build the singularity container where `openfoam.sif` and `openfoam.def` are the paths to the singularity container file and definition file, respectively.

```
sudo singularity build openfoam.sif openfoam.def
```


## Running OpenFOAM with Singularity
Running OpenFOAM simulations within the Singularity container follows similar steps to those in the Docker container. Here's how to do it:

1. **Start an Interactive Shell**: Launch an interactive shell within the Singularity container using the following command. Note that the user's home directory is automatically mounted inside the container.

```
singularity shell ./openfoam.sif /bin/bash
```

2. **Load OpenFOAM Environment**: Unlike the Docker container, in the Singularity container, you need to manually load the OpenFOAM environment by running:

```
source /opt/openfoam11/etc/bashrc
```

3. **Prepare the OpenFOAM Case**: Repeat the following steps (2, 3, 4, and 5) for preparing the OpenFOAM case, which involves copying the Cyclone tutorial, changing directories, and configuring decomposition parameters, just like in the Docker container. These steps remain the same.


We will now explore two alternative ways to run the OpenFOAM simulation with OpenMPI:

- **OpenMPI Inside the Container**: To use the OpenMPI installation inside the container, you can run the simulation with the following command while in the Singularity container:

```
mpirun -np 4 foamRun -parallel
```


Alternatively, you can run the simulation from outside the container using this command (replace /path/to/openfoam.sif with your container path):

```
singularity exec /path/to/openfoam.sif /bin/bash -c "source /opt/openfoam11/etc/bashrc; mpirun -np 4 foamRun -parallel"
```

- **OpenMPI Outside the Container**:  To use an OpenMPI installation outside the container, ensure that it's compatible with the version of OpenMPI inside the container. To check the version, use mpirun --version. For example, if the container uses version 4.0.3 and your external installation uses version 4.0.1, you can run the simulation as follows:


```
mpirun -np 4 singularity exec  /path/to/openfoam.sif /bin/bash -c "source /opt/openfoam11/etc/bashrc; foamRun -parallel"
```


## Running OpenFOAM with Singularity using Multiple Nodes
To run your simulation utilizing MPI accross multiple nodes you need to use the OpenMPI installation outside the container. Follow the steps below:

1. **Create the SLURM Script**: Prepare a SLURM job script, such as run.sh, to submit the simulation job to the SLURM-based cluster. In this script, specify the required SLURM parameters and configure the tasks and nodes as needed. Ensure that the number of tasks per node does not exceed the number of cores available on each compute node in the cluster. Below is an example run.sh script:

```
#!/bin/bash
#SBATCH --nodes=2
#SBATCH --job-name=singularity-openfoam
#SBATCH --output=singularity-openfoam.out
#SBATCH --ntasks-per-node=2
#SBATCH --chdir=/path/to/shared/directory/with/OpenFoam/Case

# LOAD OpenMPI ENVIRONMENT HERE!

# REPLACE THE PATH TO THE SIF FILE
SIF_PATH="/path/to/openfoam.sif"

# MESH CASE
singularity exec ${SIF_PATH} /bin/bash -c "source /opt/openfoam11/etc/bashrc; blockMesh"
singularity exec ${SIF_PATH} /bin/bash -c "source /opt/openfoam11/etc/bashrc; snappyHexMesh -overwrite"
singularity exec ${SIF_PATH} /bin/bash -c "source /opt/openfoam11/etc/bashrc; decomposePar"

# RUN SIMULATION
mpirun -np 4 singularity exec ${SIF_PATH} /bin/bash -c "source /opt/openfoam11/etc/bashrc; foamRun -parallel"
```

1. **Submit the SLURM Job**: Use the sbatch command to submit the SLURM job script, such as sbatch run.sh, to the cluster's job scheduler. This initiates the simulation using the specified SLURM parameters.

By following these steps, you can run OpenFOAM simulations across multiple nodes within a SLURM-based cluster using Singularity and OpenMPI. This approach allows for efficient parallel processing and scaling of simulations.