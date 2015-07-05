#!/bin/bash
# path of master file
source ../master_3.3.sh

# path of source and target files
source_pattern=${image_file_directory}${source_pattern}
target_pattern=${image_file_directory}${target_pattern}

# ------------------------------------------------------------------------------

i=${first_index}
t=${first_timepoint}
t=`printf "%0${pad}d" "${t}"`

while [ $i -le $last_index ]; do

        for a in "${angles_renaming[@]}"; do

        	source=${source_pattern/\{index\}/${i}}
                tmp=${target_pattern/\{timepoint\}/${t}}
                target=${tmp/\{angle\}/${a}

                echo ${source} ${target} # displays source file and target file with path

                mv ${source} ${target} # renames source file into target pattern
                #cp ${source} ${target} # alternatively copy source file and resave into target pattern
                let i=i+1

        done
	t=$(( 10#${t} ))
        let t=t+1
        t=`printf "%0${pad}d" "${t}"`

done
