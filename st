#! /usr/bin/env bash

TEMPLATE=$1

HTTP_STATUS=$(curl -s https://raw.githubusercontent.com/igroff/simple-templates/master/${TEMPLATE} -o ${TEMPLATE} -w "%{http_code}")

if [ "${HTTP_STATUS}" == "404" ]; then
  echo "Unknown template \"${TEMPLATE}\""
  exit 1
elif [ "${HTTP_STATUS}" != "200" ]; then
  echo "Error ${HTTP_STATUS} retrieving template ${TEMPLATE}"
  exit 2
fi
