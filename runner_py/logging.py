import sys
from datetime import datetime

def output(message):
    sys.stdout.write("%s %s\n" % (datetime.utcnow().isoformat(), message))

log = output
error = output
info = output
warn = output
debug = output

