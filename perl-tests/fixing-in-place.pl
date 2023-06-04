# (The MIT License)
#
# Copyright (c) 2022-2023 Yegor Bugayenko
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

my $stdout = `perl ./bibcop.pl --in-place --fix '$temp' 2>&1`;
if (not $stdout eq '') {
  print $stdout;
  print "This output was not expected!\n";
  exit 1;
}

open(my $in, '<', $temp);
my $after; { local $/; $after = <$in>; }

if (index($after, 'Knuth, Donald E.') == 1) {
  print "Didn't fix in place\n";
  exit 1;
}

1;