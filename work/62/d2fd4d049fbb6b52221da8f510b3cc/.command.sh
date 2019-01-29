#!/bin/bash -ue
python --version
python app/validation.py -i All_Together.txt -r public_ref
