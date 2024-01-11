#!/usr/bin/perl
# (The MIT License)
#
# Copyright (c) 2022-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

package bibcop;

use warnings;
use strict;

# Assert on the value and exit if error.
sub assert {
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
require './perl-tests/functions.pl';
require './perl-tests/checks.pl';
require './perl-tests/cli.pl';

print "\033[0;32mGREAT!\033[0m All tests are green.\n";

