# Meli Project - URL Shortener
URL Shortener is a project that allows creating and using short URLs (me.li/AA11BB). It provides a REST API interface to manage the administration of short URLs.

This project is designed in AWS and utilizes services such as Lambda, API Gateway, S3, CloudFront, etc. This project contains the source code and supporting files for a serverless application that can be deployed in AWS.

The following image shows a simplified diagram with the resources and its interconnections:

![](img/img_01.png)

The project is built using several layers. These must be deployed in a specific order to avoid interdependencies errors. Every layer is in the following directories:

- 0-domain: Terraform code to deploy domain resources like Route53 hosted zone and ACM certificates.
- 1-core: Terraform code to deploy the core resources like CloudFront distribution, DinamoDB table, and related S3 buckets.
- 2-api: AWS SAM APP to deploy the API.
- 3-events: Terraform code to deploy 

## API Docs
For a list of the available resources and their endpoints, see [API Doc](swagger.yml).

## Getting Started

### Prerequisites
The Serverless Application Model Command Line Interface (SAM CLI) allows you to develop and test an APP locally.

To use the SAM CLI, you need the following tools.

* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

Deploy SSM
```
sam deploy --config-env dev \
  --no-fail-on-empty-changeset
```
