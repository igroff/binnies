#! /usr/bin/env launcher
# vim:ft=sh
set -eu

FILE_TO_TAG=${1?You need to provide me something to tag}
ABS_PATH_OF_FILE_TO_TAG=$(abspath ${FILE_TO_TAG})
shift
TAGS=("$@")

[ "${TAGS:-x}" != "x" ] && validate_tags "${TAGS[@]}"

KEY=$(hash_with_sha ${ABS_PATH_OF_FILE_TO_TAG})
if [ "${TAGS:-x}" == "x" ]; then
  # we weren't provided any tags so we're going to show the ones we
  # have, if there are any.
  STORED_TAGS=$(get_tags "${KEY}")
  if [ -z "${STORED_TAGS}" ]; then
    die "no tags for key ${KEY}" 0
  else
    echo ${STORED_TAGS}
  fi
else
  tag_this "${KEY}" "${TAGS[@]}"
fi
