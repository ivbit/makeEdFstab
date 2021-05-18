#!/bin/ksh

# Intellectual property information START
# 
# Copyright (c) 2021 Ivan Bityutskiy 
# 
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
# 
# Intellectual property information END

# Description START
#
# The script copies /etc/fstab file to current directory and
# creates ed script to add noatime,softdep to ./fstab.
# After testing results in ./fstab,
# addToFstab.ed can be used to change /etc/fstab, as root:
# ed /etc/fstab < addToFstab.ed
#
# Description END

# Shell settings START
set -o noglob
# Shell settings END

# Define functions START
function syntax
{
  print -u2 -- '\nEach argument should be\nsingle unique lowercase letter\nfrom \033[91m[abd-p]\033[0m range!\n'
  exit 1
}
# Define functions END

# BEGINNING OF SCRIPT
if (( $# > 0 ))
then
  # Checking user input
  typeset letters
  typeset testDup=''
  integer counter=0
  while (( $# > 0 ))
  do
    [[ "$1" != [abd-p] ]] && syntax
    letters[counter++]="$1"
    shift
  done
  for letter in ${letters[@]}
  do
    testDup="$testDup$letter\n"
  done
    print -n -- "$testDup" | sort | sort -Cu
    (( $? )) && syntax
else
  set -A letters -- 'a' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k'
fi

# Creating a script for ed
exec 4>| ./addToFstab.ed
for letter in ${letters[@]}
do
  print -u4 -- "g/^.*\\.${letter}\ns/rw/rw,noatime,softdep/"
done
print -u4 -- 'w\nq'
exec 4>&-

# Copying /etc/fstab to current working directory
# Editing ./fstab with ed
cp -fp /etc/fstab ./fstab
ed -s fstab < ./addToFstab.ed 1> /dev/null 2> /dev/null
(( $? )) && {
  print -u2 -- '\nOne of the specified letters\ncorresponds to a \033[91mswap\033[0m or read-only partition!\nThe fstab file was \033[91mnot written\033[0m!\n'
  exit
}

# Shell settings START
set +o noglob
# Shell settings END

# END OF SCRIPT

