-- principal_investigator, principal_investigator_email
select
	concat('Part:', cast(id as text)) as id,
	"type" as part_type,
	"name",
	alias as aliases,
	concat('Person:', cast((FLOOR(RANDOM()*(1000000-1 + 1))+ 1) as text)) as "pi",
	funding_source,
	status,
	bio_safety_level,
	genotype_phenotype,
	keywords,
	replace(replace(replace(replace(summary, '''', '`'), '"', '``'), E'\n', '|'), E'\r', '|') as summary,
	"references" as lit_references,
	intellectual_property,
	replace(replace(replace(replace(notes, '''', '`'), '"', '``'), E'\n', '|'), E'\r', '|') as notes,
	concat('Person:', cast(coalesce(creator_id, 999) as text)) as creator,
	host_species_id as organism_basis
from
	parts p ;