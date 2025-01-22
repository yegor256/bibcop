#!/usr/bin/perl
# (The MIT License)
#
# Copyright (c) 2022-2025 Yegor Bugayenko
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
