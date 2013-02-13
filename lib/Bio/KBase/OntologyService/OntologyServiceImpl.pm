package Bio::KBase::OntologyService::OntologyServiceImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

Ontology

=head1 DESCRIPTION

This module provides public interface/APIs for KBase gene ontology (GO) services in a species-independent manner. It encapsulates the basic functionality of extracting domain ontologies (e.g. biological process, molecular function, cellular process)  of interest for a given set of species specific genes. It only accepts KBase gene ids. External gene ids need to be converted to KBase ids. Additionally, it also allows gene ontology enrichment analysis ("hypergeometric") to be performed on a set of genes that identifies statistically overrepresented GO terms within given gene sets, say for example, GO enrichment of over-expressed genes in drought stress in plant roots. To support these key features, currently this modules provides five API-functions that are backed by custom defined data structures. Majority of these API-functions accept a list of input items (majority of them being text strings) such as list of gene-ids, list of go-ids, list of ontology-domains, and Test type ( "hypergeometric") and return the requested results as tabular dataset.

=cut

#BEGIN_HEADER
use DBI;
use POSIX;
use Bio::KBase::OntologyService::OntologySupport;
use Text::NSP::Measures::2D::Fisher::twotailed;
#use IDServerAPIClient;
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR
    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 get_goidlist

  $results = $obj->get_goidlist($geneIDList, $domainList, $ecList)

=over 4

=item Parameter and return types

=begin html

<pre>
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$results is a GeneIDMap2GoInfo
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
GeneIDMap2GoInfo is a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo
GoIDMap2GoTermInfo is a reference to a hash where the key is a GoID and the value is a GoTermInfoList
GoID is a string
GoTermInfoList is a reference to a list where each element is a GoTermInfo
GoTermInfo is a reference to a hash where the following keys are defined:
	domain has a value which is a Domain
	ec has a value which is an EvidenceCode
	desc has a value which is a GoDesc
GoDesc is a string

</pre>

=end html

=begin text

$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$results is a GeneIDMap2GoInfo
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
GeneIDMap2GoInfo is a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo
GoIDMap2GoTermInfo is a reference to a hash where the key is a GoID and the value is a GoTermInfoList
GoID is a string
GoTermInfoList is a reference to a list where each element is a GoTermInfo
GoTermInfo is a reference to a hash where the following keys are defined:
	domain has a value which is a Domain
	ec has a value which is an EvidenceCode
	desc has a value which is a GoDesc
GoDesc is a string


=end text



=item Description

This function call accepts three parameters: a list of kbase gene-identifiers, a list of ontology domains, and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of kbase gene id to go-ids along with go-description, ontology domain, and evidence code; note that in the returned table of results, each gene-id is associated with a list of one of more go-ids. Also, if no species is provided as input then by default, Arabidopsis thaliana is used as the input species.

=back

=cut

sub get_goidlist
{
    my $self = shift;
    my($geneIDList, $domainList, $ecList) = @_;

    my @_bad_arguments;
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"domainList\" (value was \"$domainList\")");
    (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ecList\" (value was \"$ecList\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_goidlist:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_goidlist');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN get_goidlist
    #my $dbh = DBI->connect("DBI:mysql:networks_pdev;host=db1.chicago.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
    my $dbh = DBI->connect("DBI:mysql:kbase_plant;host=devdb1.newyork.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
  
    if(defined $dbh->err && $dbh->err != 0) { # if there is any error
      return []; # return empty list
    }

    my %domainMap = map {$_ => 1} @{$domainList};
    my %ecMap = map {$_ => 1} @{$ecList};

    my %g2idlist = (); # gene to id list
    $results = \%g2idlist;
    my $pstmt_exc = $dbh->prepare("select DISTINCT OntologyID, OntologyDescription, OntologyDomain, OntologyEvidenceCode from ontologies_int where kblocusid = ? and OntologyType = 'GO'");
    my $pstmt;
    foreach my $geneID (@{$geneIDList}) {

      $pstmt_exc->bind_param(1, $geneID);
      $pstmt_exc->execute();
      $pstmt = $pstmt_exc;
      while( my @data = $pstmt->fetchrow_array()) {
        next if (! defined $domainMap{$data[2]}) && ($#$domainList > -1);
        next if (! defined $ecMap{$data[3]}) && ($#$ecList > -1);
        $g2idlist{$geneID} = {} if(! defined $g2idlist{$geneID}) ;
        $g2idlist{$geneID}->{$data[0]} = [] if(! defined $g2idlist{$geneID}->{$data[0]});
        push $g2idlist{$geneID}->{$data[0]}, {'domain' => $data[2], 'ec' => $data[3], 'desc' => $data[1]};
      } # end of fetch and counting
    } # end of types

    #END get_goidlist
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_goidlist:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_goidlist');
    }
    return($results);
}




=head2 get_go_description

  $results = $obj->get_go_description($goIDList)

=over 4

=item Parameter and return types

=begin html

<pre>
$goIDList is a GoIDList
$results is a reference to a hash where the key is a GoID and the value is a StringArray
GoIDList is a reference to a list where each element is a GoID
GoID is a string
StringArray is a reference to a list where each element is a string

</pre>

=end html

=begin text

$goIDList is a GoIDList
$results is a reference to a hash where the key is a GoID and the value is a StringArray
GoIDList is a reference to a list where each element is a GoID
GoID is a string
StringArray is a reference to a list where each element is a string


=end text



=item Description

Extract GO term description for a given list of GO identifiers. This function expects an input list of GO-ids (white space or comman separated) and returns a table of three columns, first column being the GO ids,  the second column is the GO description and third column is GO domain (biological process, molecular function, cellular component

=back

=cut

sub get_go_description
{
    my $self = shift;
    my($goIDList) = @_;

    my @_bad_arguments;
    (ref($goIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"goIDList\" (value was \"$goIDList\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_go_description:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_go_description');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN get_go_description
    #my $dbh = DBI->connect("DBI:mysql:networks_pdev;host=db1.chicago.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
    my $dbh = DBI->connect("DBI:mysql:kbase_plant;host=devdb1.newyork.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
        
  
    if(defined $dbh->err && $dbh->err != 0) { # if there is any error
      return []; # return empty list
    }

    my %go2desc = (); # gene to id list
    $results = \%go2desc;
    my $pstmt = $dbh->prepare("select OntologyDescription, OntologyDomain from ontologies_int where OntologyID = ? and OntologyType = 'GO'");
my @tm_goID;	
 foreach my $goID (@{$goIDList}) {
	@tm_goID=split/\t/,$goID;
	$goID=$tm_goID[0];
      $pstmt->bind_param(1, $goID);
      $pstmt->execute();
      while( my @data = $pstmt->fetchrow_array()) {
        $go2desc{$goID} = [$data[0],$data[1]];
      } # end of fetch and counting
    } # end of types
    #END get_go_description
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_go_description:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_go_description');
    }
    return($results);
}




=head2 get_go_enrichment

  $results = $obj->get_go_enrichment($geneIDList, $domainList, $ecList, $type, $ontologytype)

=over 4

=item Parameter and return types

=begin html

<pre>
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$type is a TestType
$ontologytype is an ontology_type
$results is an EnrichmentList
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
TestType is a string
ontology_type is a string
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

$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$type is a TestType
$ontologytype is an ontology_type
$results is an EnrichmentList
GeneIDList is a reference to a list where each element is a GeneID
GeneID is a string
DomainList is a reference to a list where each element is a Domain
Domain is a string
EvidenceCodeList is a reference to a list where each element is an EvidenceCode
EvidenceCode is a string
TestType is a string
ontology_type is a string
EnrichmentList is a reference to a list where each element is an Enrichment
Enrichment is a reference to a hash where the following keys are defined:
	goID has a value which is a GoID
	goDesc has a value which is a GoDesc
	pvalue has a value which is a float
GoID is a string
GoDesc is a string


=end text



=item Description

For a given list of kbase gene ids from a particular genome (for example "Athaliana" ) find out the significantly enriched GO terms in your gene set. This function accepts four parameters: A list of kbase gene-identifiers, a list of ontology domains (e.g."biological process", "molecular function", "cellular component"), a list of evidence codes (e.g."IEA","IDA","IEP" etc.), and test type (e.g. "hypergeometric"). The list of kbase gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Final filtered list of the kbase gene-id to go-ids mapping is used to calculate GO enrichment using hypergeometric test and provides pvalues.The default pvalue cutoff is used as 0.05. Also, if input species is not provided then by default Arabidopsis thaliana is considered the input species. The current released version ignores test type and by default, it uses hypergeometric test. So even if you do not provide TestType, it will do hypergeometric test.

=back

=cut

sub get_go_enrichment
{
    my $self = shift;
    my($geneIDList, $domainList, $ecList, $type, $ontologytype) = @_;

    my @_bad_arguments;
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"domainList\" (value was \"$domainList\")");
    (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ecList\" (value was \"$ecList\")");
    (!ref($type)) or push(@_bad_arguments, "Invalid type for argument \"type\" (value was \"$type\")");
    (!ref($ontologytype)) or push(@_bad_arguments, "Invalid type for argument \"ontologytype\" (value was \"$ontologytype\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_go_enrichment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_go_enrichment');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN get_go_enrichment
    my $frst = get_goidlist($self, $geneIDList, $domainList, $ecList);
    my %ukey = ();
   my @tem_goID=();
	foreach my $geneID (keys %{$frst}) {
		foreach my $goID (keys %{$frst->{$geneID}}) {
       		if(defined $ukey{$goID}) {
          		$ukey{$goID} = $ukey{$goID} + 1;
       		} else {
          		$ukey{$goID} = 1;
        	}
      		}
    }

    $results = [];

    my $geneSize = $#$geneIDList + 1;
    my @goIDList = keys %ukey;
	my $sname;
    $$geneIDList[0] =~ m/^(kb\|g\.\d+\.)/;
    $sname = $1;
    # TODO: throw exception if there is no match
    #$sname="Athaliana" if $geneIDList =~/g\.3899/;
    #$sname="Ptrichocarpa" if $geneIDList =~/g\.3907/;

    my $rh_goDescList = get_go_description($self, \@goIDList);
    my $rh_goID2Count = getGoSize( $sname, \@goIDList, $domainList, $ecList, $ontologytype);
    my $wholeGeneSize = 10000;
    #my $dbh = DBI->connect("DBI:mysql:networks_pdev;host=db1.chicago.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
    my $dbh = DBI->connect("DBI:mysql:kbase_plant;host=devdb1.newyork.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
    my  $pstmt = $dbh->prepare("select count( distinct kblocusid) from ontologies_int where kblocusid like '$sname%'");
    $pstmt->execute();
    my $res=$pstmt->fetchrow_hashref();
    foreach (keys %$res){
      $wholeGeneSize=$res->{$_};
      last;
    }
          
    for(my $i = 0; $i <= $#goIDList; $i= $i+1) {
      my $goDesc = $rh_goDescList->{$goIDList[$i]};
      my $goSize = $rh_goID2Count->{$goIDList[$i]};

	 # calc p-value using any h.g. test
      my %rst = ();
      $rst{"pvalue"} = calculateStatistic(n11 => $ukey{$goIDList[$i]}, n1p => $geneSize, np1 => $goSize, npp => $wholeGeneSize);
      $rst{"goDesc"} = $goDesc;
      $rst{"goID"} = $goIDList[$i];
      push @$results, \%rst;
    }
    
    #END get_go_enrichment
    my @_bad_returns;
    (ref($results) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_go_enrichment:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_go_enrichment');
    }
    return($results);
}




=head2 version 

  $return = $obj->version()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module version. This is a Semantic Versioning number.

=back

=cut

sub version {
    return $VERSION;
}

=head1 TYPES



=head2 Species

=over 4



=item Description

Plant Species names.
    
     The current list of plant species includes: 
     Alyrata: Arabidopsis lyrata
     Athaliana: Arabidopsis thaliana
     Bdistachyon: Brachypodium distachyon
     Creinhardtii: Chlamydomonas reinhardtii
     Gmax: Glycine max
     Oglaberrima: Oryza glaberrima
     Oindica: Oryza sativa indica
     Osativa: Oryza sativa japonica
     Ptrichocarpa: Populus trichocarpa 
     Sbicolor: Sorghum bicolor 
     Smoellendorffii:  Selaginella moellendorffii
     Vvinifera: Vitis vinefera 
     Zmays: Zea mays


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoID

=over 4



=item Description

GoID : Unique GO term id (Source: external Gene Ontology database - http://www.geneontology.org/)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoDesc

=over 4



=item Description

GoDesc : Human readable text description of the corresponding GO term


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GeneID

=over 4



=item Description

Unique identifier of a species specific Gene (aka Feature entity in KBase parlence). This ID is an external identifier that exists in the public databases such as Gramene, Ensembl, NCBI etc.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 EvidenceCode

=over 4



=item Description

Evidence code indicates how the annotation to a particular term is supported. 
The list of evidence codes includes Experimental, Computational Analysis, Author statement, Curator statement, Automatically assigned and Obsolete evidence codes. This list will be useful in selecting the correct evidence code for an annotation. The details are given below: 

+  Experimental Evidence Codes
EXP: Inferred from Experiment
IDA: Inferred from Direct Assay
IPI: Inferred from Physical Interaction
IMP: Inferred from Mutant Phenotype
IGI: Inferred from Genetic Interaction
IEP: Inferred from Expression Pattern
    
+ Computational Analysis Evidence Codes
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
    
+ Author Statement Evidence Codes
TAS: Traceable Author Statement
NAS: Non-traceable Author Statement
    
+ Curator Statement Evidence Codes
IC: Inferred by Curator
ND: No biological Data available
    
+ Automatically-assigned Evidence Codes
IEA: Inferred from Electronic Annotation
    
+ Obsolete Evidence Codes
NR: Not Recorded


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 Domain

=over 4



=item Description

Captures which branch of knowledge the GO terms refers to e.g. "biological_process", "molecular_function", "cellular_component" etc.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 TestType

=over 4



=item Description

Test type, whether it's "hypergeometric" and "chisq"


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoIDList

=over 4



=item Description

A list of ontology identifiers


=item Definition

=begin html

<pre>
a reference to a list where each element is a GoID
</pre>

=end html

=begin text

a reference to a list where each element is a GoID

=end text

=back



=head2 GoDescList

=over 4



=item Description

a list of GO terms description


=item Definition

=begin html

<pre>
a reference to a list where each element is a GoDesc
</pre>

=end html

=begin text

a reference to a list where each element is a GoDesc

=end text

=back



=head2 GeneIDList

=over 4



=item Description

A list of gene identifiers from same species


=item Definition

=begin html

<pre>
a reference to a list where each element is a GeneID
</pre>

=end html

=begin text

a reference to a list where each element is a GeneID

=end text

=back



=head2 DomainList

=over 4



=item Description

A list of ontology domains


=item Definition

=begin html

<pre>
a reference to a list where each element is a Domain
</pre>

=end html

=begin text

a reference to a list where each element is a Domain

=end text

=back



=head2 StringArray

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a string
</pre>

=end html

=begin text

a reference to a list where each element is a string

=end text

=back



=head2 EvidenceCodeList

=over 4



=item Description

A list of ontology term evidence codes. One ontology term can have one or more evidence codes.


=item Definition

=begin html

<pre>
a reference to a list where each element is an EvidenceCode
</pre>

=end html

=begin text

a reference to a list where each element is an EvidenceCode

=end text

=back



=head2 ontology_type

=over 4



=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 GoTermInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
domain has a value which is a Domain
ec has a value which is an EvidenceCode
desc has a value which is a GoDesc

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
domain has a value which is a Domain
ec has a value which is an EvidenceCode
desc has a value which is a GoDesc


=end text

=back



=head2 GoTermInfoList

=over 4



=item Definition

=begin html

<pre>
a reference to a list where each element is a GoTermInfo
</pre>

=end html

=begin text

a reference to a list where each element is a GoTermInfo

=end text

=back



=head2 GoIDMap2GoTermInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a GoID and the value is a GoTermInfoList
</pre>

=end html

=begin text

a reference to a hash where the key is a GoID and the value is a GoTermInfoList

=end text

=back



=head2 GeneIDMap2GoInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo
</pre>

=end html

=begin text

a reference to a hash where the key is a GeneID and the value is a GoIDMap2GoTermInfo

=end text

=back



=head2 Enrichment

=over 4



=item Description

A composite data structure to capture ontology enrichment type object


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
goID has a value which is a GoID
goDesc has a value which is a GoDesc
pvalue has a value which is a float

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
goID has a value which is a GoID
goDesc has a value which is a GoDesc
pvalue has a value which is a float


=end text

=back



=head2 EnrichmentList

=over 4



=item Description

A list of ontology enrichment objects


=item Definition

=begin html

<pre>
a reference to a list where each element is an Enrichment
</pre>

=end html

=begin text

a reference to a list where each element is an Enrichment

=end text

=back



=cut

1;
