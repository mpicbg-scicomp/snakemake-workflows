#!/bin/bash

#source ../../master_3.3.sh

timepoint=`seq 0 391`
dir=/projects/pilot_spim/Christopher/2014-10-23_H2A_gsb_G3/
num_angles=1
pad=3

job_dir=/projects/pilot_spim/Christopher/pipeline_3.0/jobs_alpha_3.1/czi_resave/


for i in $timepoint

	do
		i=`printf "%0${pad}d" "$i"`
		num=$(ls $dir/spim_TL"$i"_Angle*.tif |wc -l)

			if [ $num  -ne $num_angles ]

	then
		echo "TL"$i": TP or angles missing"
		//bsub -q short -n 4 -R span[hosts=1] -o "out.%J" -e "err.%J" ${1}/*${i}*

	else
		echo "TL"$i": Correct"

fi

done
