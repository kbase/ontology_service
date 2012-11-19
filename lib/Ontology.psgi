use OntologyImpl;

use OntologyServer;



my @dispatch;

{
    my $obj = OntologyImpl->new;
    push(@dispatch, 'Ontology' => $obj);
}


my $server = OntologyServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler;
