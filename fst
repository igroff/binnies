#! /usr/bin/env bash
# vim: set ft=sh

REPO_DIR=${FST_REPO_DIR:-~/.fst}
MY_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`

# ******************************************************************************
# utils
debug() { [ -n "${DEBUG}" ] && echo ${FUNCNAME^^} $@; }
export -f debug
info() { echo "$@"; }
export -f info
error() { echo "$@" >&2; }
export -f error
#
# ******************************************************************************


# ******************************************************************************
# constants
E_NOGIT=1
E_OPT_INVALID=2
E_CLONE=3
E_CHECKOUT=4
E_COPY=5
E_COMMIT=6
E_PUSH=7
E_UNPACK=8
E_NO_REPO_URL=22
E_BAD_REPO_DIR=23
# ******************************************************************************

# ******************************************************************************
# make sure we don't get any of the vars we're gonna use from the environment
unset TEMPLATE_DIR
unset TEMPLATE_NAME
# ******************************************************************************

if [ "${REPO_DIR}" = "." -o "${REPO_DIR}" = ".." ]; then
  error "I won't let you use current or parent directory indicators for your repo dir, it'd be bad"
  exit $E_BAD_REPO_DIR
fi

which git &> /dev/null || $(echo 'You must have git, or I can do nothing!' && exit $E_NOGIT)

while getopts ":d:n:" opt; do
  case $opt in
    d)
      TEMPLATE_DIR=${OPTARG}
      ;;
    n)
      TEMPLATE_NAME=${OPTARG}
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit $E_OPT_INVALID
      ;;
    :)
      [ $OPTARG == d ] && echo "You'll need to give me a directory to create template from." >&2
      [ $OPTARG == n ] && echo "To use -${OPTARG} you need to provide a name" >&2
      exit $E_OPT_INVALID
      ;;
  esac
done

[ -n "$1" ] && TEMPLATE_NAME=$1
# if we have a template dir, we're creating a template
# if we have just a template name, we're unpacking a template
# if we got nothing, we're listing our templates

# for use in subshells and such
CURRENT_DIR=`pwd`

if [ -n "${TEMPLATE_DIR}" ]; then
  # if the template dir starts with / then it's absolute, otherwise 
  # relative to our current location
  [[ "${TEMPLATE_DIR}" == \/* ]] || TEMPLATE_DIR=${CURRENT_DIR}/${TEMPLATE_DIR}
  ACTION=create
  # if the user has provided a template name via -n, it will be the 4th parameter 
  # because -d <dir> get's us here and to specify a template name it'll be like
  # -d <dir> -n <name>
  TEMPLATE_NAME=${4:-$(basename ${TEMPLATE_DIR})}
elif [ "${TEMPLATE_NAME}" = "install" ]; then
  ACTION=install
  REPO=${2}
  if [ -z "${REPO}" ]; then
    error "you must provide a url to your template repository"
    exit $E_NO_REPO_URL
  fi
elif [ -n "${TEMPLATE_NAME}" ]; then
  DESTINATION_DIR=${2}
  # here either, the destination dir is absolute (starts with a slash) or we will
  # make it relative to our current location
  [[ "${DESTINATION_DIR}" == \/* ]] || DESTINATION_DIR=${CURRENT_DIR}/${DESTINATION_DIR}
  ACTION=unpack
else
  ACTION=list
fi


debug "Action: ${ACTION}"
if [ "${ACTION}" = "create" ]; then
  (
    cd ${REPO_DIR}
    CO_OUTPUT=$(
      git checkout $TEMPLATE_NAME  2>&1 || git checkout -b ${TEMPLATE_NAME} origin/master 2>&1;
    )
    CO_RESULT=$?
    debug "CO_OUTPUT: $CO_OUTPUT"
    if [ $CO_RESULT -ne 0 ]; then
      error 'We seem to have encountered a problem checking out the template branch!'
      debug "exit code $CO_RESULT"
      error "$CO_OUTPUT"
      exit $E_CHECKOUT
    fi

    CP_OUTPUT=$(
      debug "Copying template contents from ${TEMPLATE_DIR}"
      # we really want our news stuff to overwrite the old. so..
      rm -rf ${REPO_DIR}/*
      cp -R ${TEMPLATE_DIR}/* . 2>&1
    )
    CP_RESULT=$?
    debug "CP_OUTPUT: $CP_OUTPUT"
    if [ $CP_RESULT -ne 0 ]; then 
      error 'We had some trouble copying the contents of your template into the repo for checkin'
      debug "exit code $CP_RESULT"
      error "The problem looked like: ${CP_OUTPUT}"
      exit $E_COPY
    fi

    COMMIT_OUTPUT=$(
      git add . 2>&1 && git commit -m "no message here" 2>&1;
    )
    COMMIT_RESULT=$?
    debug "COMMIT_OUTPUT: $COMMIT_OUTPUT"
    if [ $COMMIT_RESULT -ne 0 -a $COMMIT_RESULT -ne 1 ]; then
      error 'We seem to have had an error checking in your template'
      debug "exit code $COMMIT_RESULT"
      error "Here's what happend: ${COMMIT_OUTPUT}"
      exit $E_COMMIT
    fi
    
    PUSH_OUTPUT=$(
      git push origin ${TEMPLATE_NAME} 2>&1;
    )
    PUSH_RESULT=$?
    debug "PUSH_OUTPUT: $PUSH_OUTPUT"
    if [ $PUSH_RESULT -ne 0 ]; then
      error 'We had some trouble pushing the template changes back to origin'
      error "See: \n${PUSH_OUTPUT}"
      exit $E_PUSH
    fi
  )
  CREATE_RESULT=$?
  if [ $CREATE_RESULT -ne 0 ]; then
    error 'Looks like we had some problems creating the template for you, you work that out and try again ya hear?'
    exit $CREATE_RESULT
  fi
elif [ "$ACTION" = "install" ]; then
  mkdir -p ~/.bin && cp ${MY_PATH} ~/.bin/
  [ -d "${REPO_DIR}" ] && rm -rf "${REPO_DIR}"
  debug Working directory: ${REPO_DIR}
  info "going to get your repository for the first time, gimme a sec."
  CLONE_OUTPUT=$(git clone ${REPO} ${REPO_DIR} 2>&1)
  if [ $? -ne 0 ]; then
    error "error cloning your template repo, is it set correctly?  Here's what I think it is: ${REPO}"
    error "And the error from the git was: ${CLONE_OUTPUT}"
    exit $E_CLONE
  fi
elif [ "$ACTION" = "list" ]; then
  # so, git will put * into the branch listing which is kind of a bitch as the shell
  # sure wants to expand that, so we tell it NO GLOBBIN' KITTY!
  set -f
  LIST_OUTPUT=$(
   cd "${REPO_DIR}" && git branch -r 2>&1;
  )
  LIST_RESULT=$?
  if [ $LIST_RESULT -ne 0 ]; then
    error 'Hmm, something went wrong while listing your templates..'
    debug $LIST_RESULT
    error $LIST_OUTPUT
    exit $LIST_RESULT
  fi
  echo "Here are the templates I know about:"
  for template in $(echo $LIST_OUTPUT | sed -e s[\*[[g )
  do
    if [ 'origin/master' != "$template" -a 'master' != "$template" ]; then
      echo "  $template"
    fi
  done
  # undo the noglob from before
  set +f
elif [ "$ACTION" = "unpack" ]; then
  debug "DESTINATION_DIR: ${DESTINATION_DIR}"
  (
    cd "${REPO_DIR}";
    UNPACK_OUTPUT=$(
      git checkout ${TEMPLATE_NAME} 2>&1
    )
    UNPACK_RESULT=$?
    if [ $UNPACK_RESULT -ne 0 ]; then
      error "There was a problem unpacking that template, you sure ${TEMPLATE_NAME} is valid?"
      debug $UNPACK_RESULT
      error $UNPACK_OUTPUT
      exit $E_UNPACK
    fi
    COPY_OUTPUT=$(
      mkdir -p ${DESTINATION_DIR} 2>&1
      rsync -av --exclude='.git/' ${REPO_DIR}/ ${DESTINATION_DIR}/ 2>&1
    )
    COPY_RESULT=$?
    if [ $COPY_RESULT -ne 0 ]; then
      error "I had a problem copying your template ${TEMPLATE_NAME} into the specified directory ${DESTINATION_DIR}"
      debug $COPY_RESULT
      error $COPY_OUTPUT
      exit $E_COPY
    fi
  )
  UNPACK_RESULT=$?
  [ $UNPACK_RESULT -eq 0 ] || exit $UNPACK_RESULT
fi
