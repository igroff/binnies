from circuits import Event

class bad_user_command(Event):
    """bad_user_command Event. Raised in response to an inbound command that is
     invalid or unrecognizable"""
    channels = "usercommands"

class user_command(Event):
    """user_command Event. Un parsed inbound user command."""
    channels = "usercommands"
    def __init__(self, json_string=None):
        self.json_string = json_string

class list_processes(Event):
    """list_processes Event. Requests that a list of proceses be generated"""

class process_list(Event):
    """process_list Event. In response to list_processes, this event contains
       the information about the managed processes
    """
    def __init__(self, processes):
        super(process_list, self).__init__(processes=processes)

class add_process(Event):
    """add_process Event. used to request another process instance be started from
        an executable
    """
    def __init__(self, path_to_executable):
        super(add_process, self).__init__(path_to_executable=path_to_executable)

class process_terminated(Event):
    """process_terminated Event. raised when a process exits"""
    def __init__(self, path_to_executable):
        super(add_process, self).__init__(path_to_executable=path_to_executable)

class shutdown_process(Event):
    """shutdown_process Event. Used to shutdown a process matching specific criteria"""
    def __init__(self, path_to_executable=None):
        super(add_process, self).__init__(path_to_executable=path_to_executable)
    

class application_shutdown(Event):
    """ application_shutdown Event. Issued as the application is shutting down to indicate that
        any listeners should perform cleanup duty and stop
    """

class application_start(Event):
    """ application_start Event. Issued when the application is initialized and ready to go."""
    def __init__(self, working_dir=None):
        super(application_start, self).__init__(working_dir=working_dir)
