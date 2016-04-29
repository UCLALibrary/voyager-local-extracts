#!/m1/shared/bin/perl -w

use strict;
use DBI;
use lib "/opt/local/perl";
use MARC::Batch;
use UCLA_Batch; #for UCLA_Batch::safenext to better handle data errors

# set up db connection to ucladb
my $username = "ucla_preaddb";
# Requires these supporting files...
my $password = `/opt/local/bin/get_value.pl /opt/local/bin/vger_db_credentials $username`;
my $dsn = "dbi:Oracle:host=localhost;sid=VGER";
my $dbh = DBI->connect($dsn, $username, $password) or die DBI->errstr;

# get ids of suppressed mfhds associated with oacis extract
my $sql = "SELECT mfhd_id FROM vger_report.oacis_extract WHERE suppress_in_opac = 'Y'";
my $sth = $dbh->prepare($sql);
my $result = $sth->execute();

# build a simple hash table for rapid random access to all mfhd_ids, using id as key and dummy value
my $mfhd_id;
my %mfhd_ids;
$sth->bind_col(1, \$mfhd_id);
while ($sth->fetch) {
  $mfhd_ids{ $mfhd_id } = 1;
}
print "loaded " . keys(%mfhd_ids) . " mfhd ids - removing suppressed records\n";

# done with the db so clean up
$result = $sth->finish();
$dbh->disconnect();

# open marc input & output files
my $marcinfile = $ARGV[0] or die "Must provide marc input filename\n";
my $marcoutfile = $ARGV[1] or die "Must provide marc output filename\n";
open OUT, '>:utf8', "$marcoutfile" or die "Cannot open outputfile $marcoutfile\n";
my $batch = MARC::Batch->new('USMARC', $marcinfile);
# turn off strict validation - otherwise, all records after error are lost
$batch->strict_off();

# read records & process
#while (my $record = $batch->next()) {
while (my $record = UCLA_Batch::safenext($batch)) {
  my $oktowrite = "true";
  # check for 004 field, which means this is a holdings record (mfhd)
  my $field = $record->field('004');
  if ($field) {
    my $record_id = $record->field('001')->as_string();
    if (exists $mfhd_ids{$record_id}) {
      # print "skipping suppressed mfhd $record_id\n";
      $oktowrite = "false";
    } 
  }
  if ($oktowrite eq "true") {
    print OUT $record->as_usmarc();
  }
}
    
close OUT;
exit 0;

