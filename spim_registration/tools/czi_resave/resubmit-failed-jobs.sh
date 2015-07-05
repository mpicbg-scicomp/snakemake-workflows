names=`grep "exit code 1" out.* -l`
for name in $names; do
	job=`sed -n '4,4p' $name | sed -n "s/Job <\([^>]*\)>.*/\1/p"`
	echo bsub -q short -n 12 -R rusage[mem=110000] -R span[hosts=1] -o "out.%J" -e "err.%J" ${job}
       bsub -q short -n 12 -R rusage[mem=110000] -R span[hosts=1] -o "out.%J" -e "err.%J" ${job}
done
