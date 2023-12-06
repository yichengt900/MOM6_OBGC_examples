.. _QuickstartC:

====================================
Container-Based Quick Start Guide
====================================

This Container-Based Quick Start Guide will help users build and run the 1D case for the MOM6-OBGC System using a `Singularity/Apptainer <https://apptainer.org/docs/user/1.2/introduction.html>`__ container. The :term:`container` approach provides a uniform enviroment in which to build and run the MOM6-OBGC. Normally, the details of building and running the MOM6-OBGC vary from system to system due to the many possible combinations of operating systems, compilers, :term:`MPIs <MPI>`, and package versions available. Installation via container reduces this variability and allows for a smoother MOM6-OBGC build experience. 

The basic "1D" case described here builds a MOM6-OBGC for the Bermuda Atlantic Time-series Study (BATS) with OM4 single column configuration as well as COBALT-4p (still under development). 

