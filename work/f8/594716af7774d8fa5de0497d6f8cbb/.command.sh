#!/bin/bash -ue
echo "validating input..."
python /app/validation.py -i All_Together.txt -r public_ref
