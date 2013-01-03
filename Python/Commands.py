import os
import argparse

class Commands:
    def make_executable(self, *args):
        f = args[0]
        if os.access(f, os.R_OK):
            os.chmod(f, 0755)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('-c', dest='command', required = True)
    p.add_argument('args', nargs='*')
    a = p.parse_args()
    cmd = getattr(Commands(), a.command)
    if not cmd:
        raise Exception("%s not implemented" % a.command)
    cmd(*a.args)
