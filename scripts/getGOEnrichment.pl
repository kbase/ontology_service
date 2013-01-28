#!/usr/bin/perl
use strict;
use Data::Dumper;
use Carp;
use Getopt::Long;
use DBI;
=head1 NAME

getGOEnrichment - find out enriched GO terms in a set of genes.

=head1 SYNOPSIS

getGOEnrichment [--host=140.221.92.223:7072] [--species_name=Athaliana] [--domain_list=biological_process,molecular_function,cellular_component] [--evidence_code_list=IEA]  [--test_type=hypergeometric] < geneIDsList

=head1 DESCRIPTION

Use this function to perform GO enrichment analysis on a set of genes.

=head2 Documentation for underlying call

For a given list of Features from a particular genome (for example "Athaliana" ) find out the significantly enriched GO terms in your feature-set. This function accepts five parameters: Species name, a list of gene-identifiers, a list of ontology domains (e.g."biological process", "molecular function", "cellular componenet"), a list of evidence codes (e.g."IEA","IDA","IEP" etc.), and test type (e.g. "hypergeometric" and "chisq"). The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of these two lists is not empty then the gene-id and the go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Final filtered list of the gene-id to go-ids mapping is used to calculate GO Enrichment using hypergeometric or chi-square test. Also, if input species is not provided then by default Arabidopsis thaliana is considered to the input species.


=head1 OPTIONS

=over 6

=item B<-h> I<[140.221.92.223:7062]> B<--host>=I<[140.221.92.223:7062]>
hostname of the server

=item B<--help>
prints help information

=item B<--version>
print version information

=item B<--species_name> comma separated list of species name e.g. [Athaliana,Zmays]

=item B<--domain_list> comman separated list of ontology domains e.g. [biological_process,molecular_function,cellular_component]

=item B<--evidence_code_list> commma separated list of ontology term evidence code e.g [IEA,IEP]

=item B<--test_type> statistical test to use for enrichment analysis [hypergeometric|chisq]

=back

=head1 EXAMPLE

 echo AT1G71695.1 | getGOEnrichment --host=140.221.92.223:7062
 echo AT1G71695.1 | getGOEnrichment --evidence_code=[IEA,IEP]
 getGOEnrichment --help
 getGOEnrichment --version

=head1 VERSION

0.1

=cut

use Bio::KBase::OntologyService::Client;

my $usage = "Usage: $0 [--host=140.221.92.223:7062] [--species_name=Athaliana] [--domain_list=biological_process] [--evidence_code_list=IEA]  [--test_type=hypergeometric] < geneIDs  [--p_value=XXX]\n";

my $host       = "140.221.92.223:7062";
my $sname      = "Athaliana" ;
#my $domainList = "biological_process";
#my $ecList     = "IEA";
my $type       = "hypergeometric";
my $help       = 0;
my $version    = 0;

my $domainList="biological_process,molecular_function,cellular_component";
my $ecList     = "IEA,IDA,IPI,IMP,IGI,IEP,ISS,ISS,ISO,ISA,ISM,IGC,IBA,IBD,IKR,IRD,RCA,TAS,NAS,IC,ND,NR";
my $pvalue_cutoff="0.05";


GetOptions("help"       => \$help,
           "version"    => \$version,
           "host=s"     => \$host, 
        #   "species_name=s"    => \$sname, 
           "domain_list=s" => \$domainList, 
           "evidence_code_list=s" => \$ecList,
           "test_type=s" => \$type,
	"p_value=s"=>\$pvalue_cutoff
) or die $usage;

if($help)
{
	print "$usage\n";
	print "\n";
	print "General options\n";
	print "\t--host=[xxx.xxx.xx.xxx:xxxx]\t\thostname of the server\n";
	print "\t--species_name=[xxx,yyy,zzz,...]\t\tspecies name list (comma separated)\n";
	print "\t--domain_list=[biological_process,molecular_function,cellular_component]\t\tdomain list (comma separated)\n";
	print "\t--evidence_code_list=[XXX,YYY,ZZZ,...]\t\tGO evidence code list (comma separated)\n";
	print "\t--test_type=[hypergeometric|chisq]\t\tthe types of test\n";
	print "\t--help\t\tprint help information\n";
	print "\t--version\t\tprint version information\n";
	print "\n";
	print "Examples: \n";
	print "echo AT1G71695.1 | $0 --host=x.x.x.x:x \n";
	print "\n\n";
	print " echo  'kb|g.3899.locus.2366,kb|g.3899.locus.1892,kb|g.3899.locus.2354,kb|g.3899.locus.2549,kb|g.3899.locus.2420,kb|g.3899.locus.2253,kb|g.3899.locus.2229'|perl scripts/getGOEnrichment.pl --host=localhost:7062";
#	print "echo AT1G03010.1,AT1G02830.1,AT1G03390.1,AT1G03400.1,AT1G71695.1,AT1G04450.1,AT1G05910.1,AT1G07270.1,AT1G09770.1,AT2G01650.1,AT2G03570.1 | $0 --evidence_code=IEA --host=x.x.x.x:7062 --p_value=xxx \n";
#	print "echo AT1G03010.1,AT1G02830.1,AT1G03390.1,AT1G03400.1,AT1G71695.1,AT1G04450.1,AT1G05910.1,AT1G07270.1,AT1G09770.1,AT2G01650.1,AT2G03570.1 |perl scripts/getGOEnrichment.pl --p_value=0.05  --host=localhost:7062";
	print "\n\n";
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
$istr =~ s/[,]/ /g;
@input = split /\s+/, $istr;
$sname="Athaliana" if $istr =~/g\.3899/;
$sname="Ptrichocarpa" if $istr =~/g\.3907/;

my $results = $oc->getGOEnrichment($sname, \@input, \@dl, \@el, $type);

#print "@input\n===\n";

foreach my $hr (@$results) {

	next if $hr->{"goID"} !~/GO/;
	
	next if  $hr->{"pvalue"} >=  $pvalue_cutoff;
	print $hr->{"goID"}."\t".$hr->{"pvalue"}."\t".${$hr->{"goDesc"}}[0]."\t".${$hr->{"goDesc"}}[1]."\t";

my $go_id=$hr->{"goID"};

	my %tem_gene_hash;
#get the gene associated with this GO term
	undef (%tem_gene_hash);

	foreach my $ggene(@input){
	my @tem_gene_array;
	$tem_gene_array[0]=$ggene;
	my $my_goid_list=$oc->getGOIDList($sname,\@tem_gene_array,\@dl,\@el);
	my %my_hash=%$my_goid_list;
	$tem_gene_hash{$ggene}=1 if grep /$go_id/, keys %{$my_hash{$ggene}};
	}


	my @tem_in;
	undef @tem_in;
	foreach my $in(keys %tem_gene_hash){
		push @tem_in,$in;
	}
	my $new_line=join",",@tem_in;
	
	print "$new_line\n";

}




