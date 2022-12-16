# (The MIT License)
#
# Copyright (c) 2022 Yegor Bugayenko
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

assert_exec('--version', 0, qr/0\.0\.0/s);
assert_exec('-v', 0, qr/0\.0\.0/s);
assert_exec('--help', 0, qr/--version /s);
assert_exec('-?', 0, qr/--version /s);
assert_exec('./test-files/test.bib', 0, qr/\QThe 'title' must be wrapped\E/s);
assert_exec('--latex ./test-files/test.bib', 0, qr/\Q\PackageWarningNoLine{bibcop}{The 'title' must be wrapped\E/s);
assert_exec('--fix ./test-files/test.bib', 0, qr/\Q{{The TeX Book}}\E/s);

assert_exec('missing-file.bib', 256, qr/\QCannot open file: missing-file.bib\E/s);
assert_exec('--fix', 256, qr/\QFile name must be specified\E/s);

sub assert_exec {
  my ($cmd, $e, $re) = @_;
  my $args = "./bibcop.pl ${cmd}";
  my $stdout = `$args 2>&1`;
  my $exit = $?;
  if ($exit ne $e) {
    print "$stdout\n";
    print "Exit code is $exit (not $e)\n";
    exit 1;
  }
  if (not $stdout =~ $re) {
    print "$stdout\n";
    print "Doesn't match $re\n";
    exit 1;
  }
}


1;