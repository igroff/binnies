#! /usr/bin/env python
from circuits import Component, Event

"""
    Definitions
    Managed Process or Process - a process whos lifecycle is being managed by us. This 
        implies a currently executing process, until it starts it's something
        else.

    Managed Process Group - all of the processes started from a particular 
        Executable.

    Executable - an executable file watched by us ( as distinguished from
        some random executable file elsewhere on the file system )
    
    Managed Process Group State - a construct for tracking the state of a
        managed process group such as the numbe of processes running, number
        that should be running, respawn characteristics etc.
"""

class command_received(Event):
    """command Event used solely by the CommandParser to notify it that a
       raw command has been received. The parser, in turn, will turn it
       into the appropriate event."""

class start_process(Event):
    """start_process Event used to request that a process be started"""

class stop_process(Event):
    """stop_process EVent"""

class stop_all_processes(Event):
    """stop_all_processes Event, initiates the shutdown of all ManagedProcesses"""

class stop_all_processes_of_type(Event):
    """stop_all_processes_of_type Event, stops all the processes of a particular type"""


class list_all_managed_processes(Event):
    pass

class list_all_managed_processes_for_executable(Event):
    pass

class process_exited(Event):
    """process_exited EVent used to indicate the exit of a ManagedProcess"""

class process_started(Event):
    """process_started Event"""

class Application(Component):
    """Application"""
    channel = "runner"
    
    def started(self, component):
        self.fire(command()) 

    def command(self):
        print("Command received")

class ProcessManager:
    """Manages processes (ManagedProcesses) throughout their lifecycle.
    """

class Spawner:
    """ Solely responsible for spawing requested processes, and hooking things
        up accordingly.
    """

class ConfigWatcher:
    """Since the configuration for this product is nothing more than a directory full
       of executables, this essentially watches a directory and determines what
       events need to be raised.
    """

class CommandParser:
    """This guy is responsible for receiving inbound commands and 
       turning them into the appropriate events
    """


print(command().name)
Application().run()
