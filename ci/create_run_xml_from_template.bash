#!/bin/bash

# --- get current date ---
CURRENT_DATE=$(date "+%Y%m%d%H%M")

# --- submodules from MOM6_OBGC_examples ---

submodules="FMS MOM6 ocean_BGC SIS2 atmos_null coupler ice_param icebergs land_null"

# --- get the remote URL for ocean_BGC  & MOM6 repos
pushd ../ 
git config --file .gitmodules --get submodule.src/ocean_BGC.url
export OBGC_SUBMODULE_URL=$(git config --file .gitmodules --get submodule.src/ocean_BGC.url | sed 's|/ocean_BGC\.git$||')
git config --file .gitmodules --get submodule.src/MOM6.url
export MOM6_SUBMODULE_URL=$(git config --file .gitmodules --get submodule.src/MOM6.url | sed 's|/MOM6\.git$||')
popd

# --- get the hash for the various repos
if [ -f ocean_ice_cobalt_experiments.xml ]; then rm -rf ocean_ice_cobalt_experiments.xml ; fi
pushd ../
for mod in $submodules ; do
  export hash_${mod}=$( git submodule status | grep $mod | awk '{print $1}' | cut -c 2-10 )
done
popd

echo "Current date: " $CURRENT_DATE
echo "MOM6 tag: " $hash_MOM6
echo "ocean_BGC tag: " $hash_ocean_BGC
echo "SIS2 tag: " $hash_SIS2
echo "ICEBREGS tag: " $hash_icebergs
echo "ICE_PARAM tag: " $hash_ice_param
echo "COUPLER tag: " $hash_coupler
echo "FMS tag: " $hash_FMS
echo "ATMOS tag: " $hash_atmos_null
echo "LAND tag: " $hash_land_null
echo "MOM6_SUBMODULE_URL: " $MOM6_SUBMODULE_URL
echo "OBGC_MOM6_SUBMODULE_URL: " $OBGC_SUBMODULE_URL

# --- replace the hashes in the xml template

cat ocean_ice_cobalt_experiments.template.xml | sed -e "s/<FMS_GIT_HASH>/$hash_FMS/g" \
                                                    -e "s/<COUPLER_GIT_HASH>/$hash_coupler/g" \
                                                    -e "s/<SIS2_GIT_HASH>/$hash_SIS2/g" \
                                                    -e "s/<ICEBERGS_GIT_HASH>/$hash_icebergs/g" \
                                                    -e "s/<ICEPARAM_GIT_HASH>/$hash_ice_param/g" \
                                                    -e "s/<MOM6_GIT_HASH>/$hash_MOM6/g" \
                                                    -e "s/<OBGC_GIT_HASH>/$hash_ocean_BGC/g" \
                                                    -e "s/<LAND_GIT_HASH>/$hash_land_null/g" \
                                                    -e "s/<ATMOS_GIT_HASH>/$hash_atmos_null/g" \
						    -e "s|<MOM6_SUBMODULE_URL>|$MOM6_SUBMODULE_URL|g" \
						    -e "s|<OBGC_SUBMODULE_URL>|$OBGC_SUBMODULE_URL|g" \
					            -e "s/<CURRENT_DATE>/$CURRENT_DATE/g" \
                                                    > ocean_ice_cobalt_experiments.xml


# -- clean up tmp folders or runs from previos runs
echo "remove MOM6_OBGC_examples folder"
rm -rf MOM6_OBGC_examples

workflow_directory="/lustre/f2/dev/Yi-cheng.Teng/github/cefi_NWA12_regression_${CURRENT_DATE}"
# Check if the directory exists
if [ -d "$workflow_directory" ]; then
    # If it exists, remove it
    echo "Removing workflow directory: $workflow_directory"
    rm -rf "$workflow_directory"
else
    echo "Workflow directory does not exist: $workflow_directory"
fi

# Now compile mom6-sis2-cobalt 
module use -a /ncrc/home2/fms/local/modulefiles
module load fre/bronx-20
module use -a /ncrc/home2/fms/local/modulefiles
module load fre/bronx-20
echo "run fremake and submit compile job"
fremake -f -F -x ocean_ice_cobalt_experiments.xml -p ncrc5.intel22 -t repro MOM6_SIS2_GENERIC_4P_compile_symm
jobid=$(sbatch --parsable /lustre/f2/dev/Yi-cheng.Teng/github/cefi_NWA12_regression_${CURRENT_DATE}/MOM6_SIS2_GENERIC_4P_compile_symm/ncrc5.intel22-repro/exec/compile_MOM6_SIS2_GENERIC_4P_compile_symm.csh | awk -F';' '{print $1}' | cut -f1)
echo "Submitted Slurm job with ID: $jobid"

# Check the status of the job in a loop
sleep 1
while :; do
    # Check the status of the job
    job_status=$(squeue -h -j "$jobid" -o "%T" 2>/dev/null)

    if [ -z "$job_status" ]; then
        echo "Job with ID $jobid is not found or completed."
        break
    else
        echo "Job with ID $jobid is still running."
        echo "Job Status: $job_status"
    fi

    # Sleep for a short duration before checking again
    sleep 60  # Adjust the sleep duration as needed
done


# check if fms_MOM6_SIS2_GENERIC_4P_compile_symm.x create successfully or not
executable_file="/lustre/f2/dev/Yi-cheng.Teng/github/cefi_NWA12_regression_${CURRENT_DATE}/MOM6_SIS2_GENERIC_4P_compile_symm/ncrc5.intel22-repro/exec/fms_MOM6_SIS2_GENERIC_4P_compile_symm.x"
if [ -f "$executable_file" ]; then
    echo "Executable file created successfully: $executable_file"
    # Rest of your script...
else
    echo "Executable file not created within the specified duration."
    echo "Please check /lustre/f2/dev/Yi-cheng.Teng/github/cefi_NWA12_regression_${CURRENT_DATE}/MOM6_SIS2_GENERIC_4P_compile_symm/ncrc5.intel22-repro/exec/compile_MOM6_SIS2_GENERIC_4P_compile_symm.csh.o$jobid"
    exit 1
fi

# run frerun and submit a RT test for NWA12-RT case
echo "run frerun and submit a NWA12-RT case"
frerun --notransfer -o -x ocean_ice_cobalt_experiments.xml -p ncrc5.intel22 -q debug -r NWA12_RT -t repro NWA12_COBALT_V1
rt_jobid=$(sbatch --parsable /lustre/f2/dev/Yi-cheng.Teng/github/cefi_NWA12_regression_${CURRENT_DATE}/NWA12_COBALT_V1/ncrc5.intel22-repro/scripts/run/NWA12_COBALT_V1_1x0m2d_1646x1o | awk -F';' '{print $1}' | cut -f1)
echo "Submitted RT job with ID: $rt_jobid"

# Check the status of the job in a loop
sleep 1
while :; do
    # Check the status of the job
    job_status2=$(squeue -h -j "$rt_jobid" -o "%T" 2>/dev/null)

    if [ -z "$job_status2" ]; then
        echo "Job with ID $rt_jobid is not found or completed."
        break
    else
        echo "Job with ID $rt_jobid is still running."
        echo "Job Status: $job_status2"
    fi

    # Sleep for a short duration before checking again
    sleep 300  # Adjust the sleep duration as needed
done

# check if restart create successfully or not
check_file="/lustre/f2/scratch/Yi-cheng.Teng/github/cefi_NWA12_regression_${CURRENT_DATE}/NWA12_COBALT_V1/ncrc5.intel22-repro/archive/1x0m2d_1646x1o/restart/19930103.tar.ok"
if [ -f "$check_file" ]; then
    echo "restart files exist successfully: $check_file"
else
    echo "NWA12 RT is not done within the specified duration."
    echo "Please check /lustre/f2/scratch/Yi-cheng.Teng/github/cefi_NWA12_regression_${CURRENT_DATE}/NWA12_COBALT_V1/ncrc5.intel22-repro/stdout/run/NWA12_COBALT_V1_1x0m2d_1646x1o.o$rt_jobid"
    exit 10
fi

# check with references
if [ -f check.log ]; then rm -rf check.log ; fi
frecheck -x ocean_ice_cobalt_experiments.xml -p ncrc5.intel22 -r NWA12_RT -t repro NWA12_COBALT_V1 > check.log

# String to check
expected_string="REFERENTIALLY   PASSED: NWA12_COBALT_V1"

# Check if the string exists in the file
if grep -qF "$expected_string" check.log; then
    echo "PASSED: RT results are identical."
else
    echo "FAIL: check the check.log"
    cat check.log
    exit 100
fi

# Final clean-up
rm -rf /lustre/f2/scratch/Yi-cheng.Teng/work/github/cefi_NWA12_regression_${CURRENT_DATE}
rm -rf /lustre/f2/dev/Yi-cheng.Teng/github/cefi_NWA12_regression_${CURRENT_DATE}
