new repo created Nov 2012
for i in `ls /homes/chicago/thomasoniii/ontology_dumps/*/*.tab`; do grep -v '^TranscriptID'  $i; done | sed 's/\t/","/g' | sed 's/^/INSERT INTO ontologies VALUES("/' | sed 's/$/");/'  > ontologies.sql;
