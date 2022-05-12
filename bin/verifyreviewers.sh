#!/bin/sh -l

# Define variables
PULLNUMBER=$INPUT_PULLNUMBER
USERS=$(echo $INPUT_USERS | sed -e 's/,/|/g')
MINREVIEWERS=$INPUT_MINREVIEWERS
REVIEWERSJSON=''

getReviewers() {
    REVIEWERSJSON=$(curl \
  --fail \
  --header "Accept: application/vnd.github.v3+json" \
  --header "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_REPOSITORY/pulls/$PULLNUMBER/reviews)

  if [ "$?" -eq 0 ]; then
    echo "JSON Received"
  else
    echo "Failed to get json"
    exit 1
  fi
}

parseApproves() {
    result=$(echo $REVIEWERSJSON | jq '.[] |  select(.state == "APPROVED") | .user.login' | grep -cE $USERS)

    printf "Printing result\n"
    echo $result
    printf "Printing minreviewers\n"
    echo $MINREVIEWERS

   if [ "$result" -ge "$MINREVIEWERS" ]; then
        printf "Reviwers accepted\n"
        printf "Finishing all good."
    else
        printf "Minium required reviewers not met\n"
        printf "Finishing with failed."
        exit 1
    fi
}

printf "Getting Reviewers \n"
getReviewers
printf "Parsing approvers \n"
parseApproves
