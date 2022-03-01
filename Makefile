schemasheet_key = 1OY3VzL7xk1bAiSt3JIwPR5IParlaTRcxb0aD1sEPEdI
credentials_file = local/felix-sheets-4d1f37aa312b.json

module = target/project/synbio_schema_sheet.py
schema = target/synbio_schema_sheet.yaml

.PHONY: all clean

all: clean target/project target/project/synbio_schema_sheet.ttl target/felix_parts.yaml \
DataHarmonizer/template/synbio-sheets/data.js target/so_subset.owl

.cogs:
	poetry run cogs connect -k $(schemasheet_key) -c $(credentials_file)

# requires fetch step for satisfying dependencies?
.cogs/tracked/%: .cogs
	poetry run cogs add $(subst .tsv,,$(subst .cogs/tracked/,,$@))
	poetry run cogs fetch

# --exclude graphql
# gen-docs
target/project: target/synbio_schema_sheet.yaml
	poetry run gen-project \
		--exclude excel \
		--exclude java \
		--exclude markdown \
		--exclude owl \
		--dir $@ $< 2>project.log

target/project/java: target/synbio_schema_sheet.yaml target/project
	poetry run gen-java --output_directory $@ $<

target/project/synbio_schema_sheet.xlsx: target/synbio_schema_sheet.yaml target/project
	poetry run gen-excel --output $@ $<


clean_alias: clean

target/project/synbio_schema_sheet.ttl: target/synbio_schema_sheet.yaml target/project
		poetry run gen-owl --no-type-objects --no-metaclasses --output $@ $<

parts.yaml: parts.tsv target/project/synbio_schema_sheet.ttl
	poetry run linkml-convert \
		--module target/project/synbio_schema_sheet.py \
		--schema target/synbio_schema_sheet.yaml \
		--output $@ \
		--target-class Container \
		--index-slot parts $<

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

# .cogs/tracked/class_defs.tsv .cogs/tracked/enums.tsv .cogs/tracked/sections_as_classes.tsv .cogs/tracked/slot_usage.tsv .cogs/tracked/slots.tsv
target/synbio_schema_sheet.yaml: .cogs/tracked/schema.tsv .cogs/tracked/prefixes.tsv .cogs/tracked/combo.tsv .cogs/tracked/enum_do_over.tsv .cogs/tracked/sections_as_classes.tsv
	poetry run cogs fetch
	poetry run sheets2linkml -o $@ $^

DataHarmonizer/template/synbio-sheets/data.tsv: target/synbio_schema_sheet.yaml .cogs/tracked/validation_converter.tsv
	poetry run linkml2dataharmonizer --model_file $< --selected_class Part
	cp target/data.tsv $@

DataHarmonizer/template/synbio-sheets/data.js: DataHarmonizer/template/synbio-sheets/data.tsv target/felix_parts.tsv
	cd DataHarmonizer/template/synbio-sheets/ ; poetry run python ../../script/make_data.py
	# open this URL in a browser
	# file:///home/mark/gitrepos/synbio-sheets/DataHarmonizer/main.html?template=synbio-sheets
	# the DH File-> Open
	# target/felix_parts.tsv
	# row 1 has the column headers
	#
	#some failure to map are OK
#    descendants
#    ancestors
#    external_url
#    has_modifications
#    plasmid_basis
#    selection_marker
#    sequences



target/so.owl:
	wget -O $@ http://purl.obolibrary.org/obo/so.owl

bin/robot.jar:
	curl -s https://api.github.com/repos/ontodev/robot/releases/latest  | grep 'browser_download_url.*\.jar"' |  cut -d : -f 2,3 | tr -d \" | wget -O $@ -i -

target/so_subset.owl: target/so.owl bin/robot.jar
	java -jar bin/robot.jar extract \
		--method BOT \
		--input $< \
		--term-file data/so_termlist.txt \
    	--output $@

squeaky_clean: clean
	rm -rf .cogs

clean:
	#rm -rf DataHarmonizer/template/soil_emsl_jgi_mg
	rm -rf artifacts/*yaml
	rm -rf bin/*
	rm -rf docs/*
	rm -rf logs/*log
	rm -rf target/project
	rm -rf target/*log
	rm -rf target/*tsv
	rm -rf target/*txt
	rm -rf target/*yaml
	rm -rf test_parts.yaml
	rm -rf DataHarmonizer/template/synbio-sheets/data.*
	rm -rf testparts.yaml
