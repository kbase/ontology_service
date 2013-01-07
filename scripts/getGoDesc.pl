use strict;
use Data::Dumper;
use Carp;
use Getopt::Long;

=head1 NAME

getGoDesc - get GO id description

=head1 SYNOPSIS

getGoDesc [--host=140.221.92.223:7062] < goIDs

=head1 DESCRIPTION

The standard input should be space character separated go ids.
This is a pipe command. The input is taken from the standard input, and the
output is to the standard output.

=head2 Documentation for underlying call

Extract GO term description for a given list of go-identifiers. This function expects an input list of go-ids (one go-id per line) and returns a table of two columns, first column being the go-id and the second column being the go-term description.

=head1 OPTIONS

=over 6

=item B<-h> I<[140.221.92.223:7062]> B<--host>=I<[140.221.92.223:7062]>     
hostname of the server

=item B<--help>                                                             
print help information

=item B<--version>                                                          
print version information

=back

=head1 SEE ALSO

L<getGOIDList(1)>, L<getGOIDLimitedList(1)> 
=cut

use Bio::KBase::OntologyService::Client;

my $usage = "Usage: $0 [--host=140.221.92.223:7062] < goIDs\n";

my $host       = "140.221.92.223:7062";
my $help       = 0;
my $version    = 0;

GetOptions("help"       => \$help,
           "version"    => \$version,
           "host=s"     => \$host) or die $usage;

if($help)
{
	print "$usage\n";
	print "\n";
	print "General options\n";
	print "\t--host=[xxx.xxx.xx.xxx:xxxx]\t\thostname of the server\n";
	print "\t--help\t\tprint help information\n";
	print "\t--version\t\tprint version information\n";
	print "\n";
	print "Examples: \n";
	print "echo GO:0006979 | $0 --host=x.x.x.x:x \n";
	print "\n";
	print "$0 --help\tprint out help\n";
	print "\n";
	print "$0 --version\tprint out version information\n";
	print "\n";
	print "Report bugs to Shinjae Yoo at sjyoo\@bnl.gov\n";
	exit(1);
}

if($version)
{
	print "$0 version 0.1\n";
	print "Copyright (C) 2012 Shinjae Yoo\n";
	print "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.\n";
	print "This is free software: you are free to change and redistribute it.\n";
	print "There is NO WARRANTY, to the extent permitted by law.\n";
	print "\n";
	print "Written by Shinjae Yoo and Sunita Kumari\n";
	exit(1);
}

die $usage unless @ARGV == 0;

my $oc = Bio::KBase::OntologyService::Client->new("http://".$host);
my @input = <STDIN>;
my $istr = join(" ", @input);
$istr =~ s/[,|]/ /g;
@input = split /\s+/, $istr;
my $results = $oc->getGoDesc(\@input);

foreach my $goID (keys %{$results}) {
  print "$goID\t${$results->{$goID}}[0]\t${$results->{$goID}}[1]\n";
}
