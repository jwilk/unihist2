#!/usr/bin/env python3
# encoding=UTF-8

# Copyright © 2023 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

import os
import pty
import subprocess
import signal
import sys

here = os.path.dirname(__file__)
base = f'{here}/..'
prog = os.getenv('UNIHIST2_TEST_TARGET') or f'{base}/unihist2'

def signame(n):
    try:
        sig = signal.Signals(n)
    except ValueError:
        return f'signal {n}'
    return sig.name

def main():
    print('1..4')
    fd_master, fd_slave = pty.openpty()
    with subprocess.Popen([prog], stdin=fd_slave, stdout=subprocess.PIPE, stderr=subprocess.PIPE) as proc:
        os.close(fd_slave)
        os.write(fd_master, b'x\n\4')
        try:
            (stdout, stderr) = proc.communicate(timeout=1)
        except subprocess.TimeoutExpired:
            print('not ok 1', 'EOT (did not stop reading)')
            proc.kill()
        else:
            print('ok 1', 'EOT (stopped reading)')
        rc = proc.returncode
        if rc is None:
            print('not ok 2', 'exit status (none)')
        elif rc == 0:
            print('ok 2', 'exit status (0)')
        elif rc > 0:
            print('not ok 2', f'exit status (f{rc})')
        else:
            print('not ok 2', f'exit status (killed by {signame(-rc)})')
        if stderr == b'':
            print('ok 3', 'stderr (empty)')
        else:
            print('not ok 3', 'stderr (non-empty)')
        if stdout == b'1\t\tU+000A\tLINE FEED\n1\tx\tU+0078\tLATIN SMALL LETTER X\n':
            print('ok 4', 'stdout (expected)')
        else:
            print('not ok 4', 'stdout (unexpected)')
        os.close(fd_master)

if __name__ == '__main__':
    main()

# vim:ts=4 sts=4 sw=4 et ft=python
