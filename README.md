# Desing Postgres High Availability cluster

This builds a high-availability postgres cluster on AWS using 
instances ec2 with HAproxy, Postgresql, etcd, patroni.

## Infrastructure Overview

This project uses OpenTofu to provision and manage the infrastructure, allowing for 
consistent and repeatable deployments.
Once infrastructure is deployed, a second phase is launched with ansible that will confure and prepare the ec2 instances to install all the software needed.
- PostgreSQL
- Patroni
- ETCD
- HAproxy

Here the repositories that contains the ansible playbooks

- [haproxy deploymeny](https://github.com/carlo4002/deployment_postgres)
- [postgres deployment](https://github.com/carlo4002/deployment_postgres)

## Architecture Goals

The primary goal is to deploy a PostgreSQL database with high availability and 
regional redundancy across two AWS regions.
Additionally, this setup can serve as a foundation for extending work on monitoring and alerting capabilities.

## Design Summary
Two AWS regions are used to ensure regional-level failover. 
Each region contains:
- 1 VPC
- 3 subnets (both public and private)

Private subnets contains:
- PostgreSQL database instances.
- HAproxy 

Public subnets contain: 
- A NAT Gateway
- Application services that connect to the database and are exposed to the internet

# High Availability Strategy
PostgreSQL instances are distributed across both regions.
If one region goes down, the other continues to operate with active PostgreSQL replicas.

Here Patroni will take care of the leader election. As a minimal configuration, we start with 3 
instances postres but for better high availability
we can continue with 3 instanes in every region
Additional replicas can be deployed in the healthy region as needed.

### Design of insfrastructure

<p align="center">
<img src="https://github.com/carlo4002/revolut_interview/blob/main/images/ach1.png" alt="Architecture" width="800"/>
</p>

### Desing of the node

Here the process running in every node and the relation with haproxy, etc and patroni.
<p align="center">
<img src="https://github.com/carlo4002/revolut_interview/blob/main/images/db-arch.png" alt="Architecture per node" width="800"/>
</p>

# Future improvements

In this project, I’ve set up a high-availability PostgreSQL cluster, but there are still several areas that could be improved to achieve a more robust and production-grade architecture.

Ideally, the architecture should include a separate etcd cluster and HAProxy layer, each deployed across multiple regions. This would enhance fault tolerance and resilience, as shown in the design below.

<p align="center">
<img src="https://github.com/carlo4002/revolut_interview/blob/main/images/graph.png" alt="Architecture per node" width="600"/>
</p>

# Application Code

This part of the repository will contain the application code that will connect to the database.
The application will provide a rest API no TLS connection on the port 5000

## Implementation

The application will be developed using Flask (Python) and deployed on AWS.
In the instance app, the code is containerized and run in the background as a service.

# How to run the infrastructure provisioning

1. Install opentofu
2. Open an aws account and create a user infra_user with the next permissions
  ```
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::154983253182:role/<deployment role>"
        }
  ```
3. Create a role with the needed permiossion do the user infra_user can assume it.

      - AmazonEC2FullAccess
      - AWS managed
      - AmazonSSMFullAccess
      - AWS managed
      - AmazonVPCFullAccess
      - AWS managed
      - iam:AddRoleToInstanceProfile
      - iam:CreateRole
      - iam:DeleteRole
      - iam:GetPolicy
      - iam:AttachRolePolicy
      - iam:CreatePolicy
      - iam:CreatePolicyVersion
      - iam:ListAttachedUserPolicies
      - iam:ListAttachedRolePolicies
      - iam:ListRoles
      - iam:CreateInstanceProfile
      - iam:TagRole
      - iam:GetRole
      - ElasticLoadBalancingFullAccess
   
4. Store the github tokens on S3 buckets so ec2 instances can clone the repositiories to run the ansible playbook
5. Configure opentofu access to aws [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started)
6. Run the opentofu command
```
    tofu plan
    tofu apply
```
7. Connect to a one of the postgres nodes in anyregion and run
`patronictl -c /etc/patroni/patroni.yml list`
This is gonna tell us when the cluster is ready ( we need at least 1 node up and running)
Installation takes a while (download and install) So normally app instance is up and service start running before the postgres cluster is ready.
8. Relaunch the app instance
   `tofu apply -replace="aws_instance.app_instances_primary`
9. Connect to the instance by SSM and run the command
```
    nc -vz localhost 5000
    curl -XGET http://localhost:5000/hello?username=julio
    curl -XPUT http://localhost:5000/hello/julio -H 'Content-Type: application/json' -d '{"dateOfBirth":"1984-06-28"}'
    curl -XGET http://localhost:5000/hello?username=julio
```
