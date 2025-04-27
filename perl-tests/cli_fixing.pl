#!/usr/bin/perl
# SPDX-FileCopyrightText: Copyright (c) 2022-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

package bibcop;

use strict;
use warnings;
use File::Temp qw/ tempfile /;

assert_fix_compare('duplicates');
assert_fix_compare('no-fixes');

sub read_file {
  my ($path) = @_;
  open(my $h, '<', $path) or error('Cannot open file: ' . $path);
  my $content; { local $/; $content = <$h>; }
  $content =~ s/^\s+|\s+$//g;
  return $content;
}

sub assert_fix_compare {
  my ($dir) = @_;
  my $before = "test-files/fixes/$dir/before.bib";
  my $expected = "test-files/fixes/$dir/expected.bib";
  my ($a, $after) = tempfile();
  close $a;
  my $cmd = "perl ./bibcop.pl --fix $before > $after";
  my $stdout = `$cmd`;
  my $exit = $? >> 8;
  if ($exit != 0) {
    print "---\n$stdout\n";
    print "Exit code is $exit (not zero) for '$cmd'\n";
    exit 1;
  }
  my $expected_bib = read_file($expected);
  my $after_bib = read_file($after);
  if (not $expected_bib eq $after_bib) {
    print "$after_bib\n";
    print "Doesn't match:\n";
    print "$expected_bib\n";
    exit 1;
  }
}


1;
