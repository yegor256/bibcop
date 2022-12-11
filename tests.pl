#!/usr/bin/perl

# Assert on the value and exit if error.
sub assert {
  my ($v, $p) = @_;
  if (not($v)) {
    print $p . "\n";
    exit 1;
  }
}

require './bibcop.pl';
require './perl-tests/parsing.pl';
