#!/bin/bash

# path of master file
source ../master_preprocessing.sh

# creates directory for job files if not present
mkdir -p $jobs_resaving

# splits up resaving into 1 job per .czi file and writes the given parameters
# into the job file
tif_timepoint=${first_timepoint}

for timepoint in ${timepoints}

do
	for angle in ${angles}
	do
		job="$jobs_resaving/resave-${timepoint}-${angle}.job"
		echo $job
		echo "${XVFB_RUN} ${sysconfcpus} ${Fiji} \
			-Ddir=${image_file_directory} \
			-Dfirst_czi_name=${first_czi_name} \
			-Dtimepoint=${timepoint} \
			-Dangle=${angle} \
			-Dpad=${pad} \
			-Dtif_timepoint=${tif_timepoint} \
			-- --no-splash ${resaving}" >> "${job}"
		chmod a+x "${job}"
	done
tif_timepoint=$((${tif_timepoint} + 1))

done
