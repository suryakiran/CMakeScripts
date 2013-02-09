import os, sys
import argparse

p = argparse.ArgumentParser(prog='get-properties')
p.add_argument('-o', dest='output', required=True)
p.add_argument('-p', dest='properties', action='append', required = True)

args = p.parse_args()

f = open(args.output, 'w')
for p in args.properties:
    f.write('Get_Property (%s DIRECTORY PROPERTY %s)\n' % (p, p))

f.close()
