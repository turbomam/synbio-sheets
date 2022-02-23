schemasheet_key = 1OY3VzL7xk1bAiSt3JIwPR5IParlaTRcxb0aD1sEPEdI
credentials_file = local/felix-sheets-4d1f37aa312b.json

.cogs:
	poetry run cogs connect -k $(schemasheet_key) -c $(credentials_file)

# requires fetch step for satisfying dependencies?
.cogs/tracked/%: .cogs
	poetry run cogs add $(subst .tsv,,$(subst .cogs/tracked/,,$@))
	poetry run cogs fetch

target/synbio_schema_sheet.yaml: .cogs/tracked/schema.tsv .cogs/tracked/prefixes.tsv .cogs/tracked/class_defs.tsv \
.cogs/tracked/slot_usage.tsv .cogs/tracked/enums.tsv
	poetry run sheets2linkml -o $@ $^

clean:
	#rm -rf DataHarmonizer/template/soil_emsl_jgi_mg
	rm -rf artifacts/*yaml
	rm -rf bin/*
	rm -rf docs/*
	rm -rf logs/*log
	rm -rf project/*py
	rm -rf project/docs/*
	rm -rf project/excel/*
	rm -rf project/graphql/*
	rm -rf project/java/*
	rm -rf project/jsonld/*
	rm -rf project/jsonschema/*
	rm -rf project/owl/*
	rm -rf project/prefixmap/*
	rm -rf project/protobuf/*
	rm -rf project/shacl/*
	rm -rf project/shex/*
	rm -rf project/sqlschema/*
	rm -rf target/*log
	rm -rf target/*tsv
	rm -rf target/*txt

squeaky_clean: clean
	rm -rf .cogs
