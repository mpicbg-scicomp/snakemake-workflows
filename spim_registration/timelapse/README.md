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

workflow
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



Preparations for processing
--------------
The entire processing is controlled via the yaml file.

In the first part (common) of the yaml file the key parameters for the processing are found.
These parameters are usually dataset and user dependent.

1. Software directories
2. Processing switches

    2.1. Switch between all channels contain beads and one channel of two contains beads
    
    2.2. Switch between fusion and deconvolution 
    
4. Define dataset
5. Detection and registration
6. Timelapse registration
7. Weighted-average fusion
8. Multiview deconvolution

    8.1. External transformation
    
    8.2. Deconvolution settings 

```bash
common: {
  # ============================================================================
  #
  # yaml example file for single channel processing
  #
  # General settings for processing
  #
  # ============================================================================
  # directory that contains the bean shell scripts and Snakefile
  bsh_directory: "/projects/pilot_spim/Christopher/snakemake-workflows/spim_registration/timelapse/",
  # Directory that contains the cuda libraries
  directory_cuda: "/sw/users/schmied/cuda/",
  # Directory that contains the current working Fiji
  fiji-app: "/sw/users/schmied/packages/2015-06-30_Fiji.app.cuda/ImageJ-linux64",
  fiji-prefix: "/sw/users/schmied/packages/xvfb-run -a",       # calls xvfb for Fiji headless mode
  sysconfcpus: "sysconfcpus -n",
  # ============================================================================
  # Processing switches
  # Description: Use switches to decide which processing steps you need:
  #
  # Options:
  #           transformation_switch: "timelapse",
  #           goes directly into fusion after timelapse registration
  #
  #           transformation_switch: "timelapse_duplicate",
  #           for dual channel processing one channel contains the beads
  #           dublicates the transformation from the source channel to the 
  #           target channel
  #
  #           Switches between content based fusion and deconvoltion
  #           fusion_switch: "deconvolution", > for deconvolution
  #           fusion_switch: "fusion", > for content based fusion
  # ============================================================================
  # Transformation switch:
  transformation_switch: "timelapse",
  # Fusion switch:
  fusion_switch: "deconvolution",
  # ============================================================================
  # xml file name
  # 
  # Description: xml file name without .xml suffix
  # ============================================================================
  hdf5_xml_filename: '"single"', 
  # ============================================================================
  # Describe the dataset
  #
  # Options: number of timepoints
  #          angles
  #          channels
  #          illuminations
  #          Settings for .czi or .tif files
  # ============================================================================
  ntimepoints: 90,        # number of timepoints of dataset
  angles: "0,72,144,216,288",   # format e.g.: "0,72,144,216,288",
  channels: "green",     # format e.g.: "green,red", IMPORTANT: for tif numeric!
  illumination: "0",     # format e.g.: "0,1",
  # ----------------------------------------------------------------------------
  # Settings for .czi files
  first_czi: "2015-02-21_LZ1_Stock68_3.czi", 
  # ----------------------------------------------------------------------------
  # Settings for .tif datasets
  # Options: 
  #          file pattern of .tif files:
  #          multi channel with one file per channel: 
  #          spim_TL{tt}_Angle{a}_Channel{c}.tif
  #          for padded zeros use tt 
  image_file_pattern: 'img_TL{{t}}_Angle{{a}}.tif',
  multiple_channels: '"NO (one channel)"',         # '"YES (all channels in one file)"' or '"YES (one file per channel)"' or '"NO (one channel)"'
  # ============================================================================
  # Detection and registration
  #
  # Description: settings for interest point detection and registration
  # Options: Single channel and dual channel processing
  #          Source and traget for dual channel one channel contains the beads
  #          Interestpoints label
  #          Difference-of-mean or difference-of-gaussian detection
  # ============================================================================
  # reg_process_channel:
  # Single Channel: '"All channels"'
  # Dual Channel: '"All channels"'
  # Dual Channel one Channel contains beads: '"Single channel (Select from List)"'
  reg_process_channel: '"All channels"',
  #
  # Dual channel 1 Channel contains the beads: which channel contains the beads?
  # Ignore if Single Channel or Dual Channel both channels contain beads
  source_channel: "red", # channel that contains the beads
  target_channel: "green", # channel without beads
  # reg_interest_points_channel:
  # Single Channel: '"beads"'
  # Dual Channel: '"beads,beads"'
  # Dual Channel: Channel does not contain the beads '"[DO NOT register this channel],beads"'
  reg_interest_points_channel: '"beads"',
  #
  # type of detection: '"Difference-of-Mean (Integral image based)"' or '"Difference-of-Gaussian"'
  type_of_detection: '"Difference-of-Gaussian"',
  # Settings for Difference-of-Mean
  # For multiple channels 'value1,value2' delimiter is ,
  reg_radius_1: '2',
  reg_radius_2: '3',
  reg_threshold: '0.005',
  # Settings for Difference-of-Gaussian
  # For multiple channels 'value1,value2' delimiter is ,
  sigma: '1.3',
  threshold_gaussian: '0.025',
  # ============================================================================
  # Timelapse registration
  #
  # Description: settings for timelapse registration
  # Options: reference timepoint
  # ============================================================================
  reference_timepoint: '1',   # Reference timepoint
  # ============================================================================
  # Content-based multiview fusion
  #
  # Description: settings for content-based multiview fusion
  # Options: downsampling
  #          Cropping parameters based on full resolution
  # ============================================================================
  downsample: '2',    # set downsampling
  minimal_x: '190',   # Cropping parameters of full resolution
  minimal_y: '-16',
  minimal_z: '-348',
  maximal_x: '1019',
  maximal_y: '1941',
  maximal_z: '486',
  # ============================================================================
  # External transformation switch
  #
  # Description: Allows downsampling prior deconvolution
  # Options: no downsampling 
  #          external_trafo_switch: "_transform",
  #
  #          downsampling
  #          external_trafo_switch: "external_trafo",
  #          IMPORTANT: boundingbox needs to reflect this downsampling. 
  #
  #          Matrix for downsampling
  # ============================================================================
  # External transformation switch:
  external_trafo_switch: "_transform",
  #
  # Matrix for downsampling
  matrix_transform: '"0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0"',
  # ============================================================================
  # Multiview deconvolution
  #
  # Description: settings for multiview deconvolution
  # Options: 
  #          number of iterations
  #          Cropping parameters taking downsampling into account!
  #          Channel settings for deconvolution
  # ============================================================================
  iterations: '20',        # number of iterations
  minimal_x_deco: '95',  # Cropping parameters: take downsampling into account
  minimal_y_deco: '-8',
  minimal_z_deco: '-174',
  maximal_x_deco: '509',
  maximal_y_deco: '970',
  maximal_z_deco: '243',
  # Channel settings for deconvolution
  # Single Channel: '"beads"'
  # Dual Channel: '"beads,beads"'
  # Dual Channel one channel contains beads: '"[Same PSF as channel red],beads"'
  detections_to_extract_psf_for_channel: '"beads"'
  }
```

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


