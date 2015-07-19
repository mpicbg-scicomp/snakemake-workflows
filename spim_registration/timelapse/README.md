Datasets
========================
The scripts are now supporting multiple angles, multiple channels and multiple illumination direction without adjusting the Snakefile or .bsh scripts.

Using spimdata version: 0.9-revision
Using SPIM registration version 3.3.9

Supported datasets are in the following format:

Using Zeiss Lightsheet Z.1 Dataset (LOCI)

    Multiple timepoints:  YES (one file per timepoint) or (all time-points in one file)
    Multiple channels:  YES (one file per timepoint) or (all time-points in one file)
    Multiple illumination directions: YES (one file per illumination direction)
    Multiple angles: YES (one file per angle)
    
Using LOCI Bioformats opener (.tif)

    Multiple timepoints: YES (one file per timepoint) or (all time-points in one file)
    Multiple channels: YES (one file per timepoint) or (all time-points in one file)
    Multiple illumination directions: YES (one file per illumination direction) => not tested yet
    Multiple angles: YES (one file per angle)
    
Using ImageJ Opener (resave to .tif):

    Multiple timepoints: YES (one file per timepoint)
    Multiple channels: YES (one file per channel)
    Multiple illumination directions: YES (one file per illumination direction) => not tested yet
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

It contains the .yaml file for the specific dataset. You can either copy it, if you want to keep it together with the dataset, or make a symlink from the processing repository. 

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

The master_preprocesing.sh file is the configuration script that contains the information about the dataset that needs to be resaved. In the czi_resave directory you will find the the create-resaving-jobs.sh script that creates a job for each TP. The submit-jobs script sends these jobs to the cluster were they call the resaving.bsh script. The beanshell then uses executes the Fiji macro and resaves the files. The resaving of czi files is using LOCI bioformats and preserves the metadata. 

```bash
/path/to/repo/tools
├── master_preprocessing.sh
├── czi_resave
    ├── create-resaving-jobs.sh
    ├── resaving.bsh
    └── submit-jobs
```

Processing
--------------

The current workflow consists of the following steps. It covers the prinicipal processing for timelapse multiview SPIM processing:

* define czi or tif dataset
* resave into hdf5
* detect and register interespoints
* merge xml
* timelapse registration
* optional for dual channel dataset: dublicate transformations
* optional for deconvolution: external transformation
* average-weight fusion/deconvolution
* define output
* resave output into hdf5

The entire processing is controlled via the yaml file. 

Preparations for processing
--------------


Submitting Jobs
---------------

If DRMAA is supported on your cluster:

```bash
/path/to/snakemake/snakemake -j2 -d /path/to/data/ --cluster-config ./cluster.json --drmaa " -q {cluster.lsf_q} {cluster.lsf_extra}"
```

If not:

```bash
/path/to/snakemake/snakemake -j2 -d /path/to/data/ --cluster-config ./cluster.json --cluster "bsub -q {cluster.lsf_q} {cluster.lsf_extra}"
```

For error and output of the cluser add -o test.out -e test.err e.g.:

DRMAA
```bash
/path/to/snakemake/snakemake -j2 -d /path/to/data/ --cluster-config ./cluster.json --drmaa " -q {cluster.lsf_q} {cluster.lsf_extra} -o test.out -e test.err"
```

LSF
```bash
/path/to/snakemake/snakemake -j2 -d /path/to/data/ --cluster-config ./cluster.json --cluster "bsub -q {cluster.lsf_q} {cluster.lsf_extra} -o test.out -e test.err"
```

Note:  the error and output of the cluster of all jobs are written into these files. 

Log files and supervision of the pipeline
---------------

The log files are written into a new directory in the data directory called "logs".
The log files are ordered according to their position in the workflow. Multiple or alternative steps in the pipeline are indicated by numbers. 

force certain rules:
use the -R flag to rerun a particular rule and everything downstream
-R <name of rule>


