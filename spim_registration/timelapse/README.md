Fiji wiki entry
========================
You can find a wiki describing the workflow and a tutorial on how to use it here:

http://imagej.net/Automated_workflow_for_parallel_Multiview_Reconstruction

Citation
========================

Please note that the automated workflow for processing SPIM data on a cluster is based on a publication. If you use it successfully for your research please be so kind to cite the following work:
* C. Schmied, P. Steinbach, T. Pietzsch, S. Preibisch, P. Tomancak (2015) An automated workflow for parallel processing of large multiview SPIM recordings. Bioinformatics, Dec 1; doi: 10.1093/bioinformatics/btv706 http://bioinformatics.oxfordjournals.org/content/early/2015/12/30/bioinformatics.btv706.long


The automated workflow is based on the Fiji plugins Multiview Reconstruction and BigDataViewer|BigDataViewer. Please refer to and cite the following publications:
* S. Preibisch, S. Saalfeld, J. Schindelin and P. Tomancak (2010) Software for bead-based registration of selective plane illumination microscopy data, Nature Methods, 7(6):418-419. http://www.nature.com/nmeth/journal/v7/n6/full/nmeth0610-418.html
* S. Preibisch, F. Amat, E. Stamataki, M. Sarov, R.H. Singer, E. Myers and P. Tomancak (2014) Efficient Bayesian-based Multiview Deconvolution, Nature Methods, 11(6):645-648. http://www.nature.com/nmeth/journal/v11/n6/full/nmeth.2929.html
* T. Pietzsch, S. Saalfeld, S. Preibisch, P. Tomancak (2015) BigDataViewer: visualization and processing for large image data sets. Nature Methods, 12(6)481–483. http://www.nature.com/nmeth/journal/v12/n6/full/nmeth.3392.html

Datasets
========================
The scripts are now supporting multiple angles, multiple channels and multiple illumination direction without adjusting the Snakefile or .bsh scripts.

Using spimdata version: 0.9-revision

Using SPIM registration version 3.3.9

Supported datasets are in the following format:

Using Zeiss Lightsheet Z.1 Dataset (LOCI)

    Multiple timepoints:  YES (one file per timepoint) or (all time-points in one file)
    Multiple channels:  YES (one file per channel) or (all channels in one file)
    Multiple illumination directions: YES (one file per illumination direction)
    Multiple angles: YES (one file per angle)
    
Using LOCI Bioformats opener (.tif)

    Multiple timepoints: YES (one file per timepoint) or (all time-points in one file)
    Multiple channels: YES (one file per channel) or (all channels in one file)
    Multiple illumination directions: YES (one file per illumination direction) => not tested yet
    Multiple angles: YES (one file per angle)
    
Using ImageJ Opener (.tif):

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
/path/to/repository/spim_registration/timelapse/
├── README.md
├── Snakefile
├── cluster.json
├── config.yaml
├── deconvolution.bsh
├── define_czi.bsh
├── define_output.bsh
├── define_tif_zip.bsh
├── duplicate_transformations.bsh
├── export.bsh
├── export_output.bsh
├── fusion.bsh
├── registration.bsh 
├── timelapse_registration.bsh
├── timelapse_utils.py
├── transform.bsh		
└── xml_merge.bsh	 		
```

A data directory e.g. looks like this:

It contains the .yaml file for the specific dataset. You can either copy it, if you want to keep it together with the dataset, or make a symlink from the processing repository. 

```bash
/path/to/data/
├── exampleSingleChannel.czi
├── exampleSingleChannel(1).czi
├── exampleSingleChannel(2).czi
├── exampleSingleChannel(3).czi
├── exampleSingleChannel(4).czi
└── config.yaml	 		# copied/symlinked from this repo
```


* `config.yaml` contains the parameters that configure the beanshell scripts found in the data directory
* `Snakefile` from this directory
* `cluster.json` that resides in the same directory as the `Snakefile`
* cluster runs LSF

Tools
--------------

The tool directory contains scripts for common file format pre-processing.
Some datasets are currently only usable when resaving them into .tif:
* discontinous .czi datasets
* .czi dataset with multiple groups
* .ome.tiff files

The master_preprocesing.sh file is the configuration script that contains the information about the dataset that needs to be resaved. In the czi_resave directory you will find the the create-resaving-jobs.sh script that creates a job for each TP. The submit-jobs script sends these jobs to the cluster were they call the resaving.bsh script. The beanshell then uses executes the Fiji macro and resaves the files. The resaving of czi files is using LOCI bioformats and preserves the metadata. 

```bash
/path/to/repository/spim_registration/tools/
├── czi_resave/
    ├── create-resaving-jobs.sh
    ├── resaving.bsh
    └── submit-jobs
├── ometiff_resave/
    ├── create-ometiff_resave.sh
    ├── ometiff_resave.bsh
    └── submit-jobs
└──  master_preprocessing.sh
```
cluster_tools directory
--------------
The cluster tools directory contains the libraries for GPU deconvolution and the virtual frame buffer (xvfb) for running Fiji headless. 

```bash
libFourierConvolutionCUDALib.so
xvfb-run
```

sysconfcpus
--------------

We use Libsysconfcpus (http://www.kev.pulo.com.au/libsysconfcpus/)  to restrict how many cores Fiji is using on the cluster.

Compile with:
```bash
 CFLAGS=-ansi ./configure --prefix=$PREFIX
 make
 make install
```

where PREFIX is the installation directory.
ANSI mode is necessary when compiling with our default GCC version, 4.9.2.
It may or may not be necessary with older versions.

Command line
--------------

It is very likely that the cluster computer does not run ANY Graphical User Interface and relies exclusively on the command line. Steering a cluster from the command line is fairly easy - I use about 10 different commands to do everything I need to do. Since the Linux command line may be unfamiliar to most biologists we start a separate http://imagej.net/Linux_command_line_tutorial and http://swcarpentry.github.io/shell-novice/ page that explains the bare essentials.

workflow
--------------

The current workflow consists of the following steps. It covers the prinicipal processing for timelapse multiview SPIM processing:

1. define czi or tif dataset.

2. resave into hdf5.

3. detect and register interest points.

4. merge xml, creates XML for registered dataset. 

5. timelapse registration.

6. optional for dual channel dataset: duplicate transformations

7. optional for deconvolution: external transformation

8. average-weight fusion/deconvolution

9. define output

10. resave output into hdf5, creates XML for fused dataset.

Initial setup of the workflow
--------------
After you cloned the snakemake-workflows repository you need to configure the config.yaml for your setup.
This means you need to specify the directory for your Fiji, the location of the xvfb-run and the location for the GPU deconvolution libraries. 
Go into the timelapse directory of the snakemake-workflows and open the config.yaml with your preferred editor for example nano and change the settings in section 7. Software directories:

```bash
cd snakemake-workflows/spim_registration/timelapse/
nano config.yaml
```

```bash
 # ============================================================================
  # 7. Software directories
  # 
  # Description: paths to software dependencies of processing
  # Options: Fiji location
  #          beanshell and snakefile diretory
  #          directory for cuda libraries
  #          xvfb setting
  #          sysconfcpus setting
  # ============================================================================
  # current working Fiji
  fiji-app: "/sw/users/schmied/packages/2015-06-30_Fiji.app.cuda/ImageJ-linux64",
  # bean shell scripts and Snakefile
  bsh_directory: "/projects/pilot_spim/Christopher/snakemake-workflows/spim_registration/timelapse/",
  # Directory that contains the cuda libraries
  directory_cuda: "/sw/users/schmied/cuda/",
  # xvfb 
  fiji-prefix: "/sw/users/schmied/packages/xvfb-run -a",       # calls xvfb for Fiji headless mode
  sysconfcpus: "sysconfcpus -n",
  memory-prefix: "-Xmx"
```

After this initial setup you can proceed to modify the ''config.yaml'' for your specific dataset.

 Setup for the dataset
--------------
The entire processing is controlled via the yaml file.

In the first part (common) of the config.yaml file the key parameters for the processing are found.
These parameters are usually dataset and user dependent.
The second part contains the advanced and manual overrides for each processing step. These steps correspond to the rules in the snakefile.

A tutorial for modifying the config.yaml for your dataset you can find here:
http://imagej.net/Automated_workflow_for_parallel_Multiview_Reconstruction#Setup_for_the_dataset

Submitting Jobs
---------------
We recommend to execute Snakemake within screen (https://www.gnu.org/software/screen/manual/screen.html). 
To execute Snakemake you need to call Snakemake, specify the number of jobs, the location of the data and to dispatch jobs to a cluster with the information for the queuing system. Here is a list of commands and flags that are used for the Snakemake workflow:

Local back end:
/path/to/snakemake/snakemake -j 1 -d /path/to/data/

Flag for number of jobs run in parallel:
-j <number of jobs>

Flag for specifying data location:
-d /path/to/data/

Flag for dry run of snakemake:
-n

Force the execution of a rule:
-R <name of rule>

For DRMAA back end add: 
--drmaa " -q {cluster.lsf_q} {cluster.lsf_extra}"

For Lsf backend add:
--cluster "bsub -q {cluster.lsf_q} {cluster.lsf_extra}”

To specify the configuration script for the queuing system:
--cluster-config ./cluster.json

To save error and output files of cluster add:
--drmaa " -q {cluster.lsf_q} {cluster.lsf_extra} -o test.out -e test.err"
--cluster "bsub -q {cluster.lsf_q} {cluster.lsf_extra} -o test.out -e test.err“


The commands to execute snakemake would then look like this:

If DRMAA is supported on your cluster:

```bash
/path/to/snakemake/snakemake -j 2 -d /path/to/data/ --cluster-config ./cluster.json --drmaa " -q {cluster.lsf_q} {cluster.lsf_extra}"
```

If not:

```bash
/path/to/snakemake/snakemake -j 2 -d /path/to/data/ --cluster-config ./cluster.json --cluster "bsub -q {cluster.lsf_q} {cluster.lsf_extra}"
```

For error and output of the cluster add -o test.out -e test.err e.g.:

DRMAA
```bash
/path/to/snakemake/snakemake -j 2 -d /path/to/data/ --cluster-config ./cluster.json --drmaa " -q {cluster.lsf_q} {cluster.lsf_extra} -o test.out -e test.err"
```

LSF
```bash
/path/to/snakemake/snakemake -j 2 -d /path/to/data/ --cluster-config ./cluster.json --cluster "bsub -q {cluster.lsf_q} {cluster.lsf_extra} -o test.out -e test.err"
```

Note:  the error and output of the cluster of all jobs are written into these files.

Log files and supervision of the pipeline
---------------
The log files are written into a new directory in the data directory called "logs".
The log files are ordered according to their position in the workflow. Multiple or alternative steps in the pipeline are indicated by numbers. 

force certain rules:
use the -R flag to rerun a particular rule and everything downstream
-R <name of rule>
