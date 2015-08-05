#!/bin/bash
md5(){ printf "%d" 0x`echo "$@" | tee m1 | md5sum | tee -a m1 | cut -b3,7` | tee -a m1 ; }
md5exit(){ exit `md5 "$@"` ; }
md5exit $@
