package OntologyImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org 
our $VERSION = "0.1.0";

=head1 NAME

Ontology

=head1 DESCRIPTION



=cut

#BEGIN_HEADER
use DBI;
use POSIX;
use OntologySupport;
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

  $results = $obj->getGOIDList($geneIDList, $domainList, $ecList)

=over 4

=item Parameter and return types

=begin html

<pre>
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$results is a GeneIDMap2GoIDList
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

$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$results is a GeneIDMap2GoIDList
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

get go id list

=back

=cut

sub getGOIDList
{
    my $self = shift;
    my($geneIDList, $domainList, $ecList) = @_;

    my @_bad_arguments;
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"domainList\" (value was \"$domainList\")");
    (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ecList\" (value was \"$ecList\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to getGOIDList:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGOIDList');
    }

    my $ctx = $OntologyServer::CallContext;
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
    my $pstmt = $dbh->prepare("select OntologyID, OntologyDescription, OntologyDomain, OntologyEvidenceCode from ontologies where TranscriptID = ? and OntologyType = 'GO'");
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

  $results = $obj->getGOIDLimitedList($geneIDList, $domainList, $ecList, $minCount, $maxCount)

=over 4

=item Parameter and return types

=begin html

<pre>
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$minCount is an int
$maxCount is an int
$results is a GeneIDMap2GoIDList
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

$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$minCount is an int
$maxCount is an int
$results is a GeneIDMap2GoIDList
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

TODO: add documentation....get go id list

=back

=cut

sub getGOIDLimitedList
{
    my $self = shift;
    my($geneIDList, $domainList, $ecList, $minCount, $maxCount) = @_;

    my @_bad_arguments;
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

    my $ctx = $OntologyServer::CallContext;
    my($results);
    #BEGIN getGOIDLimitedList
    my $frst = getGOIDList($self, $geneIDList, $domainList, $ecList);

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

get go id list

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

    my $ctx = $OntologyServer::CallContext;
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

  $results = $obj->getGOEnrichment($geneIDList, $domainList, $ecList, $type)

=over 4

=item Parameter and return types

=begin html

<pre>
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$type is a TestType
$results is an EnrichmentList
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

$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$type is a TestType
$results is an EnrichmentList
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

get go id list

=back

=cut

sub getGOEnrichment
{
    my $self = shift;
    my($geneIDList, $domainList, $ecList, $type) = @_;

    my @_bad_arguments;
    (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"geneIDList\" (value was \"$geneIDList\")");
    (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"domainList\" (value was \"$domainList\")");
    (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument \"ecList\" (value was \"$ecList\")");
    (!ref($type)) or push(@_bad_arguments, "Invalid type for argument \"type\" (value was \"$type\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to getGOEnrichment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'getGOEnrichment');
    }

    my $ctx = $OntologyServer::CallContext;
    my($results);
    #BEGIN getGOEnrichment
    my $frst = getGOIDList($self, $geneIDList, $domainList, $ecList);
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

    my $geneSize = $#$geneIDList;
    my @goIDList = keys %ukey;
    my $ra_goDescList = getGoDesc($self, \@goIDList);
    my $rh_goID2Count = getGoSize($geneIDList, $domainList, $ecList);
    for(my $i = 0; $i <= $#goIDList; $i= $i+1) {
      my $goDesc = ${$ra_goDescList}[$i];
      my $goSize = $rh_goID2Count->{$goIDList[$i]};
      my $wholeGeneSize = 22000; # temporary... based on gene ID <-- need to be changed...
      # calc p-value using any h.g. test
      my %rst = ();
      $rst{"pvalue"} = Text::NSP::Measures::2D::Fisher::twotailed::calculateStatistic($ukey{$goIDList[$i]}, $goSize, $geneSize, $wholeGeneSize);
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

  $results = $obj->getGOLimitedEnrichment($geneIDList, $domainList, $ecList, $minCount, $maxCount, $type)

=over 4

=item Parameter and return types

=begin html

<pre>
$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$minCount is an int
$maxCount is an int
$type is a TestType
$results is an EnrichmentList
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

$geneIDList is a GeneIDList
$domainList is a DomainList
$ecList is an EvidenceCodeList
$minCount is an int
$maxCount is an int
$type is a TestType
$results is an EnrichmentList
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

get go id list

=back

=cut

sub getGOLimitedEnrichment
{
    my $self = shift;
    my($geneIDList, $domainList, $ecList, $minCount, $maxCount, $type) = @_;

    my @_bad_arguments;
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

    my $ctx = $OntologyServer::CallContext;
    my($results);
    #BEGIN getGOLimitedEnrichment
    my $frst = getGOIDLimitedList($self, $geneIDList, $domainList, $ecList, $minCount, $maxCount);
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

    my $geneSize = $#$geneIDList;
    my @goIDList = keys %ukey;
    my $ra_goDescList = getGoDesc($self, \@goIDList);
    my $rh_goID2Count = getGoSize($geneIDList, $domainList, $ecList);
    for(my $i = 0; $i <= $#goIDList; $i= $i+1) {
      my $goDesc = ${$ra_goDescList}[$i];
      my $goSize = $rh_goID2Count->{$goIDList[$i]};
      my $wholeGeneSize = 22000; # temporary... based on gene ID <-- need to be changed...
      # calc p-value using any h.g. test
      my %rst = ();
      $rst{"pvalue"} = Text::NSP::Measures::2D::Fisher::twotailed::calculateStatistic($ukey{$goIDList[$i]}, $goSize, $geneSize, $wholeGeneSize);
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



=head2 GoID

=over 4



=item Description

GoID


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

GoDesc :


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
