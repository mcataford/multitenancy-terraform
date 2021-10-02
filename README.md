# multitenancy-terraform
Some haphazard tooling to manage a basic multitenancy Postgres setup using Terraform

## Overview

AWS RDS is expensive, but EC2s are a good way to get a database running for dimes. This repository gathers some tooling
to make creating and using a multitenant Postgres database.

This assumes you have `terraform` set up and have generated a RSA SSH key.
