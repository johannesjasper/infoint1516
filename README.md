# infoint1516

Setup:
* create a database
* create integrated schema using `integrate.sh <database>`
Or do it step by step
* create the source schemas using `psql <database> < create_source_schemas.sql`
* create the target schema using `psql <database> < create_integrated_schema.sql`
* create a target schema for each source using `./create_targets.sh <database>`
* for each data source use `psql <database> < imports/<datasource>.sql`
