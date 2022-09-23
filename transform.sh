#!/usr/bin/bash

RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
RESET="\e[0m"

workdir=
input_format="msi"
output_format=
while [ $# -gt 0 ]; do
  if [[ $1 =~ "-i" ]]; then
    if [ x"$2" != x ]; then
      input_format=$2
    else
      echo -e "$RED Please specify a input_format $RESET"
      exit 1
    fi
    shift
    shift
  elif [[ $1 =~ "-o" ]]; then
    if [ x"$2" != x ]; then
      output_format=$2
    else
      echo -e "$RED Please specify a output_format $RESET"
      exit 2
    fi
    shift
    shift
  else
    workdir=$1
    shift
  fi
done

if [ x"$output_format" == x ]; then
  echo -e "$RED Please specify a output_format $RESET"
  exit 2
fi

if [ x"$workdir" == x ]; then
  echo -e "$RED Please specify a workdir $RESET"
  exit 3
fi

# print infomation
echo -e "--> The workdir is $RED$workdir$RESET, input_format is $GREEN$input_format$RESET, output_format is $YELLOW$output_format$RESET <--"

# transform file formats
AllFiles=$(find $workdir -iname "*.$input_format")
for file in $AllFiles; do
  prefix=${file%.*}
  if [ $output_format == "POSCAR" ]; then
    parent=$(dirname $file)
    name=$(basename $file)
    prefix=${name%.*}
    output="$parent/$output_format"_"$prefix"

    echo "$file -> $output"
    $(python msi.py $file) && mv POSCAR $output
  else
    echo "$file -> $prefix.$output_format"
    $(obabel $file -O $prefix.$output_format 2>/dev/null)
  fi
done
