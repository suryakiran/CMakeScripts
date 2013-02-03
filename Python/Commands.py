import os, types, sys
import argparse
import re

class Commands:
    def to_camel_case(self, *args, **kwargs):
        for a in args:
            print ''.join(map(lambda i: i.title(), a.split('_')))

    def split_string_on_upper_case(self, *args, **kwargs):
        l = re.findall('[A-Z][^A-Z]*', args[0])
        print '-'.join(map(lambda i: i.lower(), l))
    
    def make_executable(self, *args, **kwargs):
        f = args[0]
        if os.access(f, os.R_OK):
            os.chmod(f, 0755)

    def to_yaml_list(self, *args, **kwargs):
        indent = kwargs.get('level', 1)
        if type(indent) is not types.IntType:
            indent = 1
        cmake_list = kwargs.get('list')
        s = []
        if not cmake_list:
            print ''
        cmake_list = cmake_list.split(';')
        for item in cmake_list:
            s.append('%s- %s' % ('  '*indent, item))
        print '\n'.join(s)
                     
            
    def test(self, *args, **kwargs):
        print args
        print kwargs


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('-c', dest='command', required = True)
    p.add_argument('--arg', dest = 'extra', required = False, action = 'append')
    p.add_argument('args', nargs='*')
    a = p.parse_args()
    cmd = getattr(Commands(), a.command)
    if not cmd:
        raise Exception("%s not implemented" % a.command)
    d = {}
    if a.extra:
        print a.extra
        print sys.argv
        d = dict([arg.split('=') for arg in a.extra])
    cmd(*a.args, **d)
