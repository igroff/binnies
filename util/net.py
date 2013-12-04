import subprocess
import sys
import tempfile
import os
import uuid

def curl(*args, **kwargs):
    """ provides for the invocation of /usr/bin/curl args are passed as is as 
    command line parameters to curl.  kwargs will be passed as key,kwargs[key]
    pairs using curl --data-urlencode parameter.  the data from kwargs[key] will
    be written first to a file and then supplied to curl via --data-urlencode.  the
    result of the curl invocation is returned to the caller ( this is what curl writes
    to stdout ).
    """
    # building the 'command line'
    curl_path = '/usr/bin/curl'
    curl_list = [curl_path]
    for arg in args:
        curl_list.append(arg)

    # if we have some kwargs we're going to send them as key value pairs
    # via --data-urlencode with the data stuffed in a temp file
    if kwargs.keys():
        for key in kwargs.keys():
            tfn = os.path.join(tempfile.gettempdir(), str(uuid.uuid4()))
            with open(tfn, "w") as tf:
                tf.write(kwargs[key])
            curl_list.append("--data-urlencode")
            curl_list.append("%s@%s" % (key, tfn))
    #sys.stderr.write("%s\n" % " ".join(curl_list))
    
    # invoke curl, and get the resulting output end error streams
    curl_result = subprocess.Popen(
                 curl_list,
                 stderr=subprocess.PIPE,
                 stdout=subprocess.PIPE).communicate()

    if curl_result[1]: # stderr
        sys.stderr.write(curl_result[1])
    return curl_result[0]
