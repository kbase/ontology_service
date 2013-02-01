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
use lib "t/test-deploy";
use OntologyTestConfig qw(getHost getPort getURL);

use Test::More tests => 22;
use Data::Dumper;

my $ret;

#
#  Test - Make sure we locally have JSON RPC libs
#
use_ok("JSON::RPC::Client");
use_ok("Bio::KBase::OntologyService::Service");
use_ok("Bio::KBase::OntologyService::Client");

#
# Test - Use the auto start/stop service
#
note("Create new service");
##########
# MAKE A CONNECTION (DETERMINE THE URL TO USE BASED ON THE CONFIG MODULE)
my $host=getHost(); my $port=getPort(); my $url=getURL();
#print "-> attempting to connect to:'".$host.":".$port."'\n";
#my $client = new_ok("Bio::KBase::OntologyService::Client",[$host.":".$port] );
print "-> attempting to connect to:'".$url."'\n";
my $client = new_ok("Bio::KBase::OntologyService::Client",[$url] );

#use Server;
#my ($pid, $url) = Server::start('OntologyService');
#note("Attempting to connect to:'".$url."' with PID=$pid");
#$client = undef;
#$client = Bio::KBase::OntologyService::Client->new($url);
#ok(defined($client), "instantiating OntologyService client for new service");


# 
#  Method: get_goidlist
#

note("Test   getGOIDlist");


#  Test - Use valid data. Expect hash with data to be returned

#my $species = "Athaliana";
my @genes   = qw(kb|g.3899.locus.192 kb|g.3899.locus.164);
my @domains = qw(biological_process molecular_function cellular_component);
my @ecs     = qw(IEA TAS NAS EXP IDA IPI ISS);

$ret = $client->get_goidlist( \@genes, \@domains, \@ecs);
is(ref($ret), 'HASH', "use valid data: get_goidlist returns a hash");

my @ret_keys = keys %$ret;
isnt(scalar @ret_keys, 0, "use valid data: hash is not empty");

my ($idlist) = values %$ret;
is(ref($idlist), 'HASH', "use valid data: get_goidlist returns a hash to hash");

isnt(scalar keys %$idlist, 0, "use valid data: GO id hash is not empty");


#  Test - Use invalid data.

my @empty;
my @bogus1 = qw(BOGUS bogus);
my @bogus2 = qw(bogus);

$ret = $client->get_goidlist( \@bogus1, \@bogus2, \@bogus2);
is(ref($ret), 'HASH', "use invalid data: get_goidlist returns a hash");

#  Test - Too many or too few parameters

eval { $ret = $client->get_goidlist( \@genes, \@domains, \@ecs, \@bogus1); };
isnt($@, undef, 'call with too many parameters failed properly');

eval { $ret = $client->get_goidlist(\@domains); };
isnt($@, undef, 'call with too few parameters failed properly');



#  Test - Bogus call.

my $cli = new JSON::RPC::Client;
isnt($cli, undef, "JSON::RPC::Client is defined");

my $callobj = {
    method  => 'made_up_call_which_does_not_exist!',
    params  => [ '123fakeParameter' ],
};
my $res = $cli->call("$host:$port", $callobj);
ok($cli->status_line =~ m/^500/,"test invalid rpc call");
ok(!$res,"test invalid rpc call returned nothing");


# 
#  Method: get_go_description
#

note("Test   get_go_description");

my $go_id1 = 'GO:0006979';
my $go_id2 = 'GO:0055114';

my $desc1 = 'response to oxidative stress';
my $desc2 = 'oxidation-reduction process';

# Test - Use valid GO IDs. Expect meaningful description to be returned

$ret = $client->get_go_description([$go_id1, $go_id2]);
ok(${$ret->{$go_id1}}[0] =~ /$desc1/, "get correct description for $go_id1");
ok(${$ret->{$go_id2}}[0] =~ /$desc2/, "get correct description for $go_id2");

# Test - Use invalid GO IDs. Expect empty hash
my @bad_go_ids = ['GO:000697900', 'GO:abcdefg', 'NOT_GO_ID', ''];
$ret = $client->get_go_description(\@bad_go_ids);
is(ref($ret), 'HASH', "use invalid data: get_go_description returns a hash");
is(scalar keys %$ret, 0, "use invalid data: get_go_description returns an empty hash");


# 
#  Method: get_go_enrichment
#

note("Test   get_go_enrichment");
my $type1    = 'hypergeometric';
my $type2    = 'chisq';
my $bad_type = 'bad_type_string';

$ret = $client->get_go_enrichment(\@genes, \@domains, \@ecs, $type1);
isnt($ret->[0]->{pvalue}, undef, 'call with valid data returns pvalue');

SKIP: {
  skip( 'not supported in this version', 3 );
  $ret = $client->get_go_enrichment( \@genes, \@domains, \@ecs, $type2);
  isnt($ret->[1]->{goDesc}, undef, 'call with valid data returns goDesc');

  my $ret2 = $client->get_go_enrichment( \@genes, [], [], $type2);
  #is(@$ret2 >= @$ret, 1, 'call with valid data and no filter returns at least as much data');
  cmp_ok(scalar @$ret2, '<=', scalar @$ret, 'call with valid data and no filter returns at least as much data');

  # Not sure what the correct behavior should be when a bad type is supplied
  $ret2 = undef;
  $ret2 = $client->get_go_enrichment( \@genes, \@domains, \@ecs, $bad_type);
  isnt(Dumper($ret2), Dumper($ret), 'call with bad type returns different results');
}

#Server::stop($pid);

done_testing();

