#!/bin/bash

# path of master file
source ../master_preprocessing.sh

# creates directory for job files if not present
mkdir -p ${jobs_ometiff}

# splits up resaving into 1 job per .czi file and writes the given parameters
# into the job file
tif_timepoint=${first_timepoint}

for timepoint in ${timepoints}

do
	for angle in ${angles}
	do
		job="$jobs_ometiff/resave-${timepoint}-${angle}.job"
		echo $job
		echo "${XVFB_RUN} ${sysconfcpus} ${Fiji_ometiff} \
			-Ddir=${image_file_directory} \
			-Dfirst_file=${first_file} \
			-Dtimepoint=${timepoint} \
			-Dangle=${angle} \
			-Dpad=${pad} \
			-Dtif_timepoint=${tif_timepoint} \
			-- --no-splash ${ometiff_resave}" >> "${job}"
		chmod a+x "${job}"
	done
tif_timepoint=$((${tif_timepoint} + 1))

done
