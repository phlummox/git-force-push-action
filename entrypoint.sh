#!/usr/bin/env bash

set -e

if [[ -n "${INPUT_DEBUG}" ]]; then
    export DEBUG=true
fi

function die(){
  printf '%s\n' "$1" >&2
  exit 1
}

function run_git(){
  GIT_CMD="git push --tags --force ${TARGET_REPO_URL} ${SOURCE_BRANCH}:${TARGET_BRANCH}"
  if [[ "${DEBUG}" == "true" ]]; then
    GIT_CURL_VERBOSE=true GIT_TRACE=true GIT_SSH_COMMAND="ssh -v -o IdentitiesOnly=yes -i ~/.ssh/id_rsa" $GIT_CMD
  else
    GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -i ~/.ssh/id_rsa" $GIT_CMD
  fi
}

if [[ ! $(git rev-parse --is-inside-work-tree 2>/dev/null) ]]; then
  die 'No repository checked checked out!'
fi

if [ -z "$INPUT_SOURCE_BRANCH" ] ; then
  die "Expected a non-zero-length source branch"
fi

if [ -z "$INPUT_TARGET_REPO_URL" ] ; then
  die "Expected a non-zero-length destination repo"
fi

if [ -z "$INPUT_TARGET_BRANCH" ] ; then
  die "Expected a non-zero-length destination branch"
fi

if [ -z "$INPUT_SSH_PRIVATE_KEY" ] ; then
  die "Expected a non-zero-length ssh private key"
fi

# Q. potential errors ... presumably branches can't contain
# the colon in their name?
# A. Actually they can: https://wincent.com/wiki/Legal_Git_branch_names
# Ah well. The push will presumably fail, then.

SOURCE_BRANCH="${INPUT_SOURCE_BRANCH}"
TARGET_REPO_URL="${INPUT_TARGET_REPO_URL}"
TARGET_BRANCH="${INPUT_TARGET_BRANCH}"
SSH_PRIVATE_KEY="${INPUT_SSH_PRIVATE_KEY}"

# add private key
mkdir -p ~/.ssh
echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# regenerate public key to avoid any ssh warnings
ssh-keygen -f ~/.ssh/id_rsa -y > ~/.ssh/id_rsa.pub

git checkout "${INPUT_SOURCE_BRANCH}" 2>/dev/null || \
  die "Couldn't checkout branch ${INPUT_SOURCE_BRANCH}"

run_git

