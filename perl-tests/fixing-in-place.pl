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