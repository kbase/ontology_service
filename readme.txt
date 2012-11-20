new repo created Nov 2012
for i in `ls /homes/chicago/thomasoniii/ontology_dumps/`; do grep -v '^TranscriptID' /homes/chicago/thomasoniii/ontology_dumps/$i/ontology.tab | sed "s/^/$i\",\"/"; done | sed 's/\t/","/g' | sed 's/^/INSERT INTO ontologies VALUES("/' | sed 's/$/");/'  > ontologies.sql;
