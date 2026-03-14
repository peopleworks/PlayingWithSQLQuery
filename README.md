# Playing With SQL Query

A curated collection of practical SQL scripts, administration snippets, and reusable database utilities for SQL Server, PostgreSQL, MySQL, Oracle, and DB2.

This repository focuses on real-world database work: metadata discovery, data quality checks, missing-number analysis, index maintenance, partitioning, search-and-replace operations, geocoding helpers, and security-oriented logon restrictions.

## Why This Repository Exists

- Centralize useful scripts gathered from day-to-day database work.
- Share repeatable solutions across multiple database engines.
- Keep public examples clean, documented, and safe to reuse.

## Database Coverage

| Engine | Files | Typical Topics |
| --- | ---: | --- |
| MS SQL Server | 33 | metadata, automation, partitioning, geocoding, security triggers, maintenance |
| PostgreSQL | 5 | `dblink`, metadata, missing records, role grants |
| Oracle | 3 | server/session metadata, table comments, column discovery |
| MySQL | 2 | index discovery and index maintenance procedures |
| DB2 | 1 | connection and administration command cheatsheet |

## Repository Structure

```text
.
|-- DB2/
|-- MS SQL Server/
|-- MySQL/
|-- Oracle/
`-- PostgreSQL/
```

## Featured Script Areas

### MS SQL Server

- Address validation and geocoding helpers.
- Metadata exploration for tables, views, functions, and dependencies.
- Partition creation and partition maintenance examples.
- Search-and-replace utilities and text formatting helpers.
- Security samples for host, application, and IP-based restrictions.

### PostgreSQL

- Querying remote sources with `dblink`.
- Finding and remediating missing sequence-style values.
- Listing tables across schemas with descriptions.
- Granting reporting access with reusable privilege templates.

### Oracle

- Inspecting server host information for the current session.
- Listing tables that contain a specific column pattern.
- Reviewing table and column comments for documentation work.

### MySQL

- Generating missing index statements.
- Rebuilding indexes for all base tables in a database.

### DB2

- Connecting, attaching, listing objects, and handling backup/restore tasks.

## Usage Guidelines

1. Review each script before running it in shared or production environments.
2. Replace all placeholder values such as `<DB2_USER>`, `<REMOTE_HOST>`, or `[YourDatabaseName]`.
3. Keep credentials, API keys, internal hostnames, and IP addresses outside source control.
4. Test maintenance, partitioning, and logon-trigger scripts in non-production first.
5. Adapt object names, schemas, and thresholds to your environment before execution.

## Security and Repository Hygiene

- Public samples use placeholders instead of real passwords, hosts, or blocked IP addresses.
- Environment-specific database references have been generalized where possible.
- Scripts are being normalized with clearer comments and safer customization points.

If you contribute new examples, do not commit:

- passwords or tokens
- internal server names
- private IP addresses
- customer-specific connection strings

## Contribution Notes

- Place new scripts in the correct engine folder.
- Add a short header comment describing purpose, prerequisites, and what must be customized.
- Prefer portable examples over environment-specific copies.
- Keep formatting clean so scripts are easy to scan and adapt.

## Roadmap

- Expand coverage for performance diagnostics and observability.
- Continue standardizing file headers and placeholder conventions.
- Add more script descriptions and usage examples over time.
