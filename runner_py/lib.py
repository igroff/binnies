import os
import stat
import time
import signal
import logging
from managed_process import ManagedProcess

def find_executables_in(this_dir):
    files = os.listdir(this_dir)
    executables = []
    for file in files:
        if os.stat(file)[stat.ST_MODE] & stat.S_IXUSR:
            executables.append(file)
    return executables


def start_child_process_from(this_path):
    process = ManagedProcess(this_path)
    logging.info("started executable [%d] %s" % (process.popen.pid, this_path))
    return process

def shutdown_processes_gracefully(these_processes):
    def terminate(this_process):
        logging.info("terminating process: %s" % (this_process.executable_path))
        this_process.send_signal(signal.SIGTERM)
    def kill_with_fire(this_process):
        def alarm_handler(signum, frame):
            logging.warn("process %s didn't respond to terminate in a timely fashion. killing it" % (
                this_process.executable_path
            ))
            try:
                this_process.kill()
            except OSError, oe:
                if oe.errno == 3:
                    logging.debug("no process having pid %d found, it may have died already" % (this_process.pid))
        signal.alarm(5)
        signal.signal(signal.SIGALRM, alarm_handler)
        this_process.wait()
        signal.alarm(0)
    [ terminate(process) for process in these_processes ]
    [ kill_with_fire(process) for process in these_processes if not process.poll() ]
    

