import re
import os
import math

def produce_xml_merge_job_files(_datasets):
   fre = re.compile(r'(?P<xml_base>\w+)-(?P<file_id>\d+)-00.h5')
   value = []
   for ds in _datasets:
      bn = os.path.basename(ds)
      bn_res = fre.search(bn)
      if bn_res:
         xml_base,file_id = bn_res.group('xml_base'),bn_res.group('file_id')
         value.append("{xbase}.job_{fid}.xml".format(xbase=xml_base, fid=int(file_id)))

   return value


def produce_string(_fstring, *args, **kwargs):
   contents = dict()
   for item in args:
      if type(item) == type(kwargs):
         contents.update(item)
         
   contents.update(kwargs)
   return _fstring.format(**contents)

def padding_of_file_id(_n_timepoints):
   value = math.ceil(math.log10(_n_timepoints))

   if value < 2:
      return 2
   else:
      return value
