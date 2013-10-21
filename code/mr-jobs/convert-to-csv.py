#!/usr/bin/python

##----------------------------------------------------------------------
## Copyright (c) 2013 Carl A. Dunham, All Rights Reserved
##----------------------------------------------------------------------
##
## convert-to-csv.py
##
## Created: 2013-Sep-28 by carl
##
##----------------------------------------------------------------------

"""
Convert JSON output from map-reduce to a CSV file
"""

import sys
import os
from optparse import OptionParser

import json

DEBUG = 0

VARS = ('temp', 'windspeed', 'gust')
STATS = ('N', 'min', 'max', 'mean', 'sd')


def main():
    """
    Parse command line options, read the JSON data in and output it in CSV format. 
    """

    parser = OptionParser(version="0.1", usage="%prog [options] filename")
    parser.add_option("-d", "--debug", type="int", default=0, help="set debug level to DEBUG (default: %default)")
    parser.add_option("-q", "--quiet", action="store_true", dest="quiet")
    parser.add_option("-v", "--verbose", action="store_true", dest="verbose")

    (opts, args) = parser.parse_args()

    global DEBUG
    DEBUG = opts.debug

    if DEBUG >= 3:
        print >> sys.stderr, 'opts="%s", filename="%s"' % (opts, filename)

    f_in = sys.stdin
    f_out = sys.stdout

    if len(args) > 1:
        parser.error('exactly one filename required')
    elif len(args) == 1:
        f_in = open(args[0], 'r')

    f_out.write('"station","month","N"')

    for v in VARS:

        for s in STATS:
            f_out.write(',"' + v+'.'+s + '"')

    f_out.write(',"tornado"\n')

    for line in f_in:
        raw_k,raw_v = line.split("\t")

        k = json.loads(raw_k)
        v = json.loads(raw_v)

        f_out.write('"%s","%s","%d"' % (k[0], k[1], v['N']))

        for var in VARS:

            if isinstance(v[var], dict):

                for stat in STATS:
                    f_out.write(',"%f"' % v[var][stat])

            else:
                for i in range(len(STATS)):
                    f_out.write(',NA')
                    
        f_out.write(',"' + ('T' if v['tornado'] else 'F') + '"\n')
        

if __name__ == "__main__":
    main()
