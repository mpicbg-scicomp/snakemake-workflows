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
#	1) rename .czi files
#	2) resave .czi files into .tif or .zip
#	3) resave ome.tiff files into .tif
#	4) Splitting output for Channel is
#		c=0,1 etc
#		spim_TL{tt}_Angle{a}_Channel{c}.tif
#===============================================================================
image_file_directory="/projects/pilot_spim/Christopher/cluster_test_HisYFP/2013-11-14_His-YFP_2/"

# --- jobs directory -----------------------------------------------------------
job_directory="/projects/pilot_spim/Christopher/snakemake-workflows/spim_registration/tools/"
#-------------------------------------------------------------------------------
# Resaving, Renaming files and Splitting: General
#
# Important: For renaming and resaving .czi files the first .czi file has to
# carry the index (0)
#-------------------------------------------------------------------------------
first_czi_name="2013-11-14_His-YFP_2.czi"
timepoints="`seq 1 2`" # number of time points format: "`seq 0 1`"
angles="1 2 3 4 5" # angles format: "1 2 3"
stack_size="142"
pad="2"		# for padded zeros
first_timepoint="0"	# Starts with 0
#-------------------------------------------------------------------------------
# Fiji settings
#-------------------------------------------------------------------------------
XVFB_RUN="/sw/bin/xvfb-run -a" # virtual frame buffer
sysconfcpus="sysconfcpus -n 2"
Fiji="/sw/users/schmied/packages/2015-06-30_Fiji.app.cuda/ImageJ-linux64"
#-------------------------------------------------------------------------------
# Pre-processing
#-------------------------------------------------------------------------------
#--- Resaving .czi into .tif files----------------------------------------------
jobs_resaving=${job_directory}"czi_resave"  	# directory .czi resaving
resaving=${jobs_resaving}"/resaving.bsh" 	# script .czi resaving
#--- Resaving ome.tiff into .tif files -----------------------------------------
jobs_resaving_ometiff=${job_directory}"ometiff_resave" 	 # directory .ome.tiff resaving
resaving_ometiff=${jobs_resaving_ometiff}"/resaving-ometiff.bsh" # script .ome.tiff resaving
#--- Compress dataset;----------------------------------------------------------
jobs_compress=${job_directory}"compress" 	# directory .czi to .zip resaving
czi_compress=${jobs_compress}"/for_czi.bsh" 	# script .czi to .zip resaving
#--- Split channels-------------------------------------------------------------
jobs_split=${job_directory}"split_channels" 			# directory
split=${jobs_split}"/split.bsh" 				# script
