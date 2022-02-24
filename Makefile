schemasheet_key = 1OY3VzL7xk1bAiSt3JIwPR5IParlaTRcxb0aD1sEPEdI
credentials_file = local/felix-sheets-4d1f37aa312b.json

.cogs:
	poetry run cogs connect -k $(schemasheet_key) -c $(credentials_file)

# requires fetch step for satisfying dependencies?
.cogs/tracked/%: .cogs
	poetry run cogs add $(subst .tsv,,$(subst .cogs/tracked/,,$@))
	poetry run cogs fetch

# --exclude graphql
# gen-docs
target/project: target/synbio_schema_sheet.yaml
	poetry run gen-project --exclude markdown --dir $@ $< 2>project.log

module = target/project/synbio_schema_sheet.py
schema = target/synbio_schema_sheet.yaml

# local/parts_202202230807_curated.tsv
target/felix_parts.yaml: target/felix_parts.tsv
	poetry run linkml-convert \
		--module $(module) \
		--output $@ \
		--target-class Container \
		--index-slot parts \
		--schema $(schema) $<

target/felix_parts.tsv:
	psql -h localhost -p 1111 -d felix -U mam -f sql/parts.sql -F'	' --no-align --pset footer > $@


target/synbio_schema_sheet.yaml: .cogs/tracked/schema.tsv .cogs/tracked/prefixes.tsv .cogs/tracked/class_defs.tsv \
.cogs/tracked/slot_usage.tsv .cogs/tracked/enums.tsv .cogs/tracked/sections_as_classes.tsv
	poetry run cogs fetch
	poetry run sheets2linkml -o $@ $^

DataHarmonizer/template/synbio-sheets/data.tsv: target/synbio_schema_sheet.yaml .cogs/tracked/validation_converter.tsv
	poetry run linkml2dataharmonizer --model_file $< --selected_class part
	cp target/data.tsv $@

DataHarmonizer/template/synbio-sheets/data.js: DataHarmonizer/template/synbio-sheets/data.tsv target/felix_parts.tsv
	cd DataHarmonizer/template/synbio-sheets/ ; poetry run python ../../script/make_data.py
	# open this URL in a browser
	# file:///home/mark/gitrepos/synbio-sheets/DataHarmonizer/main.html?template=synbio-sheets
	# the DH File-> Open
	# target/felix_parts.tsv
	# row 1 has the column headers
	#
	#Failed to map OK
	#    descendants
	#    external_url
	#    plasmid_basis
	#    selection_marker
	#    sequences
	#    modifications
	#    ancestors



# ./linkml.html LAUNCH THIS
  #./script/main_linkml.js

# ./template/linkml.py was identitical to ./template/MIxS/linkml.py
# but i have edited it
# poetry run python3 ./template/linkml.py --input ../target/synbio_schema_sheet.yaml

#./template/MIxS_soil/linkml.py

#./script/make_linkml.py
# hardcoded
# r_filename = 'data.tsv';
  #schema_filename = 'schema.yaml';

squeaky_clean: clean
	rm -rf .cogs


clean:
	#rm -rf DataHarmonizer/template/soil_emsl_jgi_mg
	rm -rf artifacts/*yaml
	rm -rf bin/*
	rm -rf docs/*
	rm -rf logs/*log
	rm -rf project
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
	rm -rf target/*yaml
	rm -rf test_parts.yaml
	rm -rf DataHarmonizer/template/synbio-sheets/data.*

