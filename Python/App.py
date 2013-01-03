import os, sys
import argparse
import yaml

class App:
    def __init__(self):
        self.parser = argparse.ArgumentParser()
        self.parser.add_argument('-i', dest = 'input', default = None)
        self.args_parsed = None
        self.args = None
        self.vars = None
        self.input_is_yaml = True

    def add_argument(self, arg, **kwargs):
        self.parser.add_argument(arg, **kwargs)

    def read_yaml(self):
        if not self.args_parsed:
            self.args = self.parser.parse_args()

        if self.args.input:
            if os.access(self.args.input, os.R_OK):
                stream = file(self.args.input, 'r')
                try:
                    self.vars = yaml.load(stream)
                except ParserError:
                    pass

    def vars(self):
        if self.input_is_yaml and not self.vars:
            self.read_yaml()
        return self.vars
