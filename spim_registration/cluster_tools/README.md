# required cluster tools

This directory contains binaries or scripts that can and sometimes must be used by the spim_registration workflow. 

## libFourierConvolutionCUDALib.so

Binary version of the CUDA enabled convolution library (required CUDA and Cufft to be installed). The source code for this library can be found at :

[https://github.com/StephanPreibisch/FourierConvolutionCUDALib]


## xvfb-run 

xvfb-run is required so that fiji can run in headless mode on your cluster. the funny thing is, fiji's headless mode requires an active X session under Linux. Please install the `xorg-x11-server-Xvfb` package (under CentOS) and use the patched xvfb-run that we provide here:

[https://git.mpi-cbg.de/steinbac/xvfb-run-patches.git]
