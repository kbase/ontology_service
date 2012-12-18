#!/usr/bin/perl
#
#  Server test for the Ontology Service.
#  
#  author:  fangfang
#  created: 11/30/2012
#  update:  12/06/2012 landml
# updated 12/7/2012 sjyoo
use strict;
use warnings;

use lib "lib";
use lib "t/script-tests";
use OntologyTestConfig qw(getHost getPort getURL);
my $host=getHost(); my $port=getPort();  my $url = getURL();
print "-> attempting to connect to:'".$url."'\n";

use Test::More tests => 36;
use Data::Dumper;

my $ret;
my $cmd;
my $client;
my $method;
my $DEBUG = 1;

my @empty;
my @bogus1 = qw(BOGUS bogus);
my @bogus2 = qw(bogus);

#
#  Test - Make sure we locally have JSON RPC libs
#
use_ok("JSON::RPC::Client");
use_ok("Bio::KBase::OntologyService::Service");
use_ok("Bio::KBase::OntologyService::Client");

my $species = "Athaliana";
my @genes   = qw(AT1G71695.1 At1G36180.1 AT1G01920.2 AT1G01930.1 AT1G01940.1 AT1G01950.1 AT1G01960.1 AT2G01720.1 AT2G01730.1 AT2G01740.1 AT2G01750.1 );
my @domains = qw(biological_process);
my $ecs     = "IEA,XYZ";

#&getGOIDList;
#&getGOIDLimitedList;
#&getGoDesc;
#&getGOEnrichment;
&getGOLimitedEnrichment;

#
# Test - Use the auto start/stop service
#

#------------------------------------------------------------------------------ 
# 
#  Method: getGOIDList
#
#------------------------------------------------------------------------------ 
sub getGOIDList
{

$method = "getGOIDList";
note("Test   $method");

#  Test - Use valid data. Return is a 2-column list

$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '',     "use valid data: $method returns without error");
isnt($ret, '', "use valid data: $method returns nonempty string");

my @ret = split(/\n/,$ret);
my $num_col = split(/\t/,$ret[0]);
is($num_col, 2, "use valid data: Returned 2 columns");

#  Test - Use invalid data.

$cmd = "echo @bogus1 | $method --host=$url --species_name=Dummy$species --domain_list=@bogus2 --evidence_code_list=@bogus2 --no_name_parameter='BOGUS'";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '',   "use bad data: $method does not return error");
is($ret, '', "use bad data: $method returns empty string");

$cmd = "$method --help  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method --help returns without error");
isnt($ret,"","Return is not empty");

$cmd = "$method --version  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method  --version returns without error");
isnt($ret,"","Return is not empty");

#  Test - Change number of parameters

#$cmd = "echo @genes | $method --species_name=$species --domain_list=@domains --evidence_code_list=$ecs ";
#note "$cmd" if ($DEBUG);
#eval { $ret = `$cmd`; };
#is($@, '', "missing host: $method returns without error");
#isnt($ret, '', "missing host: $method returns nonempty string");

$cmd = "echo @genes | $method --host=$url --domain_list=@domains --evidence_code_list=$ecs ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "missing species: $method returns without error");
isnt($ret, '', "missing species: $method returns nonempty string");

$cmd = "echo @genes | $method --host=$url --species_name=$species --evidence_code_list=$ecs ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "missing domains: $method returns without error");
isnt($ret, '', "missing domains: $method returns nonempty string");

$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "missing evidence_code: $method returns without error");
isnt($ret, '', "missing evidence_code: $method returns nonempty string");

#$cmd = " $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs ";
#note "$cmd" if ($DEBUG);
#eval { $ret = `$cmd`; };
#is($@, '', "missing genes: $method returns without error");
#isnt($ret, '', "missing genes: $method returns nonempty string");

my $cli = new JSON::RPC::Client;
isnt($cli, undef, "JSON::RPC::Client is defined");
}


#------------------------------------------------------------------------------ 
#
#  Method: getGOIDLimitedList
#
#------------------------------------------------------------------------------
sub getGOIDLimitedList
{

$method = "getGOIDLimitedList";
note("Test   $method");

my $from_count = 0;
my $to_count   = 0;

$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '',     "use valid data: $method returns without error");
isnt($ret, '', "use valid data: $method returns nonempty string");

my @ret = split(/\n/,$ret);
my $num_col = split(/\t/,$ret[0]);

#
#	Test the limit commands
#

$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs --from_count=$from_count --to_count=$to_count ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method limitation (min=0, max=0) returns without error");
is($ret, '', "use $method limitation (min=0, max=0) returns empty string");

my @ret_0_0 = split(/\n/,$ret);

$from_count = 0;
$to_count   = 1;
$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs --from_count=$from_count --to_count=$to_count ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method limitation (min=0, max=1) returns without error");
isnt($ret, '', "use $method limitation (min=0, max=1) returns nonempty string");
my @ret_0_1 = split(/\n/,$ret);

cmp_ok( scalar $#ret_0_1, '>=', scalar $#ret_0_0);

$from_count = 1;
$to_count   = 1;
$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs --from_count=$from_count --to_count=$to_count ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method limitation (min=1, max=1) returns without error");
isnt($ret, '', "use $method limitation (min=1, max=1) returns nonempty string");
my @ret_1_1 = split(/\n/,$ret);

cmp_ok( scalar $#ret_0_1, '>=', scalar $#ret_1_1);

$cmd = "echo @genes | $method --host=$url --species_name=$species --test_type=hypergeometric ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method test_type=hypergeometric returns without error");
isnt($ret, '', "use $method test_type=hypergeometric returns non-empty string");

$cmd = "echo @genes | $method --host=$url --species_name=$species --test_type=chisq ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method test_type=chisq  returns without error");
isnt($ret, '', "use $method test_type=chisq returns non-empty string");

$cmd = "$method --help  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method --help returns without error");
isnt($ret,"","Return is not empty");

$cmd = "$method --version  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method --version returns without error");
isnt($ret,"","Return is not empty");

#	Test non-numeric command
#
$cmd = "echo @genes | $method --host=$url --species_name=$species --from_count='bad_count' --to_count='bad_count' ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
isnt($@,   '', "use $method non-numeric returns error");
isnt($ret, '', "use $method non-numerid returns empty string");

$cmd = "echo @genes | $method --host=$url --species_name=$species --test_type=cq ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method test_type=cq  returns without error");
is($ret, '', "use $method test_type=cq returns empty string");

}

#------------------------------------------------------------------------------ 
# 
#  Method: getGoDesc
#
#------------------------------------------------------------------------------ 
sub getGoDesc
{

$method = "getGoDesc";
note("Test   $method");

my %go_ids = ('GO:0006979' => 'response to oxidative stress', 'GO:0055114'=> 'oxidation reduction');
my @go_ids = keys(%go_ids);

# Test - Use valid GO IDs. Expect meaningful description to be returned

$cmd = "echo @go_ids | $method --host=$url  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method  returns without error");

my @ret = split(/\n/,$ret);
foreach my $key (@ret)
{
	my @test = split(/\t/,$key);
	ok(exists $go_ids{$test[0]}, "Was $test[0] in my input list?");
	is($go_ids{$test[0]}, $test[1], "Was the description for $test[0] $go_ids{$test[0]}");
}

$cmd = "$method --help  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method --help returns without error");
isnt($ret,"","Return is not empty");

$cmd = "$method --version  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method  --version returns without error");
isnt($ret,"","Return is not empty");

# Test - Use invalid GO IDs. Expect empty hash
my @bad_go_ids = ('GO:000697900', 'GO:abcdefg', 'NOT_GO_ID', '');
$cmd = "echo @bad_go_ids | $method --host=$url  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@,  '', "use $method  returns without error");
is($ret,'', "use $method  returns empty");

}

#------------------------------------------------------------------------------ 
# 
#  Method: getGOEnrichment
#
#------------------------------------------------------------------------------ 
sub getGOEnrichment
{

$method = "getGOEnrichment";
note("Test   $method");

my $type1    = 'hypergeometric';
my $type2    = 'chisq';
my $bad_type = 'bad_type_string';

my $from_count = 0;
my $to_count   = 0;

$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '',     "use valid data: $method returns without error");
isnt($ret, '', "use valid data: $method returns nonempty string");

my @ret = split(/\n/,$ret);
my $num_col = split(/\t/,$ret[0]);

$cmd = "echo @genes | $method --host=$url --species_name=$species --test_type=hypergeometric ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method test_type=hypergeometric returns without error");
isnt($ret, '', "use $method test_type=hypergeometric returns non-empty string");

$cmd = "echo @genes | $method --host=$url --species_name=$species --test_type=chisq ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method test_type=chisq  returns without error");
isnt($ret, '', "use $method test_type=chisq returns non-empty string");

$cmd = "$method --help  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method --help returns without error");
isnt($ret,"","Return is not empty");

$cmd = "$method --version  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method --version returns without error");
isnt($ret,"","Return is not empty");

#	Test non-numeric command
#
$cmd = "echo @genes | $method --host=$url --species_name=$species --from_count='bad_count' --to_count='bad_count' ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
isnt($@,   '', "use $method non-numeric returns error");
isnt($ret, '', "use $method non-numerid returns empty string");

$cmd = "echo @genes | $method --host=$url --species_name=$species --test_type=cq ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method test_type=cq  returns without error");
is($ret, '', "use $method test_type=cq returns empty string");


}

#------------------------------------------------------------------------------ 
# 
#  Method: getGOLimitedEnrichment
#
#------------------------------------------------------------------------------ 
sub getGOLimitedEnrichment
{

$method = "getGOLimitedEnrichment";
note("Test   $method");

my $from_count = 0;
my $to_count   = 0;

$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '',     "use valid data: $method returns without error");
isnt($ret, '', "use valid data: $method returns nonempty string");

my @ret = split(/\n/,$ret);
my $num_col = split(/\t/,$ret[0]);

#
#	Test the limit commands
#

$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs --from_count=$from_count --to_count=$to_count ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method limitation (min=0, max=0) returns without error");
is($ret, '', "use $method limitation (min=0, max=0) returns empty string");

my @ret_0_0 = split(/\n/,$ret);

$from_count = 0;
$to_count   = 1;
$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs --from_count=$from_count --to_count=$to_count ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method limitation (min=0, max=1) returns without error");
isnt($ret, '', "use $method limitation (min=0, max=1) returns nonempty string");
my @ret_0_1 = split(/\n/,$ret);

cmp_ok( scalar $#ret_0_1, '>=', scalar $#ret_0_0);

$from_count = 1;
$to_count   = 1;
$cmd = "echo @genes | $method --host=$url --species_name=$species --domain_list=@domains --evidence_code_list=$ecs --from_count=$from_count --to_count=$to_count ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method limitation (min=1, max=1) returns without error");
isnt($ret, '', "use $method limitation (min=1, max=1) returns nonempty string");
my @ret_1_1 = split(/\n/,$ret);

cmp_ok( scalar $#ret_0_1, '>=', scalar $#ret_1_1);

$cmd = "echo @genes | $method --host=$url --species_name=$species --test_type=hypergeometric ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method test_type=hypergeometric returns without error");
isnt($ret, '', "use $method test_type=hypergeometric returns non-empty string");

$cmd = "echo @genes | $method --host=$url --species_name=$species --test_type=chisq ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method test_type=chisq  returns without error");
isnt($ret, '', "use $method test_type=chisq returns non-empty string");

$cmd = "$method --help  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method --help returns without error");
isnt($ret,"","Return is not empty");

$cmd = "$method --version  ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method --version returns without error");
isnt($ret,"","Return is not empty");

#	Test non-numeric command
#
$cmd = "echo @genes | $method --host=$url --species_name=$species --from_count='bad_count' --to_count='bad_count' ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
isnt($@,   '', "use $method non-numeric returns error");
isnt($ret, '', "use $method non-numerid returns empty string");

$cmd = "echo @genes | $method --host=$url --species_name=$species --test_type=cq ";
note "$cmd" if ($DEBUG);
eval { $ret = `$cmd`; };
is($@, '', "use $method test_type=cq  returns without error");
is($ret, '', "use $method test_type=cq returns empty string");


}

done_testing();

