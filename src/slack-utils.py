#!/usr/bin/env python

import sys
import dircache

pd = '/var/log/packages'
pa = dircache.opendir(pd)
me = sys.argv[0]
col_start = "\033[31;1m"
col_end = "\033[0m"

## Testing colorized output of the file being executed
#print col_start + me + col_end


