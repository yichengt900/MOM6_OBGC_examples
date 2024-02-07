#How to build MOM6-SIS2-cobalt on Mac

# input datasets
- [Ocean_bgc dataset](https://drive.google.com/file/d/1yLzkKQccwAcOMBzRTQp8mYwUcyNb16Gh/view?usp=share_link)
- [OM4_025_JRA](https://drive.google.com/file/d/1QLA8a7S_fHWqwsgJLHssO0sRCs37ARxZ/)


## Install Homebrew
```console
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_ROOT=/opt/homebrew
export PATH=$HOMEBREW_ROOT/bin:$PATH
```
## Install Prerequisite packages
```console
brew install gcc \
gfortran \
openmpi \
netcdf \
netcdf-fortran \
autoconf \
automake \
git \
git-lfs \
wget

git lfs install
```

## Change default gcc
```console
cd /opt/homebrew/bin
ln -s g++-13 g++
ln -s gcc-13 gcc
```
Then open a new terminal window

## Install FRE-NCtools for grid generation
```console
mkdir work && cd work
git clone https://github.com/NOAA-GFDL/FRE-NCtools.git
autoreconf -i
mkdir build && cd build
../configure --prefix=/Users/$USER/work/FRE-NCtools/build
make
make install
```
The tools will be located at `/Users/$USER/work/FRE-NCtools/build/bin`

## compile CEFI MOM6-SIS2-cobalt and run 1-D example
```console
git clone https://github.com/yichengt900/MOM6_OBGC_examples.git --recursive
cd MOM6_OBGC_examples/builds
./linux-build.bash -m macOS -p osx-gnu -t repro -f mom6sis2
cd ../exps
# download input datasets
cd OM4.single_column.COBALT
mpirun -np 1 ../../builds/build/macOS-osx-gnu/ocean_ice/repro/MOM6SIS2

## Switch to different ocean_BGC or MOM6 repos
```console
cd MOM6_OBGC_examples/src/ocean_BGC && git remote add ynt https://github.com/NOAA-CEFI-Regional-Ocean-Modeling/ocean_BGC.git && git fetch ynt && git checkout ynt/dev/cefi
```

# container approach
Another approach is to run 1-D case within container. First one can follow this [link](https://sylabs.io/2023/03/installing-singularityce-on-macos-with-apple-silicon-using-utm-rocky/) to install SingularityCE on M1/M2 mac machines. Then following below steps to build container image and run 1-D case within container:

## build singularity image
```console
mkdir work && cd work
git clone https://github.com/yichengt900/MOM6_OBGC_examples.git --recursive
cd MOM6_OBGC_examples/tests
singularity build --fakeroot 1d_mom6_cobalt.sif ./build_1d_mom6_cobalt.def
```

## Run the singularity container image in interactive mode
```console
singularity shell --fakeroot -B /home/$USER/work:/work -e 1d_mom6_cobalt.sif 
```
## Build MOM6-SIS2-cobalt and run 1D case within singularity container
```console
Singularity> cd /work/MOM6_OBGC_examples/builds
Singularity> ./linux-build.bash -m docker -p linux-gnu -t prod -f mom6sis2
Singularity> cd ../exps
Singularity> # download input datasets 
Singularity> cd OM4.single_column.COBALT
Singularity> mpirun -np 1 --allow-run-as-root ../../builds/build/docker-linux-gnu/ocean_ice/prod/MOM6SIS2
```
