#! /usr/bin/env bash
# vim:ft=sh


MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${MY_DIR}/utils

FILE_TO_TAG=${1?You need to provide a file to tag oh, and, some tags}
ABS_PATH_OF_FILE_TO_TAG=$(abspath ${FILE_TO_TAG})
shift
TAGS=("$@")

[ ${#TAGS[@]} -gt 0 ] || die "no tags, nothing tagged" 0

echo "{"
echo "  "\""file"\"":"\""${ABS_PATH_OF_FILE_TO_TAG}"\"","
echo -n "  "\""tags"\"":["
for tag in "${TAGS[@]}"
do
  [ -n "${ONCE_THRU}" ] && echo -n ","
  echo -n ""\""${tag}"\"""
  ONCE_THRU=true
done
echo "]"
echo "}"
