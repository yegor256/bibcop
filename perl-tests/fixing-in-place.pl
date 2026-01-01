#!/usr/bin/perl
# SPDX-FileCopyrightText: Copyright (c) 2022-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

package bibcop;

use strict;
use warnings;
use File::Temp qw/ tempfile /;

my ($out, $temp) = tempfile();
print $out '@article{knuth, author = {Knuth, Donald E}} @book{lamport, title={LaTeX}}';
close($out);

my $stdout1 = `perl ./bibcop.pl --in-place --fix '$temp' 2>&1`;
if (not $stdout1 eq '') {
  print $stdout1;
  print "This output was not expected!\n";
  exit 1;
}

open(my $in1, '<', $temp);
my $after1; { local $/; $after1 = <$in1>; }
close($in1);

if (index($after1, 'Knuth, Donald E.') == 1) {
  print "Didn't fix in place\n";
  exit 1;
}

my $stdout2 = `perl ./bibcop.pl --in-place --fix '$temp' 2>&1`;
if (not $stdout2 eq '') {
  print $stdout2;
  print "This output was not expected!\n";
  exit 1;
}

open(my $in2, '<', $temp);
my $after2; { local $/; $after2 = <$in2>; }
close($in2);

if (not $after2 eq $after1) {
  print "Fixing again, why?\n";
  exit 1;
}

1;
