-- principal_investigator, principal_investigator_email
select
	id,
	"type",
	"name",
	alias as aliases,
	FLOOR(RANDOM()*(1000000-1 + 1))+ 1 as "pi",
	funding_source,
	status,
	bio_safety_level,
	genotype_phenotype,
	keywords,
	replace(replace(replace(replace(summary, '''', '`'), '"', '``'), E'\n', '|'), E'\r', '|') as summary,
	"references" as lit_references,
	intellectual_property,
	replace(replace(replace(replace(notes, '''', '`'), '"', '``'), E'\n', '|'), E'\r', '|') as notes,
	creator_id as creator,
	host_species_id as organism_basis
from
	parts p ;
