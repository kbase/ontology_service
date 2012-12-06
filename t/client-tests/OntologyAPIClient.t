#!/usr/bin/perl
#
#  Client test for the Ontology Service.
#  
#  author:  fangfang
#  created: 11/30/2012
# updated 12/6/2012 landml

use strict;
use warnings;

use lib "lib";
use lib "t/client-tests";

use Test::More tests => 35;
use Data::Dumper;

my $client;
my $ret;

#
#  Test - Make sure we locally have JSON RPC libs
#
use_ok("JSON::RPC::Client");
use_ok("Bio::KBase::OntologyService::Client");


#
#  Test - Can a new object be created without parameters? 
#
$client = Bio::KBase::OntologyService::Client->new(); 
ok(defined $client, "client object is defined");               

# 
#  Test - Use the auto start/stop service
#
 use Server;
note("Create new service");
my ($pid, $url) = Server::start('OntologyService');
$client = undef;
note("Attempting to connect to:'".$url."' with PID=$pid");
$client = Bio::KBase::OntologyService::Client->new($url);
ok(defined($client), "instantiating OntologyService client for new service");

#
#  Test - Is the object in the right class?
#
isa_ok($client, 'Bio::KBase::OntologyService::Client', "is it in the right class" );   


# 
#  Test - Can the object do all of the methods?
#
my @methods = qw(getGOIDList getGOIDLimitedList getGoDesc getGOEnrichment getGOLimitedEnrichment);
can_ok($client, @methods);

# 
#  Method: getGOIDList
#

note("Test   getGOIDlist");


#  Test - Use valid data. Expect hash with data to be returned

my $species = "Athaliana";
my @genes   = qw(AT1G71695.1);
my @domains = qw(biological_process);
my @ecs     = qw(IEA);

$ret = $client->getGOIDList($species, \@genes, \@domains, \@ecs);
is(ref($ret), 'HASH', "use valid data: getGOIDList returns a hash");

my @ret_keys = keys %$ret;
isnt(scalar @ret_keys, 0, "use valid data: hash is not empty");

my ($idlist) = values %$ret;
is(ref($idlist), 'ARRAY', "use valid data: getGOIDList returns a hash to arrays");

my ($go_id1, $go_id2) = @$idlist;
isnt(scalar @$idlist, 0, "use valid data: GO id array is not empty");


#  Test - Use invalid data.

my @empty;
my @bogus1 = qw(BOGUS bogus);
my @bogus2 = qw(bogus);

$ret = $client->getGOIDList($species, \@bogus1, \@bogus2, \@bogus2);
is(ref($ret), 'HASH', "use invalid data: getGOIDList returns a hash");

#  Test - Too many or too few parameters

eval { $ret = $client->getGOIDList($species, \@genes, \@domains, \@ecs, \@bogus1); };
isnt($@, undef, 'call with too many parameters failed properly');

eval { $ret = $client->getGOIDList($species); };
isnt($@, undef, 'call with too few parameters failed properly');


# 
#  Method: getGOIDLimitedList
#

note("Test   getGOIDLimitedList");

$ret = $client->getGOIDLimitedList($species, \@genes, \@domains, \@ecs, 0, 100000);
{
    my @ret_keys = keys %$ret;
    isnt(scalar @ret_keys, 0, "use valid data: hash is not empty");

    my ($idlist) = values %$ret;
    is(ref($idlist), 'ARRAY', "use valid data: getGOIDList returns a hash to arrays");

    my ($go_id1, $go_id2) = @$idlist;
    isnt(scalar @$idlist, 0, "use valid data: GO id array is not empty");
}

$ret = $client->getGOIDLimitedList($species, \@genes, \@domains, \@ecs, 0, 0);
is(scalar keys%$ret, 0, "use valid data with limitation (min=0, max=0): hash is empty");


#  Test - Do the min and max parameters actually filter out invalid cases

my $limit_min = 0;
my $limit_max = 1;
$ret = $client->getGOIDLimitedList($species, \@genes, \@domains, \@ecs, $limit_min, $limit_max);
my $min = 1e9;
my $max = 0;
for my $list (values %$ret) {
    my $n = scalar @$list;
    $min = $n if $n < $min;
    $max = $n if $n > $max;
}
cmp_ok($min, '>=', $limit_min, "use valid data with limitation (min=$limit_min, max=$limit_max): actual min list size >= $limit_min and min=$min");
cmp_ok($max, '<=', $limit_max, "use valid data with limitation (min=$limit_min, max=$limit_max): actual max list size <= $limit_max and max=$max");
print Dumper(%$ret);

# 
#  Method: getGoDesc
#

note("Test   getGoDesc");

$go_id1 = 'GO:0006979';
$go_id2 = 'GO:0055114';

my $desc1 = 'response to oxidative stress';
my $desc2 = 'oxidation reduction';

# Test - Use valid GO IDs. Expect meaningful description to be returned

$ret = $client->getGoDesc([$go_id1, $go_id2]);
is($ret->{$go_id1}, $desc1, "get correct description for $go_id1");
is($ret->{$go_id2}, $desc2, "get correct description for $go_id2");

# Test - Use invalid GO IDs. Expect empty hash
my @bad_go_ids = ['GO:000697900', 'GO:abcdefg', 'NOT_GO_ID', ''];
$ret = $client->getGoDesc(\@bad_go_ids);
is(ref($ret), 'HASH', "use invalid data: getGoDesc returns a hash");
is(scalar keys %$ret, 0, "use invalid data: getGoDesc returns an empty hash");


# 
#  Method: getGOEnrichment
#

note("Test   getGOEnrichment");
my $type1    = 'hypergeometric';
my $type2    = 'chisq';
my $bad_type = 'bad_type_string';

$ret = $client->getGOEnrichment($species, \@genes, \@domains, \@ecs, $type1);
isnt($ret->[0]->{pvalue}, undef, 'call with valid data returns pvalue');

$ret = $client->getGOEnrichment($species, \@genes, \@domains, \@ecs, $type2);
isnt($ret->[1]->{goDesc}, undef, 'call with valid data returns goDesc');

my $ret2 = $client->getGOEnrichment($species, \@genes, [], [], $type2);
#is(@$ret2 >= @$ret, 1, 'call with valid data and no filter returns at least as much data');
cmp_ok(scalar @$ret2, '<=', scalar @$ret, 'call with valid data and no filter returns at least as much data');

# Not sure what the correct behavior should be when a bad type is supplied
$ret2 = undef;
$ret2 = $client->getGOEnrichment($species, \@genes, \@domains, \@ecs, $bad_type);
isnt(Dumper($ret2), Dumper($ret), 'call with bad type returns different results');


# 
#  Method: getGOLimitedEnrichment
#

note("Test   getGOLimitedEnrichment");

$ret = $client->getGOLimitedEnrichment('', \@genes, \@domains, \@ecs, $type1, 0, 10);
is(ref($ret), 'ARRAY', "use invalid species: getGOLimitedEnrichment returns an array");
is(scalar@$ret, 0, "use invalid species: getGOLimitedEnrichment returns an empty ARRAY");

$ret = $client->getGOLimitedEnrichment($species, [], \@domains, \@ecs, $type1, 0, 10);
is(ref($ret), 'ARRAY', "use empty gene list: getGOLimitedEnrichment returns an array");
is(scalar@$ret, 0, "use empty gene list: getGOLimitedEnrichment returns an empty ARRAY");

eval { $ret = $client->getGOLimitedEnrichment($species, \@genes, \@domains, \@ecs, $type1, 1); };
isnt($@, undef, 'call with too few parameters failed properly');

$ret = $client->getGOLimitedEnrichment($species, \@genes, \@domains, \@ecs, $type1, 1, 3);
isnt($ret->[0]->{pvalue}, undef, 'call with reasonable lower/upper bounds returns data');

$ret = $client->getGOLimitedEnrichment($species, \@genes, \@domains, \@ecs, $type1, 1000000, 10);
isnt(scalar@$ret, 0, 'call with invalid lower/upper bounds returns no data');

$ret = $client->getGOLimitedEnrichment($species, \@genes, \@domains, \@ecs, $type1, 1000000, 1000001);
isnt(scalar@$ret, 0, 'call with unreasonable lower/upper bounds returns no data');

Server::stop($pid);

done_testing();

