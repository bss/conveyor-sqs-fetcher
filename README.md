# Conveyor SQS Fetcher
Just a simple polling script to connect an SQS queue with github pushes to conveyor.

## Quick start
Just add the following

```YAML
sqs_fetcher:
  image: bssdk/conveyor-sqs-fetcher
  env_file: .env
  links:
    - conveyor:conveyor
```
to the conveyor docker-compose.yml file.
