#!/bin/bash  
echo "run on $HOSTNAME"
/mnt/net1/common/anaconda3/bin/conda run --name base python -m pip list
/mnt/net1/common/anaconda3/bin/conda run --name base  --no-capture-output python test.py