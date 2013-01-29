use strict;
use Data::Dumper;
use Carp;
use Getopt::Long;
use DBI;


=head1 NAME

get_goidlist - find out which GO terms are associated with a gene

=head1 SYNOPSIS

get_goidlist [--host=140.221.92.223:7062] [--species_name=Athaliana] [--domain_list=biological_process] [--evidence_code_list=IEA] < geneIDs

=head1 DESCRIPTION

For a given list of Features (aka Genes) from a particular genome (for example "Athaliana" Arabidopsis thaliana ) extract corresponding list of GO identifiers along with GO description for each GO term.

=head2 Documentation for underlying call

This function call accepts four parameters: species name, a list of gene-identifiers, a list of ontology domains, and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of gene-id to go-ids along with go-description, ontology domain, and evidence code; note that in the returned table of results, each gene-id is associated with a list of one of more go-ids. Also, if no species is provided as input then by default, Arabidopsis thaliana is used as the input species.

=head1 OPTIONS

=over 6

=item B<-h> I<[140.221.92.223:7062]> B<--host>=I<[140.221.92.223:7062]>
hostname of the server

=item B<--help>
prints help information

=item B<--version>
print version information

=item B<--host> IP address and port of the host server e.g. --host=140.221.92.223:7062

=item B<--species_name> comma separated list of species name e.g. --species=[Athaliana,Zmays]

=item B<--domain_list> comma separated list of ontology domains e.g. --domain_list=[biological_process,cellular_component]

=item B<--evidence_code_list> comma separated list of ontology evidence codes e.g. --evidence_code_list=[IEA,IEP]

=back

=head1 EXAMPLE

 echo AT1G71695.1 | get_goidlist --host=140.221.92.223:7062
 echo AT1G71695.1 | get_goidlist --evidence_code=IEA
 get_goidlist --help
 get_goidlist --version

=head1 VERSION

0.1

=cut

use Bio::KBase::OntologyService::Client;

my $usage = "Usage: $0 [--host=140.221.92.223:7062] [--species_name=Athaliana] [--domain_list=biological_process] [--evidence_code_list=IEA] < geneIDs\n";

my $host       = "140.221.92.223:7062";
my $sname      = "Athaliana";
#my $domainList = ("biological_process","molecular_function","cellular_component");
#my $ecList     = ("IEA","IDA","IPI","IMP","IGI","IEP","ISS","ISS","ISO","ISA","ISM","IGC","IBA","IBD","IKR","IRD","RCA","TAS","NAS","IC","ND","NR");
my $domainList="biological_process,molecular_function,cellular_component";
my $ecList     = "IEA,IDA,IPI,IMP,IGI,IEP,ISS,ISS,ISO,ISA,ISM,IGC,IBA,IBD,IKR,IRD,RCA,TAS,NAS,IC,ND,NR";



my $help       = 0;
my $version    = 0;

GetOptions("help"       => \$help,
           "version"    => \$version,
           "host=s"     => \$host, 
           "species_name=s"    => \$sname, 
           "domain_list=s" => \$domainList, 
           "evidence_code_list=s" => \$ecList) or die $usage;

if($help)
{
        print <<MAN;
        DESCRIPTION
	    This function call accepts four parameters: species name, a list of gene-identifiers, a list of ontology domains, and a list of evidence codes. The list of gene identifiers cannot be empty; however the list of ontology domains and the list of evidence codes can be empty. If any of the last two lists is not empty then the gene-id and go-id pairs retrieved from KBase are further filtered by using the desired ontology domains and/or evidence codes supplied as input. So, if you don't want to filter the initial results then it is recommended to provide empty domain and evidence code lists. Finally, this function returns a mapping of gene-id to go-ids along with go-description, ontology domain, and evidence code; note that in the returned table of results, each gene-id is associated with a list of one of more go-ids. Also, if no species is provided as input then by default, Arabidopsis thaliana is used as the input species.

        MAN

	print "$usage\n";
	print "\n";
	print "General options\n";
	print "\t--host=[xxx.xxx.xx.xxx:xxxx]\t\thostname of the server\n";
	print "\t--species_name=[xxx,yyy,zzz,...]\t\tspecies name list (comma separated)\n";
	print "\t--domain_list=[biological_process,molecular_function,cellular_component]\t\tdomain list (comma separated)\n";
	print "\t--evidence_code_list=[XXX,YYY,ZZZ,...]\t\tGO evidence code list (comma separated)\n";
	print "\t--help\t\tprint help information\n";
	print "\t--version\t\tprint version information\n";
	print "\n";
	print "Examples: \n";
	print "echo 'kb|g.3899.locus.192,kb|g.3899.locus.2366' |get_goidlist --host=localhost:7062 --evidence_code=IEA";
#	print "echo AT1G71695.1 | $0 --host=x.x.x.x:7062 \n";
	print "\n";
#	print "echo AT1G71695.1 | $0 --evidence_code=IEA --host=localhost:7062 \n";
	print "\n";
#	print "echo AT1G03010.1,AT1G02830.1,AT1G09770.1,AT2G01650.1,AT2G03570.1 | get_goidlist  --host=localhost:7062\n";
	print "$0 --help\tprint out help\n";
	print "\n";
	print "$0 --version\tprint out version information\n";
	print "\n";
	print "Report bugs to Shinjae Yoo at sjyoo\@bnl.gov\n";
	exit(0);
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
	exit(0);
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
$sname="Ptrichocarpa" if $istr =~/g.\3907/;



my $results = $oc->get_goidlist($sname, \@input, \@dl, \@el);
foreach my $geneID (keys %{$results}) {
  foreach my $goID (keys %{$results->{$geneID}}) {
    foreach my $mlh (@{$results->{$geneID}->{$goID}}) {
      my %lh = %$mlh;
      print "$geneID\t$goID\t$lh{'domain'}\t$lh{'ec'}\t$lh{'desc'}\n";
    }
  }
}




