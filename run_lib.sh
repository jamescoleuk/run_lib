#!/usr/bin/env bash
#
# Have you ever used 'make' to execute commands? Lots of interfering people
# don't think you should do that. Maybe they're right. BUT IT'S SO HANDY.
# However, it would be better as bash scripts for reasons, if only they were
# as easy to smash out as a Makefile. That's what this script is for.
#
# If you put this file into any project then you could create a 'run' file
# next to it and at the very end add this line:
#   source run_lib.sh "$@"
# This will do a few things:
#  1. When you execute you './run' script, which has some functions in it
#     you'll get a list of those functions, along with any immediately
#     preceding comments.
#  2. You'll be able to do './run my_cool_function' to execute that function.
#  3. You'll get nice colours in your functions, if you feel like using 'echo -e'.
#
# You must source this file because that introduces everything here as part of
# the shell of your 'run' file. So in the line before where we get the name of
# 'this_script', it will be your 'run' script, and not this 'run_lib.sh' file.
# If this isn't clear then why not execute it './run_lib.sh "$@"' instead of
# sourcing it. When you do a simple './run' you'll see the function names in
# _this_ file, not your 'run' file.
#
# Why not have a better solution? Because this is light, not many lines, easy
# to understand, and probably good enough. Will it fail if you do something
# wierd? Maybe. PR me or mail me and we'll see what can be done.
#
# I'm far from an expert at Bash. If any of this can be done better then
# please come forward and educate me. NB nerds: better != more succintly. I've
# chosen some verbosity for the sake of comprehensibility.

# Exit the script on any error
set -e

# Shell colour constants for use in 'echo -e'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
LGREY='\e[37m'
DGREY='\e[90m'
NC='\033[0m' # No colour

show_help() {
  # Get the full name of the file sourcing this one.
  this_script="$(pwd)/`basename "$0"`"

  # Two things happening here:
  # 1. grep the sourcing file to get lines with functions on them
  # 2. get rid of white-space, which will cause extra elements in the array
  # No idea why shellcheck is complaining.
  functions=($(grep -n '^[A-Za-z0-9 -_]*()[ ]*{' ${this_script} | tr -d ' '))

  # That was easy, but we also want comments for each function.
  for i in "${functions[@]}"
  do
     # Pull out the line number from the grep
     IFS=: read line_number rest <<< $i

     # Just keep the function name.
     # TODO: use a capture group in the original grep. This would avoid the tr too.
     function_name=$(sed 's/(){$//' <<< $rest)

     # This $((...)) bullshit is the "arithmetic expansion operator".
     # Bash treats things as strings or numbers depending on context,
     # so we need to use this operator to treat $line_number as a number.
     previous_line_number=$(($line_number-1))

     # sed out the previous line, to use as a comment
     # TODO: what about sedding out all previous commented lines?
     previous_line=$(sed "${previous_line_number}q;d" ${this_script})

     # TODO Check that the previous line is in fact a comment
    
     echo -e "${BLUE}${function_name}${NC} \t\t\t ${DGREY}${previous_line}${NC}"
  done
}

# If there aren't any arguments then display the help.
if [ $# -eq 0 ]; then
  show_help "$@"
else
  # This will call the first argument as a function, passing in the subsequent arguments
  "$@"
fi
