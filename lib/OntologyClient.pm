package OntologyClient;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

OntologyClient

=head1 DESCRIPTION



=cut

sub new
{
    my($class, $url, @args) = @_;

    my $self = {
	client => OntologyClient::RpcClient->new,
	url => $url,
    };


    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




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
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 3)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function getGOIDList (received $n, expecting 3)");
    }
    {
	my($geneIDList, $domainList, $ecList) = @args;

	my @_bad_arguments;
        (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"geneIDList\" (value was \"$geneIDList\")");
        (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"domainList\" (value was \"$domainList\")");
        (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"ecList\" (value was \"$ecList\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to getGOIDList:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'getGOIDList');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Ontology.getGOIDList",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'getGOIDList',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method getGOIDList",
					    status_line => $self->{client}->status_line,
					    method_name => 'getGOIDList',
				       );
    }
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
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 5)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function getGOIDLimitedList (received $n, expecting 5)");
    }
    {
	my($geneIDList, $domainList, $ecList, $minCount, $maxCount) = @args;

	my @_bad_arguments;
        (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"geneIDList\" (value was \"$geneIDList\")");
        (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"domainList\" (value was \"$domainList\")");
        (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"ecList\" (value was \"$ecList\")");
        (!ref($minCount)) or push(@_bad_arguments, "Invalid type for argument 4 \"minCount\" (value was \"$minCount\")");
        (!ref($maxCount)) or push(@_bad_arguments, "Invalid type for argument 5 \"maxCount\" (value was \"$maxCount\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to getGOIDLimitedList:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'getGOIDLimitedList');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Ontology.getGOIDLimitedList",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'getGOIDLimitedList',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method getGOIDLimitedList",
					    status_line => $self->{client}->status_line,
					    method_name => 'getGOIDLimitedList',
				       );
    }
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
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function getGoDesc (received $n, expecting 1)");
    }
    {
	my($goIDList) = @args;

	my @_bad_arguments;
        (ref($goIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"goIDList\" (value was \"$goIDList\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to getGoDesc:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'getGoDesc');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Ontology.getGoDesc",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'getGoDesc',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method getGoDesc",
					    status_line => $self->{client}->status_line,
					    method_name => 'getGoDesc',
				       );
    }
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
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 4)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function getGOEnrichment (received $n, expecting 4)");
    }
    {
	my($geneIDList, $domainList, $ecList, $type) = @args;

	my @_bad_arguments;
        (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"geneIDList\" (value was \"$geneIDList\")");
        (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"domainList\" (value was \"$domainList\")");
        (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"ecList\" (value was \"$ecList\")");
        (!ref($type)) or push(@_bad_arguments, "Invalid type for argument 4 \"type\" (value was \"$type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to getGOEnrichment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'getGOEnrichment');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Ontology.getGOEnrichment",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'getGOEnrichment',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method getGOEnrichment",
					    status_line => $self->{client}->status_line,
					    method_name => 'getGOEnrichment',
				       );
    }
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
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 6)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function getGOLimitedEnrichment (received $n, expecting 6)");
    }
    {
	my($geneIDList, $domainList, $ecList, $minCount, $maxCount, $type) = @args;

	my @_bad_arguments;
        (ref($geneIDList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"geneIDList\" (value was \"$geneIDList\")");
        (ref($domainList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 2 \"domainList\" (value was \"$domainList\")");
        (ref($ecList) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 3 \"ecList\" (value was \"$ecList\")");
        (!ref($minCount)) or push(@_bad_arguments, "Invalid type for argument 4 \"minCount\" (value was \"$minCount\")");
        (!ref($maxCount)) or push(@_bad_arguments, "Invalid type for argument 5 \"maxCount\" (value was \"$maxCount\")");
        (!ref($type)) or push(@_bad_arguments, "Invalid type for argument 6 \"type\" (value was \"$type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to getGOLimitedEnrichment:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'getGOLimitedEnrichment');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Ontology.getGOLimitedEnrichment",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'getGOLimitedEnrichment',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method getGOLimitedEnrichment",
					    status_line => $self->{client}->status_line,
					    method_name => 'getGOLimitedEnrichment',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "Ontology.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'getGOLimitedEnrichment',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method getGOLimitedEnrichment",
            status_line => $self->{client}->status_line,
            method_name => 'getGOLimitedEnrichment',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for OntologyClient\n";
    }
    if ($sMajor == 0) {
        warn "OntologyClient version is $svr_version. API subject to change.\n";
    }
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

package OntologyClient::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        $obj->{id} = $self->id if (defined $self->id);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
