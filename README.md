# Desing Postgres HA cluster

This project has as intention to build a HA postgres cluster on AWS using 
instances ec2 with HAproxy, Postgresql, etcd, patroni.

## Infrastructure Overview

This project uses OpenTofu to provision and manage the infrastructure, allowing for 
consistent and repeatable deployments.

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
- Application services that, connect to the database and are exposed to the internet

# High Availability Strategy
PostgreSQL instances are distributed across both regions.
If one region goes down, the other continues to operate with active PostgreSQL replicas.

Here Patroni will take care of the leader election. As a minimal configuration, we start with 3 
instances postres but for better high availability
we can continue with 3 instanes in every region
Additional replicas can be deployed in the healthy region as needed.

### Design of insfrastructure

<p align="center">
<img src="https://github.com/carlo4002/revolut_interview/blob/main/images/ach1.png" alt="Architecture" width="600"/>
</p>

### Desing of the node

Here the process running in every node and the relation with haproxy, etc and patroni.
<p align="center">
<img src="https://github.com/carlo4002/revolut_interview/blob/main/images/db-arch.png" alt="Architecture per node" width="600"/>
</p>
# Application Code

This part of the repository will contain the application code that will connect to the database.
The application will provide a rest API no TLS connection on the port 5000

## Implementation

The application will be developed using Flask (Python) and deployed on AWS.
In the instance app, the code is containerized and run in the background as a service.
