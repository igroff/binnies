#! /usr/bin/env bash
# vim:ft=sh


MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${MY_DIR}/utils

FILE_TO_TAG=${1?You need to provide a file to tag oh, and, some tags}
ABS_PATH_OF_FILE_TO_TAG=$(abspath ${FILE_TO_TAG})
shift
TAGS=("$@")


# this is the root of where our tag data will be stored
TAG_STORE_ROOT=${TAG_STORE_ROOT-~/.tags}
# and under that, where our "items tagged" will be referenced
TAG_ITEM_STORE=${TAG_STORE_ROOT}/objs
# as well, the tags that reference those tagged items
TAG_TAG_STORE=${TAG_STORE_ROOT}/tags
mkdir -p ${TAG_ITEM_STORE} ${TAG_TAG_STORE}


[ ${#TAGS[@]} -gt 0 ] || die "no tags, nothing tagged" 0

TAG_JSON=$(
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
)

find_a_hasher
ITEM_SHA=$(hasher ${FILE_TO_TAG})
echo ${ITEM_SHA}
# create our tag links
for tag in "${TAGS[@]}"
do
  :
done
