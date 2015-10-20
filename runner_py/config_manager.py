import os
import stat
from circuits import Component, Event
from events import add_process, application_start

def find_executables_in(this_dir):
    files = os.listdir(this_dir)
    executables = []
    for file in files:
        if os.stat(file)[stat.ST_MODE] & stat.S_IXUSR:
            executables.append(file)
    return executables

class ConfigManager(Component):
    def application_start(self, working_dir):
        for executable in sorted(find_executables_in(working_dir)):
            self.fire(add_process(path_to_executable=os.path.join(working_dir,executable)))
        
        


