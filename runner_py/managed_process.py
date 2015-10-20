import os
import sys
import logging
import subprocess


class ManagedProcess:
    @staticmethod
    def _create_session():
        os.setsid()
    def __init__(self, path_to_executable):
        self.path_to_executable = path_to_executable
        self.popen = subprocess.Popen(
            [path_to_executable],
            stdout=sys.stdout,
            stderr=subprocess.STDOUT,
            preexec_fn=ManagedProcess._create_session,
            close_fds=True)
        self.pid = self.popen.pid
    def __getattr__(self, name):
        attribute = getattr(self.popen, name)
        if attribute:
            logging.debug("delegating to popen for %s" % (name))
            return attribute
        else:
            return object.__getattribute__(self, name)
    def wait(self):
        self.returncode = self.popen.wait()
    def poll(self):
        self.returncode = self.popen.poll()
