#!/usr/bin/perl
#
#  Server test for the Ontology Service.
#  
#  author:  fangfang
#  created: 11/30/2012

use strict;
use warnings;

use lib "lib";
use lib "t/server-tests";

use Test::More tests => 11;
use Data::Dumper;

my $client;
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
use Server;
note("Create new service");
my ($pid, $url) = Server::start('OntologyService');
note("Attempting to connect to:'".$url."' with PID=$pid");
$client = undef;
$client = Bio::KBase::OntologyService::Client->new($url);
ok(defined($client), "instantiating OntologyService client for new service");


#  Test - Valid call. Expect hash with data to be returned

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


#  Test - Bogus call.

my $cli = new JSON::RPC::Client;
isnt($cli, undef, "JSON::RPC::Client is defined");

my $callobj = {
    method  => 'made_up_call_which_does_not_exist!',
    params  => [ '123fakeParameter' ],
};
my $res = $cli->call($url, $callobj);
ok($cli->status_line =~ m/^500/,"test invalid rpc call");
ok(!$res,"test invalid rpc call returned nothing");


Server::stop($pid);

done_testing();

