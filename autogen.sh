#!/bin/sh -e

base=`dirname $0`

autoreconf --force --install --no-recursive "-I$base/m4"
