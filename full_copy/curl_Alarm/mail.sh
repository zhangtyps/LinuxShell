#!/bin/bash
to=$1
subject=$2
FILE=$3
mail -s "$subject" "$to" <$FILE
