Datasets
========================
The scripts are now supporting multiple angles, multiple channels and multiple illumination direction without adjusting the Snakefile or .bsh scripts.

Based on SPIM registration version 3.3.9

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
Clone the repository:

The repository contains the example configuration scripts for single and dual channel datasets, the Snakefile which defines the workflow, the beanshell scripts which drive the processing via Fiji and a cluster.json file which contains information for the cluster queuing system. 

```bash
/path/to/repo/timelapse
├── single_test.yaml
├── dual_OneChannel.yaml
├── Snakefile
├── cluster.json
├── define_tif_zip.bsh
├── define_czi.bsh
├── registration.bsh
├── deconvolution.bsh
├── transform.bsh	 		
├── registration.bsh 		
└── xml_merge.bsh	 		
```

A data directory e.g. looks like this:

It contains the .yaml file for the specific dataset. You can either copy it if you want to keep it together with the dataset or make a symlink from the processing repository. 

```bash
/path/to/data
├── dataset.czi
├── dataset(1).czi
├── dataset(2).czi
├── dataset(3).czi
├── dataset(4).czi
└── dataset.yaml	 		# copied/symlinked from this repo
```


* `tomancak.yaml` contains the parameters that configure the beanshell scripts found in the data directory
* `Snakefile` from this directory
* `cluster.json` that resides in the same directory as the `Snakefile`
* cluster runs LSF

Tools: 
--------------

The tool directory contains scripts for common file format pre-processing.
Some datasets are currently only usable when resaving them into .tif:
* discontinous .czi datasets
* .czi dataset with multiple groups

The master_preprocesing.sh file is the configuration script that contains the information about the dataset that needs to be resaved or split. rename-zeiss-file.sh is renaming the .czi files into the .tif naming convention for SPIM processing: SPIM_TL{t}_Angle{a}.tif. The different resaving steps are then carried out by creating the jobs and submitting them to the cluster.

```bash
/path/to/repo/tools
├── master_preprocessing.sh
├── rename-zeiss-file.sh
├── compress
    ├── create-compress-jobs.sh
    ├── for_czi.bsh
    └── submit-jobs
├── czi_resave
    ├── create-resaving-jobs.sh
    ├── resaving.bsh
    └── submit-jobs
└──  split_channels
    ├── create-split-jobs.sh
    ├── split.bsh
    └── submit.jobs
```

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
Log files and supervision of the pipeline
---------------

The log files are written into a new directory in the data directory called "logs".
The log files are ordered according to their position in the workflow. Multiple or alternative steps in the pipeline are indicated by numbers. 
