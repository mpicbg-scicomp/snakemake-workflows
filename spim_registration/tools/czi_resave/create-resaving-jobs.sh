#!/bin/bash

# path of master file
source ../master_preprocessing.sh

# creates directory for job files if not present
mkdir -p $jobs_resaving

# splits up resaving into 1 job per .czi file and writes the given parameters
# into the job file
for i in $timepoints

do
	for a in $angle_prep
	do
		job="$jobs_resaving/resave-$i-$a.job"
		echo $job
		echo "$XVFB_RUN $sysconfcpus $Fiji_resave \
			-Ddir=$image_file_directory \
			-Dtimepoint=$i \
			-Dangle=$a \
			-Dpad=$pad \
			-- --no-splash $resaving" >> "$job"
		chmod a+x "$job"
	done
done
