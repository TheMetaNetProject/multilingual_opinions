#!/bin/bash

export PYTHONPATH=$PYTHONPATH:/n/shokuji/dc/edg/Library/Python/2.6/site-packages/

python cluster.py $1 $2

exit $?