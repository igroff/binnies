#! /usr/bin/env bash

TEMPLATE=$1
OUTPUT_FILE=${2-${TEMPLATE}}

# refuse to overwrite existing file
[ -f "${OUTPUT_FILE}" ] && echo "File ${TEMPLATE} already exists" && exit 3

HTTP_STATUS=$(curl -s https://raw.githubusercontent.com/igroff/simple-templates/master/${TEMPLATE} -o ${OUTPUT_FILE} -w "%{http_code}")

if [ "${HTTP_STATUS}" == "404" ]; then
  echo "Unknown template \"${TEMPLATE}\""
  # we didn't have the requested template, so our output file will simply contain
  # a form of 'not found' hence we're gonna remove it
  rm ${TEMPLATE}
  exit 1
elif [ "${HTTP_STATUS}" != "200" ]; then
  echo "Error ${HTTP_STATUS} retrieving template ${TEMPLATE}"
  exit 2
fi
