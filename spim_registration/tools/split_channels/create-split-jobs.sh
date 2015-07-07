#!/bin/bash

source ../../master_preprocessing.sh

mkdir -p ${jobs_split}

for i in $parallel_timepoints

	do
		for a in $angle_prep

			do
				job="$jobs_split/split-$i-$a.job"
				echo $job
				echo "#!/bin/bash" > "$job"
				echo "$XVFB_RUN -a $Fiji \
				-Dimage_file_directory=$image_file_directory \
				-Dparallel_timepoints=$i \
				-Dangle_prep=$a \
				-Dpad=$pad \
				-Dtarget_split=$image_file_directory \
				-- --no-splash \
				$split" >> "$job"
chmod a+x "$job"
        done
done

