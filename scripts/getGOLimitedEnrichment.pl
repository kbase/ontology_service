use strict;
use Data::Dumper;
use Carp;
use Getopt::Long;

=head1 

=head1 NAME

getGOLimitedEnrichment - find out enriched GO terms in a set of genes

=head1 SYNOPSIS

getGOLimitedEnrichment [--host=140.221.92.223:7072] [--species_name=Athaliana] [--domain_list=biological_process] [--evidence_code_list=IEA,IEP]  [--test_type=hypergeometric|chisq] < geneIDsList

=head1 DESCRIPTION

For a given list of Features from a particular genome (for example Arabidopsis thaliana) find out the significantly enriched GO terms in your feature-set. Use this function to perform GO enrichment analysis on a set of genes using the filtered list of GO terms based on the input criteria.

=head2 Documentation for underlying call

This function accepts seven parameters: Species name, a list of gene-identifiers, a list of ontology domains, a list of evidence codes, lower & upper bound on the number of returned go-ids that a gene-id must have, and test type (hypergeometric or chi-square). The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. In any case, a mapping of only those gene-id to go-ids for which the count of go-ids per gene is between minimum and maximum count limit is carried forward. Final filtered list of the gene-id to go-ids mapping is used to calculate GO Enrichment using hypergeometric or chi-square test.

=head1 OPTIONS

=over 6

=item B<-h> I<[140.221.92.223:7062]> B<--host>=I<[140.221.92.223:7062]>
hostname of the server

=item B<--help>
prints help information

=item B<--version>
print version information

=item B<--species_name> comma separated list of species name e.g. [Athaliana,Zmays]

=item B<--domain_list> comman separated list of ontology domains e.g. [biological_process,molecular_function]

=item B<--evidence_code_list> commma separated list of ontology term evidence code e.g [IEA,IEP]

=item B<--test_type> statistical test to use for enrichment analysis [hypergeometric|chisq]

=item B<--from_count> Integer >=0 for a feature to have minimum number of GO terms

=item B<--to_count> Integer >= from_count for a feature to have maximum number of GO terms

=back

=head1 EXAMPLE

 echo AT1G71695.1 | getGOEnrichment --host=140.221.92.223:7062
 echo AT1G71695.1 | getGOEnrichment --evidence_code=[IEA,IEP]
 echo AT1G71695.1 | getGOEnrichment --species=[Athaliana] --domain_list=[molecular_function,biological_process] --evidence_code=[IEA,IEP]
 getGOEnrichment --help
 getGOEnrichment --version

=head1 VERSION

0.1

=cut

use Bio::KBase::OntologyService::Client;

my $usage = "Usage: $0 [--host=140.221.92.223:7062] [--species_name=Athaliana] [--domain_list=biological_process] [--evidence_code_list=IEA]  [--test_type=hypergeometric] [--from_count=0] [--to_count=100000000] < geneIDs\n";

my $host       = "140.221.92.223:7062";
my $sname      = "Athaliana";
my $domainList = "biological_process";
my $ecList     = "IEA";
my $type       = "hypergeometric";
my $from       = 0;
my $to         = 100000000;
my $help       = 0;
my $version    = 0;

GetOptions("help"       => \$help,
           "version"    => \$version,
           "host=s"     => \$host, 
           "species_name=s"    => \$sname, 
           "domain_list=s" => \$domainList, 
           "evidence_code_list=s" => \$ecList,
           "from_count=s" => \$from,
           "to_count=s" => \$to,
           "test_type=s" => \$type) or die $usage;

if($help)
{
	print "$usage\n";
	print "\n";
	print "General options\n";
	print "\t--host=[xxx.xxx.xx.xxx:xxxx]\t\thostname of the server\n";
	print "\t--species_name=[xxx,yyy,zzz,...]\t\tspecies name list (comma separated)\n";
	print "\t--domain_list=[biological_process,molecular_function,cellular_component]\t\tdomain list (comma separated)\n";
	print "\t--evidence_code_list=[XXX,YYY,ZZZ,...]\t\tGO evidence code list (comma separated)\n";
	print "\t--from_count=[0]\t\tthe minimun frequency of GO term to be considered\n";
	print "\t--to_count=[100000000]\t\tthe maximum frequency of GO term to be considered\n";
	print "\t--test_type=[hypergeometric|chisq]\t\tthe types of test\n";
	print "\t--help\t\tprint help information\n";
	print "\t--version\t\tprint version information\n";
	print "\n";
	print "Examples: \n";
	print "echo AT1G71695.1 | $0 --host=x.x.x.x:x \n";
	print "\n";
	print "echo AT1G71695.1 | $0 --evidence_code=IEA \n";
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
my @dl = split/,/, $domainList;
my @el = split/,/, $ecList;
my @input = <STDIN>;
my $istr = join(" ", @input);
$istr =~ s/[,|]/ /g;
@input = split /\s+/, $istr;
my $results = $oc->getGOLimitedEnrichment($sname, \@input, \@dl, \@el, $from, $to, $type);
foreach my $hr (@$results) {
  print $hr->{"goID"}."\t".$hr->{"pvalue"}."\t".$hr->{"goDesc"}."\n";
}
