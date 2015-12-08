# infoint1516

* create a database
* create the source schemas using `psql <database> < all_schemas.sql`
* create the target schema using `psql <database> < integrated_schema.sql`
* create a target schema for each source using `./create_targets.sh <database>`
