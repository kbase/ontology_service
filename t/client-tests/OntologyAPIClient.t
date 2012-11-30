#!/usr/bin/perl
#
#  Client test for the Ontology Service.
#  
#  author:  fangfang
#  created: 11/30/2012

use strict;
use warnings;

use lib "lib";
use lib "t/client-tests";

# use Test::More tests => 1;
use Test::More;
use Data::Dumper;
use String::Random;

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

#  Test - Use the deployed service for testing
use ServerConfig;
my $host = ServerConfig::getHost();
my $port = ServerConfig::getPort();
my $url = "$host:$port";
note("Use deployed service");
note("Attempting to connect to:'$url'");
$client = undef;
$client = Bio::KBase::OntologyService::Client->new($url);
ok(defined($client), "instantiating OntologyService client for deployed service");

# 
#  Test - Use the auto start/stop service
#
# use Server;
# note("Create new service");
# my ($pid, $url) = Server::start('OntologyService');
# note("Attempting to connect to:'".$url."' with PID=$pid");
# $client = undef;
# $client = Bio::KBase::OntologyService::Client->new($url);
# ok(defined($client), "instantiating OntologyService client for new service");

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
is($min >= $limit_min, 1, "use valid data with limitation (min=$limit_min, max=$limit_max): actual min list size >= $limit_min");
is($max <= $limit_max, 1, "use valid data with limitation (min=$limit_min, max=$limit_max): actual max list size <= $limit_max");


# 
#  Method: getGoDesc
#

note("Test   getGoDesc");


# 
#  Method: getGOEnrichment
#

note("Test   getGOEnrichment");


# 
#  Method: getGOLimitedEnrichment
#

note("Test   getGOLimitedEnrichment");


# Server::stop($pid);

done_testing();

