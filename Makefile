# This Makefile encodes the entirety of IMPCs ontology dependencies

OBO=http://purl.obolibrary.org/obo
ROBOT=robot
ONTOLOGIES=mp mp-ext-merged ma emapa uberon eco efo emap mp-hp mmusdv mpath pato
TABLES=mp ma emapa uberon eco efo emap mmusdv mpath pato
ONTOLOGY_FILES = $(patsubst %, ontologies/%.owl, $(ONTOLOGIES))
TABLE_FILES = $(patsubst %, tables/%.csv, $(TABLES))
MIR=true
GIT_UPHENO=https://github.com/obophenotype/upheno.git

ontologies/%.owl:
	$(ROBOT) merge -I $(OBO)/$*.owl -o $@
	#echo "Skipping mirrors"

ontologies/efo.owl:
	$(ROBOT) merge -I http://www.ebi.ac.uk/efo/efo.owl -o $@
	#echo "Skipping mirrors"

ontologies/mp-ext-merged.owl:
	$(ROBOT) merge -I https://raw.githubusercontent.com/obophenotype/mammalian-phenotype-ontology/master/scratch/mp-ext-merged.owl -o $@

tmp/upheno:
	git clone $(GIT_UPHENO) $@

tmp/upheno/mp-hp-view.owl: tmp/upheno
	cd  $< && make -B mp-hp-view.owl

ontologies/mp-hp.owl: #tmp/upheno/mp-hp-view.owl
	cp $< $@

tables/%.csv: ontologies/%.owl
	$(ROBOT) query --use-graphs true -f csv -i $< --query sparql/$*_metadata_table.sparql $@

dirs:
	mkdir -p tmp
	mkdir -p tables
	mkdir -p ontologies

clean: 
	rm -r tmp

impc_ontologies: dirs $(ONTOLOGY_FILES) $(TABLE_FILES)
	tar cvzf impc_ontologies.tar.gz $(ONTOLOGY_FILES) $(TABLE_FILES)