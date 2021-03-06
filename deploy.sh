#!/bin/bash
set -e

# We expect the deploy directory to contain the desired gh-pages contents
if [ ! -d "$DEPLOY_DIR" ]; then
  echo "DEPLOY_DIR ($DEPLOY_DIR) does not exist, build the source directory before deploying"
  exit 1
fi

# Convert https repository to ssh
REPO_URL=$(git config remote.origin.url)
TEST_HTTPS=`echo $REPO_URL | sed -Ene's#.*(https://[^[:space:]]*).*#\1#p'`
if [ -z "$TEST_HTTPS" ]; then
  echo "-- ERROR:  Could not identify Repo url."
  echo "   It is possible this repo is already using SSH instead of HTTPS."
else
  USER=`echo $REPO_URL | sed -Ene's#https://github.com/([^/]*)/(.*).git#\1#p'`
  if [ -z "$USER" ]; then
    echo "-- ERROR:  Could not identify User."
    exit 1
  fi

  REPO=`echo $REPO_URL | sed -Ene's#https://github.com/([^/]*)/(.*).git#\2#p'`
  if [ -z "$REPO" ]; then
    echo "-- ERROR:  Could not identify Repo."
    exit 1
  fi

  REPO_URL="git@github.com:$USER/$REPO.git"
fi

if [ -n "$TRAVIS_BUILD_ID" ]; then
  # When running on Travis we need to use SSH to deploy to GitHub
  #
  # The following converts the repo URL to an SSH location,
  # decrypts the SSH key and sets up the Git config with
  # the correct user name and email (globally as this is a
  # temporary travis environment)
  #
  # Set the following environment variables in the travis configuration (.travis.yml)
  #
  #   SOURCE_BRANCH    - The only branch that Travis should deploy from
  #   ENCRYPTION_LABEL - The label assigned when encrypting the SSH key using travis encrypt-file
  #   GIT_NAME         - The Git user name
  #   GIT_EMAIL        - The Git user email
  #
  echo SOURCE_BRANCH: $SOURCE_BRANCH
  echo ENCRYPTION_LABEL: $ENCRYPTION_LABEL
  echo GIT_NAME: $GIT_NAME
  echo GIT_EMAIL: $GIT_EMAIL
  if [ "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Travis should only deploy from the SOURCE_BRANCH ($SOURCE_BRANCH) branch"
    exit 0
  else
    if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
      echo "Travis should not deploy from pull requests"
      exit 0
    else
      ENCRYPTED_KEY_VAR=encrypted_${ENCRYPTION_LABEL}_key
      ENCRYPTED_IV_VAR=encrypted_${ENCRYPTION_LABEL}_iv
      ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
      ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
      
      # The `deploy_key.enc` file should have been added to the repo and should
      # have been created from the deploy private key using `travis encrypt-file`
      openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_key.enc -out deploy_key -d

      #openssl aes-256-cbc -K $encrypted_d6a76f5bfedb_key -iv $encrypted_d6a76f5bfedb_iv -in deploy_key.enc -out deploy_key -d
      
      chmod 600 deploy_key
      eval `ssh-agent -s`
      ssh-add deploy_key
      git config --global user.name "$GIT_NAME"
      git config --global user.email "$GIT_EMAIL"
    fi
  fi
fi

TARGET_DIR=$(mktemp -d /tmp/$REPO.XXXX)
REV=$(git rev-parse HEAD)

git clone --branch ${TARGET_BRANCH} ${REPO_URL} ${TARGET_DIR}
rsync -rt --delete --exclude=".git" --exclude=".nojekyll" --exclude=".travis.yml" $DEPLOY_DIR/ $TARGET_DIR/
cd $TARGET_DIR
git add -A .
git commit --allow-empty -m "Built from commit $REV"

git push $REPO_URL $TARGET_BRANCH
