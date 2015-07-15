#!/bin/bash

# path of master file
source ../master_preprocessing.sh

# creates directory for job files if not present
mkdir -p $jobs_compress

echo $jobs_compress
echo $czi_compress

# splits up resaving into 1 job per .czi file and writes the given parameters
# into the job file
for i in $timepoints

do
	for a in $angle_prep
	do
		job="$jobs_compress/compress-$i-$a.job"
		echo $job
		echo "$XVFB_RUN $sysconfcpus $Fiji_resave \
			-Ddir=$image_file_directory \
			-Dtimepoint=$i \
			-Dangle=$a \
			-Dpad=$pad \
			-- --no-splash $czi_compress" >> "$job"
		chmod a+x "$job"
	done
done

