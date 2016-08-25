#!/bin/bash

# path of master file
source ../master_preprocessing.sh

# creates directory for job files if not present
mkdir -p ${jobs_luxendo}

# splits up resaving into 1 job per .czi file and writes the given parameters
# into the job file
tif_timepoint=${first_timepoint}

for timepoint in ${timepoints}

do
	for angle in ${angles}
	do
	
		for channel in ${channels}
		do
			job="$jobs_luxendo/resave-${timepoint}-${angle}.job"
			echo $job
			echo "${XVFB_RUN} ${sysconfcpus} ${Fiji_lux} \
				-Ddir=${image_file_directory} \
				-Dtimepoint=${timepoint} \
				-Dangle=${angle} \
				-Dchannel=${channel} \
				-Dpad=${pad} \
				-- --no-splash ${luxendo_resave}" >> "${job}"
			chmod a+x "${job}"
		done
	done
timepoint=$((${timepoint} + 1))

done
