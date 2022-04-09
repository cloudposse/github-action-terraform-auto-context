#!/bin/bash

if [[ -f context.tf ]]; then
  echo "Discovered existing context.tf!"
  echo "Checking for pre-existing ${BRANCH_NAME} branch."
  if [[ ! $(git show-branch remotes/origin/${BRANCH_NAME}) ]]; then
    echo "Branch ${BRANCH_NAME} not found."
    echo "Fetching most recent version of context.tf to see if there is an update."
    curl -o context.tf -fsSL https://raw.githubusercontent.com/cloudposse/terraform-null-label/master/exports/context.tf
    if git diff --no-patch --exit-code context.tf; then
      echo "No changes detected! Exiting the job..."
    else
      # updating context.tf and documentation
      echo "context.tf file has changed. Update examples and rebuild README.md and commit everything to a new ${BRANCH_NAME} branch."
      #make init
      make github/init/context.tf
      #make readme/build
      # moving to new branch to commit changes
      git checkout -b ${BRANCH_NAME}
      # committing changes
      git config --global user.name "${BOT_NAME}"
      git config --global user.email "11232728+${BOT_NAME}@users.noreply.github.com"
      git add -A
      git commit -m "Update context.tf from origin source"
      git push --set-upstream origin ${BRANCH_NAME}
      # setting flag to create pull request for new branch
      #echo "::set-output name=create_pull_request::true"
    fi
  else
    echo "Branch ${BRANCH_NAME} found."
    echo "Please merge or delete pre-existing ${BRANCH_NAME} branch before rerunning this action."
  fi
else
  echo "This module has not yet been updated to support the context.tf pattern! Please update in order to support automatic updates."
fi