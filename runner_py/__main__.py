import os
import sys
import os.path
import signal
import logging
from circuits import Component
from circuits.io import File
from lib import find_executables_in, start_child_process_from, shutdown_processes_gracefully
from command_parser import CommandParser, FifoCommandReader
from process_manager import ProcessManager
from config_manager import ConfigManager
from events import application_shutdown, application_start

class Application(Component):
    """ Root Component """

    def signal(self, signum, stack):
        logging.debug("received signal %d" % (signum))
        if signal.SIGINT == signum:
            shutdown_event = application_shutdown()
            shutdown_event.complete = True
            self.fire(shutdown_event)

    def application_shutdown_complete(self, *args):
        os.unlink(self.runnerfifo_path)
        sys.exit(0)
    
    def process_list(self, processes):
        for process in processes:
            print("[%d] %s" % (process.pid, process.path_to_executable))

    def started(self, *args):
        self.directory_containing_exes = os.getcwd()
        self.runnerfifo_path = os.path.join(self.directory_containing_exes, ".runnerfifo")

        logging.info("my PID: %d" % (os.getpid()))

        logging.debug("creating command pipe at %s" % ( self.runnerfifo_path ))
        os.mkfifo(self.runnerfifo_path)

        CommandParser().register(self)
        FifoCommandReader(self.runnerfifo_path).register(self)
        ProcessManager().register(self)
        ConfigManager().register(self)

        self.fire(application_start(working_dir=self.directory_containing_exes))

if 'DEBUG' in os.environ:
    from circuits import Debugger
    (Debugger() + Application()).run()
else:
    Application().run()

