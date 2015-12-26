#!/bin/sh
set -e

SQS_WAIT_TIMEOUT=20
SQS_VISIBILITY_TIMEOUT=10

if [ -z "$CONVEYOR_PORT" ]
then
  echo "Error: Conveyor container not linked."
  exit 1
fi

if [ -z "$GITHUB_QUEUE" ]
then
  echo "Error: Queue not specified, please set \$GITHUB_QUEUE."
  exit 1
fi

while true
do
  echo "Polling SQS queue for github pushes (timeout: ${SQS_WAIT_TIMEOUT}s)"
  sqs_data=$(aws sqs receive-message --queue-url $GITHUB_QUEUE --region $AWS_REGION --visibility-timeout $SQS_VISIBILITY_TIMEOUT --wait-time-seconds $SQS_WAIT_TIMEOUT)
  if [ -n "$sqs_data" ]
  then
    echo "Got a payload, pushing to conveyor"
    payload=$(echo "$sqs_data" | jq '.Messages[0].Body | fromjson')
    handle=$(echo "$sqs_data" | jq -r '.Messages[0].ReceiptHandle')
    conveyor_url=${CONVEYOR_PORT/tcp:\/\//http:\/\/}
    curl -H "X-GitHub-Event: push" -X POST $conveyor_url -d "${payload}"
    aws sqs delete-message --queue-url $GITHUB_QUEUE --region $AWS_REGION --receipt-handle "$handle"
  fi
done
