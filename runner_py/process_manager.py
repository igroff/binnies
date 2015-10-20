import os
import stat
import time
import signal
import logging
from circuits import Component, handler

from events import add_process, process_terminated, process_list
from managed_process import ManagedProcess

def start_child_process_from(this_path):
    process = ManagedProcess(this_path)
    logging.info("started executable [%d] %s" % (process.popen.pid, this_path))
    return process

def shutdown_processes_gracefully(these_processes):
    def terminate(this_process):
        logging.info("terminating process: %d" % (this_process.pid))
        this_process.send_signal(signal.SIGTERM)
    def kill_with_fire(this_process):
        def alarm_handler(signum, frame):
            logging.warn("process %s didn't respond to terminate in a timely fashion. killing it" % (
                this_process.pid
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
    # first we ask all the processes, nicely, to quit
    [ terminate(process) for process in these_processes ]
    # then we go ahead and wait for them for 5 seconds
    signal.alarm(5)
    signal.signal(signal.SIGALRM, lambda: 1)
    [ process.wait() for process in these_processes ]
    signal.alarm(0)
    # if anyone isn't yet dead we will give them a bit more time and murdalate them
    [ kill_with_fire(process) for process in these_processes if process.poll() ]

class ProcessManager(Component):
    """This guy listens for process related events and tries to make sure
       those requests are met
    """

    managed_processes = []

    def __init__(self):
        super(ProcessManager, self).__init__(self)
        # we would like to know of state changes involving our spawned processes
        signal.signal(signal.SIGCHLD, self.child_signal_handler)

    def child_signal_handler(self, signum, frame):
        dead_ones = {}
        for process in self.managed_processes:
            if not process.poll():
                dead_ones[process.pid] = process
                logging.info("removing dead process %d" % (process.pid))
                self.fire(add_process(path_to_executable=process.path_to_executable))
        self.managed_processes = [ process for process in self.managed_processes if process.pid not in dead_ones ]

    def add_process(self, path_to_executable):
        self.managed_processes.append(start_child_process_from(path_to_executable))

    def list_processes(self):
        self.fire(process_list(self.managed_processes))

    @handler('application_shutdown')
    def shutdown_all(self):
        logging.debug(
            "ProcessManager handling application shutdown, preparing to shutdown %d processes" %
            (len(self.managed_processes))
        )
        signal.signal(signal.SIGCHLD, signal.SIG_IGN)
        shutdown_processes_gracefully(self.managed_processes)
