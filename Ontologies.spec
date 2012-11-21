=head1 Ontology module specifications

 This module provides public interface/APIs for KBase gene ontology (GO) services in a species-independent manner. It encapsulates the basic functionality of extracting domain ontologies (e.g. biological process, molecular function, cellular process)  of interest for a given set of species specific genes. Additionally, it also allows gene ontology enrichment analysis ("hypergeometric" and "chisq") to be performed on a set of genes that identifies statistically overrepresented GO terms within given gene sets, say for example, GO enrichment of over-expressed genes in drought stress in plant roots. To support these key features, currently this modules provides five API-functions that are backed by custom defined data structures. Majority of these API-functions accept a list of input items (majority of them being text strings) such as list of gene-ids, list of go-ids, list of ontology-domains, and Testtype (right now it is ignored but "hypergeometric" and "chisq" will be included) and return the requested results as tabular dataset. 

=head2 Plant Species

 The current list of plant species includes: 
 Alyrata: Arabidopsis lyrata
 Athaliana: Arabidopsis thaliana
 Bdistachyon: Brachypodium distachyon
 Creinhardtii: Chlamydomonas reinhardtii
 Gmax: Glycine max
 Oglaberrima: Oryza glaberrima
 Oindica: Oryza sativa indiaca
 Osativa: Oryza sativa japonica
 Ptrichocarpa: Populus trichocarpa 
 Sbicolor: Sorghum bicolor 
 Smoellendorffii:  Selaginella moellendorffii
 Vvinifera: Vitis vinefera 
 Zmays: Zea mays

=head2 GO Domains

 The list of GO domain includes: biological process, molecular function, cellular content.

=head2 GO Enrichment Tests

 The list of GO enrichment test type includes hypergeometric test, chi-square test for assessing overrepresentation of GO categories. Hypergeometric test should be selected when the input list is compared with the previously computed background or it is a subset of reference list (this test will be used as default). Ch-square test should be selected when the input list has few or no intersections with the reference list. Bonferroni or Benjamini & Hochberg correction will also be included later.

=head2 Ontology Evidence Codes

 The list of evidence codes includes Experimental, Computational Analysis, Author statement, Curator statement, Automatically assigned and Obsolete evidence codes. This list will be useful in selecting the correct evidence code for an annotation. The details are given below: 

=head3 Experimental Evidence Codes

 EXP: Inferred from Experiment
 IDA: Inferred from Direct Assay
 IPI: Inferred from Physical Interaction
 IMP: Inferred from Mutant Phenotype
 IGI: Inferred from Genetic Interaction
 IEP: Inferred from Expression Pattern

=head3 Computational Analysis Evidence Codes

 ISS: Inferred from Sequence or Structural Similarity
 ISO: Inferred from Sequence Orthology
 ISA: Inferred from Sequence Alignment
 ISM: Inferred from Sequence Model
 IGC: Inferred from Genomic Context
 IBA: Inferred from Biological aspect of Ancestor
 IBD: Inferred from Biological aspect of Descendant
 IKR: Inferred from Key Residues
 IRD: Inferred from Rapid Divergence
 RCA: inferred from Reviewed Computational Analysis

=head3 Author Statement Evidence Codes

 TAS: Traceable Author Statement
 NAS: Non-traceable Author Statement

=head3 Curator Statement Evidence Codes

 IC: Inferred by Curator
 ND: No biological Data available

=head3 Automatically-assigned Evidence Codes

 IEA: Inferred from Electronic Annotation

=head3 Obsolete Evidence Codes

 NR: Not Recorded

=cut

module Ontology : Ontology
{

  typedef string Species;
  /* GoID : Unique GO term id (Source: external Gene Ontology database - http://www.geneontology.org/) */
  typedef string GoID;

  /* GoDesc : Human readable text description of the corresponding GO term */
  typedef string GoDesc;

  /* Unique identifier of a species specific Gene (aka Feature entity in KBase parlence). This ID is also an external identifier
     that exists in the public databases such as Gramene, Ensembl, NCBI etc. */
  typedef string GeneID;

  /* Evidence code indicates how the annotation to a particular term is supported. Different types of evidence codes that includes Experimental, Computational Analysis etc. (details are given above)  */
  typedef string EvidenceCode;

  /* Captures which branch of knowledge the GO terms refers to e.g. "Biological Process", "Molecular Function", "Cellular Process" etc. */
  typedef string Domain;

  /* Test type, whether it's "hypergeometric" and "chisq"  */
  typedef string TestType;

  /* A list of ontology identifiers */
  typedef list<GoID> GoIDList;

  /* a list of GO terms description */
  typedef list<GoDesc> GoDescList;

  /* A list of gene identifiers from same species */
  typedef list<GeneID> GeneIDList;

  /* A list of ontology domains */
  typedef list<Domain> DomainList;

  /* A list of ontology term evidence codes. One ontology term can have one or more evidence codes. */
  typedef list<EvidenceCode> EvidenceCodeList;

  /* A list of gene-id to go-id mappings. One gene-id can have one or more go-ids associated with it. */
  typedef mapping<GeneID,GoIDList> GeneIDMap2GoIDList;

  /* A composite data structure to capture ontology enrichment type object */
  typedef structure {
    GoID goID;
    GoDesc goDesc;
    float pvalue;
  } Enrichment;

  /* A list of ontology enrichment objects */
  typedef list<Enrichment> EnrichmentList;
  
=head1 getGOIDList

Example:

    getGOIDList [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifier. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the identifier.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Documentation for underlying call

 For a given list of Features (aka Genes) from a particular genome (for example "Athaliana" Arabidopsis thaliana ) extract corresponding list of GO identifiers. This function call accepts four parameters: species name, a list of gene-identifiers, a list of ontology domains, and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of gene-id to go-ids; note that in the returned table of results, each gene-id is associated with a list of one of more go-ids. Also, a note on the input list: only one item per line is allowed.

=over 4

=item Parameter and return types

=begin html

<pre>
$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$results is a GeneIDMap2GoIDList
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
GeneIDMap2GoIDList is a reference to a hash where the key is a GeneID and the value is a GoIDList
GoIDList is a reference to a list where each element is a GoID
GoID is a string

</pre>

=end html

=begin text

$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$results is a GeneIDMap2GoIDList
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
GeneIDMap2GoIDList is a reference to a hash where the key is a GeneID and the value is a GoIDList
GoIDList is a reference to a list where each element is a GoID
GoID is a string

=end text

=cut

  funcdef getGOIDList(Species sname, GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList) returns (GeneIDMap2GoIDList results);



=head1 getGOIDLimitedList

Example:

    getGOIDLimitedList [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifier. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the identifier.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Documentation for underlying call

 For a given list of Features from a particular genome (for example "Athaliana") extract corresponding list of GO identifiers. This function call accepts six parameters: species name, a list of gene-identifiers, a list of ontology domains, a list of evidence codes, and lower & upper bound on the number of returned go-ids that a gene-id must have. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the domain and the evidence-code lists is not empty then the gene-id and go-ids pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results  then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of only those gene-id to go-ids for which the count of go-ids per gene is between minimum and maximum count limit. Note that in the returned table of results, each gene-id is associated with a list of one of more go-ids. Also, a note on the input list: only one item per line is allowed.

=over 4

=item Parameter and return types

=begin html

<pre>
$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$minCount is an int
$maxCount is an int
$results is a GeneIDMap2GoIDList
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
GeneIDMap2GoIDList is a reference to a hash where the key is a GeneID and the value is a GoIDList
GoIDList is a reference to a list where each element is a GoID
GoID is a string

</pre>

=end html

=begin text

$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$minCount is an int
$maxCount is an int
$results is a GeneIDMap2GoIDList
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
GeneIDMap2GoIDList is a reference to a hash where the key is a GeneID and the value is a GoIDList
GoIDList is a reference to a list where each element is a GoID
GoID is a string

=end text

=cut

  funcdef getGOIDLimitedList(Species sname, GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList, int minCount, int maxCount) returns (GeneIDMap2GoIDList results);



=head1 getGoDesc

Example:

    getGoDesc [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifier. If another column contains the identifier use.

    -c N

where N is the column (from 1) that contains the identifier.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Documentation for underlying call

Extract GO term description for a given list of go-identifiers. This function expects an input list of go-ids (one go-id per line) and returns a table of two columns, first column being the go-id and the second column being the go-term description.

=over 4

=item Parameter and return types

=begin html

<pre>
$goIDList is a GoIDList
$results is a reference to a hash where the key is a GoID and the value is a string
GoIDList is a reference to a list where each element is a GoID
GoID is a string

</pre>

=end html

=begin text

$goIDList is a GoIDList
$results is a reference to a hash where the key is a GoID and the value is a string
GoIDList is a reference to a list where each element is a GoID
GoID is a string

=end text

=cut

  funcdef getGoDesc(GoIDList goIDList) returns (mapping<GoID, string> results);


=head1 getGOEnrichment

Example:

    getGOEnrichment [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifier. If another column contains the identifier use

    -c N

where N is the column (from 1) that contains the identifier.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Documentation for underlying call

 For a given list of Features from a particular genome (for example "Athaliana" ) find out the significantly enriched GO terms in your feature-set. This function accepts five parameters: Species name, a list of gene-identifiers, a list of ontology domains, a list of evidence codes, and test type (e.g. "hypergeometric" and "chisq"). The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Final filtered list of the gene-id to go-ids mapping is used to calculate GO Enrichment using hypergeometric or chi-square test.

=over 4

=item Parameter and return types

=begin html

<pre>
$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$type is a TestType
$results is an EnrichmentList
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
TestType is a string
EnrichmentList is a reference to a list where each element is an Enrichment
Enrichment is a reference to a hash where the following keys are defined:
	goID has a value which is a GoID
	goDesc has a value which is a GoDesc
	pvalue has a value which is a float
GoID is a string
GoDesc is a string

</pre>

=end html

=begin text

$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$type is a TestType
$results is an EnrichmentList
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
TestType is a string
EnrichmentList is a reference to a list where each element is an Enrichment
Enrichment is a reference to a hash where the following keys are defined:
	goID has a value which is a GoID
	goDesc has a value which is a GoDesc
	pvalue has a value which is a float
GoID is a string
GoDesc is a string


=end text


=cut

  funcdef getGOEnrichment(Species sname, GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList, TestType type) returns (EnrichmentList results);  



=head1 getGOLimitedEnrichment

Example:

    getGOLimitedEnrichment [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifier. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the identifier.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Documentation for underlying call

For a given list of Features from a particular genome (for example Arabidopsis thaliana) find out the significantly enriched GO 
terms in your feature-set. This function accepts seven parameters: Specie name, a list of gene-identifiers, a list of ontology domains,
    a list of evidence codes, lower & upper bound on the number of returned go-ids that a gene-id must have, and ontology 
    type (e.g. GO, PO, EO, TO etc). The list of gene identifiers cannot be empty; however the list of ontology domains and the list of 
    evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are 
    further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the 
    initial results then it is recommended to provide empty domain and evidence code lists. In any case, a mapping of only those 
    gene-id to go-ids for which the count of go-ids per gene is between minimum and maximum count limit is carried forward. Final filtered 
    list of the gene-id to go-ids mapping is used to calculate GO Enrichment using hypergeometric test.

=over 4

=item Parameter and return types

=begin html

<pre>
$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$minCount is an int
$maxCount is an int
$type is a TestType
$results is an EnrichmentList
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
TestType is a string
EnrichmentList is a reference to a list where each element is an Enrichment
Enrichment is a reference to a hash where the following keys are defined:
	goID has a value which is a GoID
	goDesc has a value which is a GoDesc
	pvalue has a value which is a float
GoID is a string
GoDesc is a string

</pre>

=end html

=begin text

$sname is a Species
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$minCount is an int
$maxCount is an int
$type is a TestType
$results is an EnrichmentList
Species is a string
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
TestType is a string
EnrichmentList is a reference to a list where each element is an Enrichment
Enrichment is a reference to a hash where the following keys are defined:
	goID has a value which is a GoID
	goDesc has a value which is a GoDesc
	pvalue has a value which is a float
GoID is a string
GoDesc is a string


=end text

=cut

  funcdef getGOLimitedEnrichment(Species sname, GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList, int minCount, int maxCount, TestType type) returns (EnrichmentList results);  
};
