#!/bin/bash -ue
pip list
python ./app/validation.py -i All_Together.txt -r public_ref
