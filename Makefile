.cogs:
	poetry run cogs connect -k 1OY3VzL7xk1bAiSt3JIwPR5IParlaTRcxb0aD1sEPEdI -c local/felix-sheets-4d1f37aa312b.json

org_schema_sheet.tsv: .cogs
	poetry run cogs ls
	poetry run cogs add $(subst .tsv,,$(@))
	poetry run cogs ls
	poetry run cogs fetch
	poetry run cogs pull
	# sleep step?
	ls -l $@

target/org_schema_sheet.yaml: org_schema_sheet.tsv
	poetry run sheets2linkml -o $@ $<
