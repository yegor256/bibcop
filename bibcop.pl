#!/usr/bin/perl

# Parse the incoming .bib file and return an array
# of hash-maps, where each one is a bibitem.
sub bibitems {
  my ($bib) = @_;
  return ();
}

if (@ARGV+0 == 0) {
  print "The path of .bib file is required\n";
} else {
  open(my $fh, '<', $ARGV[0]);
  my $bib; { local $/; $bib = <$fh>; }

  my @items = bibitems($bib);

  print '% ' . (@items+0) . ' bibitems found in ' . $ARGV[0] . "\n";

  # print '\PackageWarningNoLine{bibcop}{Hello, world!}';
}

1;