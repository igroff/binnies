#! /usr/bin/env python
# vi:ft=python

import json
import events
import logging
from circuits.io.file import File
from circuits import Component, handler

import logging
from events import bad_user_command, add_process

class CommandParser(Component):
    channel = "usercommands"

    @handler("read")
    def inbound_command(self, json_message):
        logging.debug("received command: %s" % (json_message))
        try:
            message = json.loads(json_message)
            if not 'name' in message:
                logging.error("no name on command: %s" % (json_message))
                self.fire(bad_user_command, "no name on command: %s"  % (json_message))
                return
            if not message['name'] in events.__dict__:
                logging.error("no command named [%s] found." % (json_message.name))
                self.fire(bad_user_command, "no command named %s" % (json_message.name))
                return
            real_event = events.__dict__[message['name']]
            del(message['name'])
            logging.debug("firing event named %s of type %s with args: %s" % (real_event.name, type(real_event), message))
            self.fire(real_event(**message), "*")
        except Exception, e:
            logging.error("bad command: %s\n%s" % (json_message, e))
            self.fire(bad_user_command(e)) 

class FifoCommandReader(File):
    channel = "usercommands"
    def __init__(self, *args):
        """ this is a bit like voodoo, but we have to add the + to get circuits to not
            close the file on read which, since this is a pipe for commands would be
            dumb.
        """
        super(FifoCommandReader, self).__init__(*args, mode='r+')

    def shutdown_application(self, *args, **kwargs):
        self.close()

