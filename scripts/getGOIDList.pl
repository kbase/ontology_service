use strict;
use Data::Dumper;
use Carp;

#
# This is a SAS Component
#

=head1 getGOIDList

Example:

    getGOIDList [arguments] < input > output

The standard input should be a tab-separated table (i.e., each line
is a tab-separated set of fields).  Normally, the last field in each
line would contain the identifer. If another column contains the identifier
use

    -c N

where N is the column (from 1) that contains the identifier.

This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Documentation for underlying call

This script is a wrapper for the CDMI-API call getGOIDList. It is documented as follows:

For a given list of Features (aka Genes) from a particular genome (for example Arabidopsis thaliana) extract corresponding 
list of GO identifiers. This function call accepts four parameters: specie name, a list of gene-identifiers, a list of ontology domains,
    and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list
    of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from 
    KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't  
    want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function
    returns a mapping of gene-id to go-ids; note that in the returned table of results, each gene-id is associated with a list of
    one of more go-ids. Also, a note on the input list: only one item per line is allowed.

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

=back

=head2 Command-Line Options

=over 4

=item -c Column

This is used only if the column containing the identifier is not the last column.

=item -i InputFile    [ use InputFile, rather than stdin ]

=back

=head2 Output Format

The standard output is a tab-delimited file. It consists of the input
file with extra columns added.

Input lines that cannot be extended are written to stderr.

=cut

use SeedUtils;

my $usage = "usage: getGOIDList [-c column] < input > output";

use Bio::KBase::CDMI::CDMIClient;
use Bio::KBase::Utilities::ScriptThing;

my $column;

my $input_file;

my $kbO = Bio::KBase::CDMI::CDMIClient->new_for_script('c=i' => \$column,
				      'i=s' => \$input_file);
if (! $kbO) { print STDERR $usage; exit }

my $ih;
if ($input_file)
{
    open $ih, "<", $input_file or die "Cannot open input file $input_file: $!";
}
else
{
    $ih = \*STDIN;
}

while (my @tuples = Bio::KBase::Utilities::ScriptThing::GetBatch($ih, undef, $column)) {
    my @h = map { $_->[0] } @tuples;
    my $h = $kbO->getGOIDList(\@h);
    for my $tuple (@tuples) {
        #
        # Process output here and print.
        #
        my ($id, $line) = @$tuple;
        my $v = $h->{$id};

        if (! defined($v))
        {
            print STDERR $line,"\n";
        }
        elsif (ref($v) eq 'ARRAY')
        {
            foreach $_ (@$v)
            {
                print "$line\t$_\n";
            }
        }
        else
        {
            print "$line\t$v\n";
        }
    }
}
