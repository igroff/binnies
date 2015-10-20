#! /usr/bin/env launcher
# vim:ft=sh

##############################################################################
### ${ME} (options and stuff)
### ${ME} <key>                    Show tags for item
### ${ME} <key> <taglist>          Add tags to item
### ${ME} <key> --remove <taglist> Remove tags from item
### ${ME} <key> --delete           Delete item
### ${ME} --list                   List info for all tags
### ${ME} --with-any <taglist>     List items with ANY of the tags provided
### ${ME} --with-all <taglist>     List items with ALL of the tags provided
##############################################################################

# argument handling
# if $1 does not start with --, then insert --key
# --key "$@"
# if $1 is --key and $3 does not start with --, insert --tags at $3


getopt --shell bash --longoptions "with-any:,with-all:" --options "lr:x" -- "$@"
echo "$@"
exit 1


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
