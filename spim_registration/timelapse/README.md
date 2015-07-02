Datasets
========================
The scripts are now supporting multiple angles, multiple channels and multiple illumination direction without adjusting the .bsh or creat-jobs.sh scripts.

Based on SPIM registration version 3.3.8

Supported datasets are in the following format:

ImageJ Opener (resave to .tif):

    Multiple timepoints: YES (one file per timepoint)
    Multiple channels: YES (one file per channel)
    Multiple illumination directions: YES (one file per illumination direction) => not tested yet
    Multiple angles: YES one file per angle

Zeiss Lightsheet Z.1 Dataset (LOCI)

    Multiple timepoints: Supports multiple time points per file
    Multiple channels: Supports multiple channels per file
    Multiple illumination directions: YES (one file per illumination direction)
    Multiple angles: YES (one file per angle)

Timelapse based workflow
========================

Expected setup
--------------

```bash
/path/to/repo
├── deconvolution_CPU.bsh
├── deconvolution_GPU.bsh
├── transform.bsh	 		
├── registration.bsh 		
└── xml_merge.bsh	 		
```

* a data directory e.g. looks like this

```bash
/path/to/data
├── hdf5_test_unicore-00-00.h5
├── hdf5_test_unicore-01-00.h5
├── hdf5_test_unicore.h5
├── hdf5_test_unicore.xml
└── tomancak.yaml	 		# copied/symlinked from this repo
```


* `tomancak.yaml` contains the parameters that configure the beanshell scripts found in the data directory
* `Snakefile` from this directory
* `cluster.json` that resides in the same directory as the `Snakefile`
* cluster runs LSF


Submitting Jobs
---------------

If DRMAA is supported on your cluster:

```bash
snakemake -j2 -d /path/to/data/ --cluster-config ./cluster.json --drmaa " -q {cluster.lsf_q} {cluster.lsf_extra}"
```

If not:

```bash
snakemake -j2 -d /path/to/data/ --cluster-config ./cluster.json --cluster "bsub -q {cluster.lsf_q} {cluster.lsf_extra}"
```
