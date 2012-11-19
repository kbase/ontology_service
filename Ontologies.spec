module Ontology : Ontology
{

  /* GoID */
  typedef string GoID;
  /* GoDesc : */
  typedef string GoDesc;
  typedef string GeneID;
  typedef string EvidenceCode;
  typedef string Domain;
  typedef string TestType;
  typedef list<GoID> GoIDList;
  typedef list<GoDesc> GoDescList;
  typedef list<GeneID> GeneIDList;
  typedef list<Domain> DomainList;
  typedef list<EvidenceCode> EvidenceCodeList;
  typedef map<GeneID,GoIDList> GeneIDMap2GoIDList;

  typedef structure {
    GoID goID;
    GoDesc goDesc;
    float pvalue;
  } Enrichment;

  typedef list<Enrichment> EnrichmentList;
  
  /* get go id list */
  funcdef getGOIDList(GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList) returns GeneIDMap2GoIDList results;

  /* TODO: add documentation....get go id list */
  funcdef getGOIDLimitedList(GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList, int minCount, int maxCount) returns GeneIDMap2GoIDList results;

  /* get go id list */
  funcdef getGoDesc(GoIDList goIDList) returns map<GoID, String> results;

  /* get go id list */
  funcdef getGOIDFromTo(GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList, TestType type) returns EnrichmentList results;  

  /* get go id list */
  funcdef getGOIDFromTo(GeneIDList geneIDList, DomainList domainList, EvidenceCodeList ecList, int minCount, int maxCount, TestType type) returns EnrichmentList results;  
