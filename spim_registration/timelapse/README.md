Timelapse based workflow
========================

Expected setup
--------------

* a data directory e.g. looks like this
```bash
/path/to/data
├── deconvolution_CPU.bsh	# copied/symlinked from this repo
├── deconvolution_GPU.bsh	# copied/symlinked from this repo
├── hdf5_test_unicore-00-00.h5
├── hdf5_test_unicore-01-00.h5
├── hdf5_test_unicore.h5
├── hdf5_test_unicore.xml
├── registration.bsh 		# copied/symlinked from this repo
├── tomancak.json	 		# copied/symlinked from this repo
├── transform.bsh	 		# copied/symlinked from this repo
└── xml_merge.bsh	 		# copied/symlinked from this repo
```

* `tomancak.json` contains the parameters that configure the beanshell scripts found in the data directory
* `Snakefile` from this directory
* `cluster.json` that resides in the same directory as the `Snakefile`



Submitting Jobs
---------------

```bash
snakemake -j2 -d /path/to/data/ --cluster-config ./cluster.json --drmaa " -q {cluster.lsf_q} {cluster.lsf_extra}"
```
