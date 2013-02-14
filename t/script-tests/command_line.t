#!/usr/bin/perl

#This is a command line testing script, wrote by Fei He 1/19/2013


use strict;
use warnings;

use Test::More tests => 13;
use Test::Cmd;
use String::Random qw(random_regex random_string);
use JSON;


my $host = "localhost:7062";
my $bin  = "../../scripts";
my $goid="GO:0006979";
#my $genelist="AT1G03010.1";
#my $gene_list="AT1G03010.1,AT1G02830.1,AT1G03390.1,AT1G03400.1,AT1G71695.1,AT1G04450.1";

my $genelist='kb|g.3899.locus.2366';
my $gene_list='kb|g.3899.locus.2366,kb|g.3899.locus.1892,kb|g.3899.locus.2354,kb|g.3899.locus.2549,kb|g.3899.locus.2420,kb|g.3899.locus.2253,kb|g.3899.locus.2229';


note("Create Test::Cmd objects for all of the scripts");

my $getgodes = Test::Cmd->new(prog => "get_go_description");
ok($getgodes, "creating Test::Cmd object for get_go_description.pl");

my $getgoenrich = Test::Cmd->new(prog => "$bin/get_go_enrichment.pl", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($getgoenrich, "creating Test::Cmd object for get_go_enrichment.pl ");

my $getgoid = Test::Cmd->new(prog => "$bin/get_goidlist.pl", workdir => '', interpreter => '/kb/runtime/bin/perl');
ok($getgoid, "creating Test::Cmd object for get_goidlist.pl");




$getgodes->run(args => "--host=$host", stdin => "$goid");
ok($? ==0,"Running getGoDes");
#my @tem=split/\t/,$getgodes->stdout;
#ok(@tem>1,"Successfully got the description");
ok($getgodes->stdout =~ /response to oxidative stress/, "Successfully got the description");

$getgoid->run(args => "--host=$host", stdin => "$genelist");
ok($? ==0,"Running getGOList");
my @tem=$getgoid->stdout;
my $line=join"\t",@tem;
ok($line=~/GO:0009535/ && $line=~/GO:0006123/ && $line=~/GO:0004129/, "Successfully got the GO id list");

$getgoid->run(args => "--host=$host --evidence_code=IEA", stdin => "$genelist");
ok($? ==0,"Running getGOList with evidence code");
@tem=$getgoid->stdout;
$line=join"\t",@tem;
ok($line!~/GO:0009535/, "Evidence code appplied");

$getgoenrich->run(args => "--host=$host", stdin => "$gene_list");
ok($? ==0,"Running get_go_enrichment");
@tem=$getgoenrich->stdout;
$line=join"\t",@tem;
ok($line=~/mitochondrial electron transport/, "Successfully got the GO enrichment");


$getgoenrich->run(args => "--host=$host --p_value=0.005", stdin => "$gene_list");
ok($? ==0,"Running get_go_enrichment");
@tem=$getgoenrich->stdout;
$line=join"\t",@tem;
ok($line=~/mitochondrial electron transport/ && $line !~/electron transport chain/ , "P-value applied");

 















