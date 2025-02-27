#!/usr/bin/perl
# SPDX-FileCopyrightText: Copyright (c) 2022-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

package bibcop;

use warnings;
use strict;

# Assert on the value and exit if error.
sub assert_eq {
  my ($l, $r) = @_;
  if ($l ne $r) {
    print "'$l' ne '$r'\n";
    exit 1;
  }
}

# Print entry to console.
sub show_entry {
  my (%entry) = @_;
  print "{\n";
  foreach my $k (keys %entry) {
    print "  $k = {$entry{$k}}\n";
  }
  print "}\n";
}

# Print entries to console.
sub show {
  my (@entries) = @_;
  print 'Total entries: ' . (@entries+0) . "\n";
  for my $i (0..(@entries+0 - 1)) {
    my %entry = %{ $entries[$i] };
    show_entry(%entry);
  }
}

require './bibcop.pl';
require './perl-tests/parsing.pl';
require './perl-tests/checking.pl';
require './perl-tests/fixing.pl';
require './perl-tests/entry_fixing.pl';
require './perl-tests/functions.pl';
require './perl-tests/checks.pl';
require './perl-tests/cli.pl';
require './perl-tests/cli_fixing.pl';

print "\033[0;32mGREAT!\033[0m All tests are green.\n";
