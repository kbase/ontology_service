package OntologySupport;
use strict;
use DBI;

sub getGoSize( 
    (my $goIDList, my $domainList, my $ecList) = @_;

    my $dbh = DBI->connect("DBI:mysql:networks_pdev;host=db1.chicago.kbase.us",'networks_pdev', '',  { RaiseError => 1 } );
  
    if(defined $dbh->err && $dbh->err != 0) { # if there is any error
      return []; # return empty list
    }

    my %domainMap = map {$_ => 1} @{$domainList};
    my %ecMap = map {$_ => 1} @{$ecList};

    my %goID2Count = (); # gene to id list
    my $pstmt = $dbh->prepare("select TranscriptID, OntologyDomain, OntologyEvidenceCode from ontologies where OntologyID = ?, OntologyType = 'GO'");
    foreach my $goID (@{$goIDList}) {
      $pstmt->bind_param(1, $goID);
      $pstmt->execute();
      while( my @data = $pstmt->getchrow_array()) {
        next if ! defined $domainMap{$data[2]};
        next if ! defined $ecMap{$data[3]};
        $goID2Count{$goID} = 0 if(! defined $goID2Count{$goID});
        $goID2Count{$goID} = $goID2Count{$goID} + 1;
      } # end of fetch and counting
    } 
    return \%goID2Count;
}
