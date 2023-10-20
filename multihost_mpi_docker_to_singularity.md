# Converting Docker to Singularity for Multihost MPI Simulation
To begin this tutorial, make sure you're logged into the controller node of a cloud cluster. You can find detailed login instructions by visiting this [link](https://parallelworks.com/docs/compute/logging-in-controller).

In this tutorial, we'll show you how to convert a Docker container into a Singularity container and use it to run simulations that utilize MPI across multiple nodes within a SLURM-based cluster.

For our example, we'll use the [official OpenFOAM Docker container](https://hub.docker.com/r/openfoam/openfoam11-paraview510). Keep in mind that this container already has OpenFOAM precompiled. So, for creating the Singularity container, we'll adopt the Hybrid Approach. If you're working with software that requires compilation, you can explore the Bind Approach. You can find more details on these methods in this [link](https://docs.sylabs.io/guides/3.7/user-guide/mpi.html#singularity-and-mpi-applications). Our demonstration will focus on running the OpenFOAM cyclone tutorial as a sample case.


## Running OpenFOAM inside the Docker Container
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

4. **Configure Decomposition Parameters**: Edit the `system/decomposeParDict` file to set the `numberOfSubdomains` and `simpleCoeffs` parameters. These parameters define how the mesh will be divided among MPI processes. Make sure that `numberOfSubdomains` is smaller than the number of cores in the controller node and matches the multiplication of the coefficients in the `simpleCoeffs` parameter.

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

6. **Parallel Simulation with MPI**: Run the solver in parallel using MPI. In this example, we use 4 MPI processes.

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


