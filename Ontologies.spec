/*

 */

module Ontology : Ontology
{

  /* GoID : Unique GO term id (Source: external Gene Ontology database - http://www.geneontology.org/) */
  typedef string GoID;
  /* GoDesc : Human readable text description of the corresponding GO term */
  typedef string GoDesc;
  /* Unique identifier of a species specific Gene (aka Feature entity in KBase parlence). This ID is also an external identifier
     that exists in the public databases such as Gramene, Ensembl, NCBI etc. */
  typedef string GeneID;
  /* Evidence code indicates how the annotation to a particular term is supported. See - http://www.geneontology.org/GO.evidence.shtml*/
  typedef string EvidenceCode;
  /* Captures which branch of knowledge the GO terms refers to e.g. "Biological Process", "Molecular Function", "Cellular Process" etc. */
  typedef string Domain;
  /* Ontology type, whether it's a Gene Ontology or Plant Ontology or Trait Ontology or Environment Ontology */
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
  
  /* For a given list of Features (aka Genes) from a particular genome (for example Arabidopsis thaliana) extract corresponding 
     list of GO identifiers. This function call accepts three parameters: a list of gene-identifiers, a list of ontology domains,
	 and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list
	 of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from 
	 KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't  
	 want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function
	 returns a mapping of gene-id to go-ids; note that in the returned table of results, each gene-id is associated with a list of
	 one of more go-ids. Also, a note on the input list: only one item per line is allowed. */
  funcdef getGOIDList(GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList) returns (GeneIDMap2GoIDList results);

  /* For a given list of Features from a particular genome (for example Arabidopsis thaliana) extract corresponding 
     list of GO identifiers. This function call accepts five parameters: a list of gene-identifiers, a list of ontology domains,
	 a list of evidence codes, and lower & upper bound on the number of returned go-ids that a gene-id must have. The list of gene  
	 identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the 
	 domain and the evidence-code lists is not empty then the gene-id and go-ids pairs retrieved from KBase are further filtered by 
	 using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results 
	 then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of only those 
	 gene-id to go-ids for which the count of go-ids per gene is between minimum and maximum count limit. Note that in the returned 
	 table of results, each gene-id is associated with a list of one of more go-ids. Also, a note on the input list: only one item 
	 per line is allowed.  */
  funcdef getGOIDLimitedList(GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList, int minCount, int maxCount) returns (GeneIDMap2GoIDList results);

  /* Extract GO term description for a given list of go-identifiers. This function expects an input list of go-ids (one go-id per line) 
     and returns a table of two columns, first column being the go-id and the second column being the go-term description. */
  funcdef getGoDesc(GoIDList goIDList) returns (mapping<GoID, string> results);

  /* For a given list of Features from a particular genome (for example Arabidopsis thaliana) find out the significantly enriched GO 
     terms in your feature-set. This function accepts four parameters: a list of gene-identifiers, a list of ontology domains,
	 a list of evidence codes, and ontology type (e.g. GO, PO, EO, TO etc). The list of gene identifiers cannot be empty; however 
	 the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id 
	 and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied 
	 as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists.
	 Final filtered list of the gene-id to go-ids mapping is used to calculate GO Enrichment using hypergeometric test. */
  funcdef getGOEnrichment(GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList, TestType type) returns (EnrichmentList results);  

  /* For a given list of Features from a particular genome (for example Arabidopsis thaliana) find out the significantly enriched GO 
     terms in your feature-set. This function accepts six parameters: a list of gene-identifiers, a list of ontology domains,
	 a list of evidence codes, lower & upper bound on the number of returned go-ids that a gene-id must have, and ontology 
	 type (e.g. GO, PO, EO, TO etc). The list of gene identifiers cannot be empty; however the list of ontology domains and the list of 
	 evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are 
	 further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the 
	 initial results then it is recommended to provide empty domain and evidence code lists. In any case, a mapping of only those 
	 gene-id to go-ids for which the count of go-ids per gene is between minimum and maximum count limit is carried forward. Final filtered 
	 list of the gene-id to go-ids mapping is used to calculate GO Enrichment using hypergeometric test. */
  funcdef getGOLimitedEnrichment(GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList, int minCount, int maxCount, TestType type) returns (EnrichmentList results);  
};
