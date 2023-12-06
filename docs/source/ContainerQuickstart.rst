.. _QuickstartC:

====================================
Container-Based Quick Start Guide
====================================

This Container-Based Quick Start Guide will help users build and run the 1D case for the MOM6-OBGC System using a `Singularity/Apptainer <https://apptainer.org/docs/user/1.2/introduction.html>`__ container. The :term:`container` approach provides a uniform enviroment in which to build and run the MOM6-OBGC. Normally, the details of building and running the MOM6-OBGC vary from system to system due to the many possible combinations of operating systems, compilers, :term:`MPIs <MPI>`, and package versions available. Installation via container reduces this variability and allows for a smoother MOM6-OBGC build experience. 

The basic "1D" case described here builds a MOM6-OBGC for the Bermuda Atlantic Time-series Study (BATS) with OM4 single column configuration as well as COBALT-4p (still under development).

Prerequisites 
-------------------

Users must have either Docker (recommended for personal Windows/macOS systems) or Singularity/Apptainer (recommended for users working on Linux, NOAA Cloud, or HPC systems).

Install Docker on Windows/macOS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To build and run the MOM6-OBGC using a Docker container, first install the software according to the `Docker Installation Guide for Windows <https://docs.docker.com/desktop/install/windows-install/>`__ or `Docker Installation Guide for macOS <https://docs.docker.com/desktop/install/mac-install/>`__. 

Install Singularity/Apptainer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

   As of November 2021, the Linux-supported version of Singularity has been `renamed <https://apptainer.org/news/community-announcement-20211130/>`__ to *Apptainer*. Apptainer has maintained compatibility with Singularity, so ``singularity`` commands should work with either Singularity or Apptainer (see compatibility details `here <https://apptainer.org/docs/user/1.2/introduction.html>`__.)

To build and run the MOM6-OBGC using a Singularity/Apptainer container, first install the software according to the `Apptainer Installation Guide <https://apptainer.org/docs/admin/1.2/installation.html>`__. This will include the installation of all dependencies.

Build and run 1-D example using Docker 
-----------------------------------------
User can follow the following steps to build and run MOM6-OBGC 1-D case within a Docker container.
.. code-block::

   #Assume user is under /USER_HOME_PATH
   docker pull clouden90/1d_mom6_cobalt:v0.1 #This will pull docker image to your local machine
   git clone -b feature/4p-2023-10 https://github.com/yichengt900/MOM6_OBGC_examples.git --recursive #git clone MOM6-OBGC feature branch
   cd USER_HOME_PATH//MOM6_OBGC_examples/exps/OM4.single_column.COBALT.p4/INPUT
   rm ocean_hgrid.nc; wget https://gfdl-med.s3.amazonaws.com/OceanBGC_dataset/ocean_hgrid.nc
   rm COBALT_2023_10_spinup_2003_subset.nc; wget https://gfdl-med.s3.amazonaws.com/OceanBGC_dataset/COBALT_2023_10_spinup_2003_subset.nc
   docker run --rm -v /USER_HOME_PATH:/work -it clouden90/1d_mom6_cobalt:v0.1 bash --login # run docker container
   cd /work/MOM6_OBGC_examples/builds
   ./linux-build.bash -m docker -p linux-gnu -t prod -f mom6sis2 #build MOM6-SIS2-OBGC
   cd /work/MOM6_OBGC_examples/exps
   ln -fs /opt/datasets ./
   cd OM4.single_column.COBALT.p4
   mpirun -np 1 ../../builds/build/docker-linux-gnu/ocean_ice/prod/MOM6SIS2


Build and run 1-D example using Singularity/Apptainer container
-----------------------------------------
For users working on systems with limited disk space in their ``/home`` directory, it is recommended to set the ``SINGULARITY_CACHEDIR`` and ``SINGULARITY_TMPDIR`` environment variables to point to a location with adequate disk space. For example:

.. code-block:: 

   export SINGULARITY_CACHEDIR=/absolute/path/to/writable/directory/cache
   export SINGULARITY_TMPDIR=/absolute/path/to/writable/directory/tmp

where ``/absolute/path/to/writable/directory/`` refers to a writable directory (usually a project or user directory within ``/lustre``, ``/work``, ``/scratch``, or ``/glade`` on NOAA RDHPC systems). If the ``cache`` and ``tmp`` directories do not exist already, they must be created with a ``mkdir`` command.

Then User can follow the following steps to build and run MOM6-OBGC 1-D case within a Singularity/Apptainer container.
.. code-block::

   #Assume user is under /USER_HOME_PATH
   singularity pull 1d_mom6_cobalt.sif docker://clouden90/1d_mom6_cobalt:v0.1 #pull docker image and convert to sif
   git clone -b feature/4p-2023-10 https://github.com/yichengt900/MOM6_OBGC_examples.git --recursive #git clone MOM6-OBGC feature branch
   cd /USER_HOME_PATH/MOM6_OBGC_examples/exps/OM4.single_column.COBALT.p4/INPUT
   rm ocean_hgrid.nc; wget https://gfdl-med.s3.amazonaws.com/OceanBGC_dataset/ocean_hgrid.nc
   rm COBALT_2023_10_spinup_2003_subset.nc; wget https://gfdl-med.s3.amazonaws.com/OceanBGC_dataset/COBALT_2023_10_spinup_2003_subset.nc
   singularity shell -B /USER_HOME_PATH:/work -e /USER_HOME_PATH/1d_mom6_cobalt.sif
   cd /work/MOM6_OBGC_examples/builds
   ./linux-build.bash -m docker -p linux-gnu -t prod -f mom6sis2 #build MOM6-SIS2-OBGC
   cd /work/MOM6_OBGC_examples/exps
   ln -fs /opt/datasets ./
   cd OM4.single_column.COBALT.p4
   mpirun -np 1 ../../builds/build/docker-linux-gnu/ocean_ice/prod/MOM6SIS2

   
   
    
