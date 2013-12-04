#! /usr/bin/env python
from lxml import etree
from StringIO import StringIO

class StudioArticleContenParser:
    """ this is an attempt to have something that mimics the article gateway bs """
    def __init__(self, buffer=StringIO()):
        self.content = buffer
        self.current_tag = None
        self.in_title = False
        self.in_section = False

    def start(self, tag, attrib):
        if tag == 'Section':
            self.in_section = True
        if tag == 'Title':
            self.in_title = True
        self.current_tag = tag
    
    def end(self, tag):
        self.current_tag = None
        if tag == 'Title':
            self.in_title = False
        if tag == 'Section':
            self.in_section = False

    def data(self, data):
        if self.in_section and self.current_tag == 'Text':
            self.content.write("%s\n\n" % data)
        elif self.current_tag == 'Title' \
            and self.data \
            and self.in_section \
            and not data.startswith("Step"):
            self.content.write("%s\n\n" % data) 

    def comment(self, text):
        pass

    def close(self):
        pass

if __name__ == "__main__":
    content_handler = StudioArticleHandler()
    parser = etree.XMLParser(target = content_handler)
    f = open("xml_test.xml")
    result = etree.fromstring(f.read(), parser)
    print content_handler.content.getvalue()

