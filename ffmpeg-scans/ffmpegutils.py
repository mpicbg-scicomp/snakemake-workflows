import os

def create_csv_with_header(_name, _header):
    if not os.path.exists(_name):
        with open(_name,'a') as csvout:
            header_str = ""
            if type(_header) == type(list()):
                header_str = ",".join(_header)
            else:
                header_str = _header
            if not header_str.endswith("\n"):
                header_str += "\n"
                
            csvout.write(header_str)


def mkdir_if_not_present(_path):
    if not os.path.exists(_path):
        os.mkdir(_path)
