#!/bin/bash
#===============================================================================
#
#	  FILE: master_preprocessing.sh
#
#  DESCRIPTION: source file for pre-processing of file formats
#
#       AUTHOR: Christopher Schmied, schmied@mpi-cbg.de
#    INSTITUTE: Max Planck Institute for Molecular Cell Biology and Genetics
#         BUGS:
#        NOTES:
#      Version: 1.0
#      CREATED: 2015-07-05
#     REVISION: 2015-07-05
#
# Preprocessing
#	resave single channel and dual channel .czi files into .tif
#	output: img_TL{t}_Angle{a}.tif
#	channels are 0,1 etc
# 
#===============================================================================
# directory of data, don't forget / at the end!
image_file_directory="/projects/pilot_spim/Christopher/test_pipeline/single_channel/czi/"

# --- jobs directory -----------------------------------------------------------
job_directory="/projects/pilot_spim/Christopher/snakemake-workflows/spim_registration/tools/"
#-------------------------------------------------------------------------------
# Resaving, Renaming files: General
#
# Important: For renaming and resaving .czi files the first .czi file has to
# carry the index (0)
#-------------------------------------------------------------------------------
first_file="2015-02-21_LZ1_Stock68_3.czi" # name of the first czi or ometiff file
timepoints="`seq 1 2`" # number of time points format: "`seq 0 1`"
angles="1 2 3 4 5" # angles format: "1 2 3"
pad="2"		# for padded zeros
first_timepoint="1"	# First .tif needs to start with 0 for workflow
#-------------------------------------------------------------------------------
# Fiji settings
#-------------------------------------------------------------------------------
XVFB_RUN="/sw/bin/xvfb-run -a" # virtual frame buffer
sysconfcpus="sysconfcpus -n 2"
Fiji="/sw/users/schmied/packages/2015-06-30_Fiji.app.cuda/ImageJ-linux64"	# Fiji version for .czi resave
Fiji_ometiff="/sw/users/schmied/packages/2015-10-20_Fiji.app.cuda/ImageJ-linux64" # Fiji version for ometiff resave
#-------------------------------------------------------------------------------
# Pre-processing
#-------------------------------------------------------------------------------
#--- Resaving .czi into .tif files----------------------------------------------
jobs_resaving=${job_directory}"czi_resave"  	# directory .czi resaving
resaving=${jobs_resaving}"/resaving.bsh" 	# script .czi resaving
#--- Resaving .ometiff into .tif -----------------------------------------------
jobs_ometiff=${job_directory}"ometiff_resave"	# directory for ometiff resaving
ometiff_resave=${jobs_ometiff}"/ometiff_resave.bsh"	# script for ometiff resaving

