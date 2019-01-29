#!/bin/bash -ue
cd app/
pwd
python validation.py -i All_Together.txt -r public_ref
