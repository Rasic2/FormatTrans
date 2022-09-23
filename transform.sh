#!/usr/bin/bash

RED="\e[1;31m"
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
RESET="\e[0m"

workdir=
input_format="msi"
output_format=
while [ $# -gt 0 ]; do
  if [[ $1 =~ "-i" ]]; then # catch input format
    if [ x"$2" != x ]; then
      input_format=$2
    else
      echo -e "$RED Please specify a input_format $RESET"
      exit 1
    fi
    shift
    shift
  elif [[ $1 =~ "-o" ]]; then # catch output format
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

if [ x"$output_format" == x ]; then # check output format
  echo -e "$RED Please specify a output_format $RESET"
  exit 2
fi

if [ x"$workdir" == x ]; then # check workdir
  echo -e "$RED Please specify a workdir $RESET"
  exit 3
fi

# print infomation
echo -e "--> The workdir is $RED$workdir$RESET, input_format is $GREEN$input_format$RESET, output_format is $YELLOW$output_format$RESET <--"

# search files according to the input format
if [ $input_format != "POSCAR" ]; then
  AllFiles=$(find $workdir -iname "*.$input_format")
else
  AllFiles=$(find $workdir -iname "$input_format"'_*')
fi

# transform here
for file in $AllFiles; do
  parent=$(dirname $file) # parent directory
  name=$(basename $file)  # name of file
  if [ $input_format == "POSCAR" ]; then
    name_without_prefix=${name#*_} # name of file without `POSCAR_` prefix
    echo "$file -> $parent/$name_without_prefix.$output_format"
    $(obabel -i POSCAR $file -O $parent/$name_without_prefix.$output_format)
  else
    if [ $output_format == "POSCAR" ]; then
      name_without_suffix=${name%.*} # name of file without the extension
      output="$parent/$output_format"_"$name_without_suffix"
      echo "$file -> $output"
      $(python msi.py $file) && mv POSCAR $output
    else
      name_without_suffix=${file%.*}
      echo "$file -> $name_without_suffix.$output_format"
      $(obabel $file -O $name_without_suffix.$output_format 2>/dev/null)
    fi
  fi
done
