package Bio::KBase::OntologyService::OntologyServiceImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

Ontology

=head1 DESCRIPTION

This module provides public interface/APIs for KBase gene ontology (GO) services in a species-independent manner. It encapsulates the basic functionality of extracting domain ontologies (e.g. biological process, molecular function, cellular process)  of interest for a given set of species specific genes. Additionally, it also allows gene ontology enrichment analysis ("hypergeometric" and "chisq") to be performed on a set of genes that identifies statistically overrepresented GO terms within given gene sets, say for example, GO enrichment of over-expressed genes in drought stress in plant roots. To support these key features, currently this modules provides five API-functions that are backed by custom defined data structures. Majority of these API-functions accept a list of input items (majority of them being text strings) such as list of gene-ids, list of go-ids, list of ontology-domains, and Testtype (right now it is ignored but "hypergeometric" and "chisq" will be included) and return the requested results as tabular dataset.

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



=head2 getGOIDList

  $results = $obj->getGOIDList($sname, $geneIDList, $domainList, $ecList)

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



=item Description

For a given list of Features (aka Genes) from a particular genome (for example "Athaliana" Arabidopsis thaliana ) extract corresponding list of GO identifiers. This function call accepts four parameters: species name, a list of gene-identifiers, a list of ontology domains, and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of gene-id to go-ids; note that in the returned table of results, each gene-id is associated with a list of one of more go-ids. Also, a note on the input list: only one item per line is allowed.

=back

=cut

sub getGOIDList
{
    my $self = shift;
    my($sname, $geneIDList, $domainList, $ecList) = @_;

    my @_bad_arguments;
    (!ref($sname)) or push(@_bad_arguments, "Invalid type for argument \"sname\" (value was \"$sname\")");
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"domainList\" (value was \"$domainList\")");
    (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ecList\" (value was \"$ecList\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to getGOIDList:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGOIDList');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN getGOIDList
    my $dbh = DBI->connect("DBI:mysql:networks_pdev;host=db1.chicago.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
  
    if(defined $dbh->err && $dbh->err != 0) { # if there is any error
      return []; # return empty list
    }

    my %domainMap = map {$_ => 1} @{$domainList};
    my %ecMap = map {$_ => 1} @{$ecList};

    my %g2idlist = (); # gene to id list
    $results = \%g2idlist;
    my $pstmt = $dbh->prepare("select OntologyID, OntologyDescription, OntologyDomain, OntologyEvidenceCode from ontologies where SName = '$sname' and TranscriptID = ? and OntologyType = 'GO'");
    foreach my $geneID (@{$geneIDList}) {

      $pstmt->bind_param(1, $geneID);
      $pstmt->execute();
      while( my @data = $pstmt->fetchrow_array()) {
        next if ! defined $domainMap{$data[2]};
        next if ! defined $ecMap{$data[3]};
        $g2idlist{$geneID} = [] if(! defined $g2idlist{$geneID}) ;
        push $g2idlist{$geneID}, $data[0];
      } # end of fetch and counting
    } # end of types

    #END getGOIDList
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to getGOIDList:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGOIDList');
    }
    return($results);
}




=head2 getGOIDLimitedList

  $results = $obj->getGOIDLimitedList($sname, $geneIDList, $domainList, $ecList, $minCount, $maxCount)

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



=item Description

For a given list of Features from a particular genome (for example "Athaliana") extract corresponding list of GO identifiers. This function call accepts six parameters: species name, a list of gene-identifiers, a list of ontology domains, a list of evidence codes, and lower & upper bound on the number of returned go-ids that a gene-id must have. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the domain and the evidence-code lists is not empty then the gene-id and go-ids pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results  then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of only those gene-id to go-ids for which the count of go-ids per gene is between minimum and maximum count limit. Note that in the returned table of results, each gene-id is associated with a list of one of more go-ids. Also, a note on the input list: only one item per line is allowed.

=back

=cut

sub getGOIDLimitedList
{
    my $self = shift;
    my($sname, $geneIDList, $domainList, $ecList, $minCount, $maxCount) = @_;

    my @_bad_arguments;
    (!ref($sname)) or push(@_bad_arguments, "Invalid type for argument \"sname\" (value was \"$sname\")");
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"domainList\" (value was \"$domainList\")");
    (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ecList\" (value was \"$ecList\")");
    (!ref($minCount)) or push(@_bad_arguments, "Invalid type for argument \"minCount\" (value was \"$minCount\")");
    (!ref($maxCount)) or push(@_bad_arguments, "Invalid type for argument \"maxCount\" (value was \"$maxCount\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to getGOIDLimitedList:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGOIDLimitedList');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN getGOIDLimitedList
    my $frst = getGOIDList($self, $sname, $geneIDList, $domainList, $ecList);

    my %trst = ();
    $results = \%trst;
    
    foreach my $key (keys %{$frst}) {
      my $n = $#{$frst->{$key}};
      $trst{$key}= $frst->{$key} if($n >= $minCount && $n <= $maxCount);
    }

    #END getGOIDLimitedList
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to getGOIDLimitedList:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGOIDLimitedList');
    }
    return($results);
}




=head2 getGoDesc

  $results = $obj->getGoDesc($goIDList)

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



=item Description

Extract GO term description for a given list of go-identifiers. This function expects an input list of go-ids (one go-id per line) and returns a table of two columns, first column being the go-id and the second column being the go-term description.

=back

=cut

sub getGoDesc
{
    my $self = shift;
    my($goIDList) = @_;

    my @_bad_arguments;
    (ref($goIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"goIDList\" (value was \"$goIDList\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to getGoDesc:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGoDesc');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN getGoDesc
    my $dbh = DBI->connect("DBI:mysql:networks_pdev;host=db1.chicago.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
  
    if(defined $dbh->err && $dbh->err != 0) { # if there is any error
      return []; # return empty list
    }

    my %go2desc = (); # gene to id list
    $results = \%go2desc;
    my $pstmt = $dbh->prepare("select OntologyDescription from ontologies where OntologyID = ? and OntologyType = 'GO'");
    foreach my $goID (@{$goIDList}) {

      $pstmt->bind_param(1, $goID);
      $pstmt->execute();
      while( my @data = $pstmt->fetchrow_array()) {
        $go2desc{$goID} = $data[0];
      } # end of fetch and counting
    } # end of types
    #END getGoDesc
    my @_bad_returns;
    (ref($results) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to getGoDesc:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGoDesc');
    }
    return($results);
}




=head2 getGOEnrichment

  $results = $obj->getGOEnrichment($sname, $geneIDList, $domainList, $ecList, $type)

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



=item Description

For a given list of Features from a particular genome (for example "Athaliana" ) find out the significantly enriched GO terms in your feature-set. This function accepts five parameters: Species name, a list of gene-identifiers, a list of ontology domains, a list of evidence codes, and test type (e.g. "hypergeometric" and "chisq"). The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Final filtered list of the gene-id to go-ids mapping is used to calculate GO Enrichment using hypergeometric or chi-square test.

=back

=cut

sub getGOEnrichment
{
    my $self = shift;
    my($sname, $geneIDList, $domainList, $ecList, $type) = @_;

    my @_bad_arguments;
    (!ref($sname)) or push(@_bad_arguments, "Invalid type for argument \"sname\" (value was \"$sname\")");
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"domainList\" (value was \"$domainList\")");
    (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ecList\" (value was \"$ecList\")");
    (!ref($type)) or push(@_bad_arguments, "Invalid type for argument \"type\" (value was \"$type\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to getGOEnrichment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGOEnrichment');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN getGOEnrichment
    my $frst = getGOIDList($self, $sname, $geneIDList, $domainList, $ecList);
    my %ukey = ();
    foreach my $geneID (keys %{$frst}) {
      foreach my $goID (@{$frst->{$geneID}}) {
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
    my $rh_goDescList = getGoDesc($self, \@goIDList);
    my $rh_goID2Count = getGoSize($sname, \@goIDList, $domainList, $ecList);
    for(my $i = 0; $i <= $#goIDList; $i= $i+1) {
      my $goDesc = $rh_goDescList->{$goIDList[$i]};
      my $goSize = $rh_goID2Count->{$goIDList[$i]};
      my $wholeGeneSize = 22000; # temporary... based on gene ID <-- need to be changed...
      # calc p-value using any h.g. test
      my %rst = ();
      $rst{"pvalue"} = calculateStatistic(n11 => $ukey{$goIDList[$i]}, n1p => $geneSize, np1 => $goSize, npp => $wholeGeneSize);
      $rst{"goDesc"} = $goDesc;
      $rst{"goID"} = $goIDList[$i];
      push @$results, \%rst;
    }
    
    #END getGOEnrichment
    my @_bad_returns;
    (ref($results) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to getGOEnrichment:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGOEnrichment');
    }
    return($results);
}




=head2 getGOLimitedEnrichment

  $results = $obj->getGOLimitedEnrichment($sname, $geneIDList, $domainList, $ecList, $minCount, $maxCount, $type)

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



=item Description

For a given list of Features from a particular genome (for example Arabidopsis thaliana) find out the significantly enriched GO 
terms in your feature-set. This function accepts seven parameters: Specie name, a list of gene-identifiers, a list of ontology domains,
    a list of evidence codes, lower & upper bound on the number of returned go-ids that a gene-id must have, and ontology 
    type (e.g. GO, PO, EO, TO etc). The list of gene identifiers cannot be empty; however the list of ontology domains and the list of 
    evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are 
    further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the 
    initial results then it is recommended to provide empty domain and evidence code lists. In any case, a mapping of only those 
    gene-id to go-ids for which the count of go-ids per gene is between minimum and maximum count limit is carried forward. Final filtered 
    list of the gene-id to go-ids mapping is used to calculate GO Enrichment using hypergeometric test.

=back

=cut

sub getGOLimitedEnrichment
{
    my $self = shift;
    my($sname, $geneIDList, $domainList, $ecList, $minCount, $maxCount, $type) = @_;

    my @_bad_arguments;
    (!ref($sname)) or push(@_bad_arguments, "Invalid type for argument \"sname\" (value was \"$sname\")");
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"domainList\" (value was \"$domainList\")");
    (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ecList\" (value was \"$ecList\")");
    (!ref($minCount)) or push(@_bad_arguments, "Invalid type for argument \"minCount\" (value was \"$minCount\")");
    (!ref($maxCount)) or push(@_bad_arguments, "Invalid type for argument \"maxCount\" (value was \"$maxCount\")");
    (!ref($type)) or push(@_bad_arguments, "Invalid type for argument \"type\" (value was \"$type\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to getGOLimitedEnrichment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGOLimitedEnrichment');
    }

    my $ctx = $Bio::KBase::OntologyService::Service::CallContext;
    my($results);
    #BEGIN getGOLimitedEnrichment
    my $frst = getGOIDLimitedList($self, $sname, $geneIDList, $domainList, $ecList, $minCount, $maxCount);
    my %ukey = ();
    foreach my $geneID (keys %{$frst}) {
      foreach my $goID (@{$frst->{$geneID}}) {
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
    my $rh_goDescList = getGoDesc($self, \@goIDList);
    my $rh_goID2Count = getGoSize($sname, \@goIDList, $domainList, $ecList);
    for(my $i = 0; $i <= $#goIDList; $i= $i+1) {
      my $goDesc = $rh_goDescList->{$goIDList[$i]};
      my $goSize = $rh_goID2Count->{$goIDList[$i]};
      my $wholeGeneSize = 22000; # temporary... based on gene ID <-- need to be changed...
      # calc p-value using any h.g. test
      my %rst = ();
      $rst{"pvalue"} = calculateStatistic(n11 => $ukey{$goIDList[$i]}, n1p => $geneSize, np1 => $goSize, npp => $wholeGeneSize);
      $rst{"goDesc"} = $goDesc;
      $rst{"goID"} = $goIDList[$i];
      push @$results, \%rst;
    }
    #END getGOLimitedEnrichment
    my @_bad_returns;
    (ref($results) eq 'ARRAY') or push(@_bad_returns, "Invalid type for return variable \"results\" (value was \"$results\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to getGOLimitedEnrichment:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGOLimitedEnrichment');
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
     Oindica: Oryza sativa indiaca
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

Captures which branch of knowledge the GO terms refers to e.g. "Biological Process", "Molecular Function", "Cellular Process" etc.


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



=head2 GeneIDMap2GoIDList

=over 4



=item Description

A list of gene-id to go-id mappings. One gene-id can have one or more go-ids associated with it.


=item Definition

=begin html

<pre>
a reference to a hash where the key is a GeneID and the value is a GoIDList
</pre>

=end html

=begin text

a reference to a hash where the key is a GeneID and the value is a GoIDList

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
