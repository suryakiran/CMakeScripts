import os, sys
import argparse

parser = argparse.ArgumentParser(prog = 'set-properties')
parser.add_argument('-o', dest = 'output', required = True)
parser.add_argument('-v', dest = 'values', action = 'append', required = True)
parser.add_argument('-n', dest = 'name', required = True)

args = parser.parse_args()

file = open(args.output, 'a')
file.write ('Set_Property (DIRECTORY PROPERTY %s %s)\n'
            % (args.name, ' '.join(args.values)))
file.close()
