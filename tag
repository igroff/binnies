#! /usr/bin/env launcher
# vim:ft=sh
set -eu

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${MY_DIR}/utils

FILE_TO_TAG=${1?You need to provide me something to tag}
ABS_PATH_OF_FILE_TO_TAG=$(abspath ${FILE_TO_TAG})
shift
TAGS=("$@")

# if we have tags, then we validate them it looks 'funny' because 
# TAGS is an array and an empty array is undefined we do this below
# as well
[ "${TAGS:-x}" != "x" ] && validate_tags "${TAGS[@]}"

KEY=$(hash_with_sha ${ABS_PATH_OF_FILE_TO_TAG})
# wonky test necessitated by array, see above for explanation
if [ "${TAGS:-x}" == "x" ]; then
  STORED_TAGS=$(get_tags "${KEY}")
  if [ -z "${STORED_TAGS}" ]; then
    die "no tags for key ${KEY}" 0
  else
    echo ${STORED_TAGS}
  fi
else
  tag_this "${KEY}" "${TAGS[@]}"
fi

