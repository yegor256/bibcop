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

my $f = 'check_typography';
check_fails($f, ('title' => 'A redundant space , before the comma'));
check_fails($f, ('title' => 'A redundant space . before the dot'));
check_fails($f, ('title' => 'A redundant space ; before the semi'));
check_fails($f, ('title' => 'A redundant space : before the colon'));
check_fails($f, ('title' => 'A redundant space ? before the question'));
check_fails($f, ('title' => 'A redundant space ! before the exclamation'));
check_fails($f, ('title' => 'No spaces around the---triple dash'));
check_fails($f, ('title' => 'Not enough spaces around the--- triple dash'));
check_fails($f, ('title' => 'Not enough spaces around the ---triple dash'));
check_passes($f, ('title' => 'Proper placement of, with no space in front of it'));
check_passes($f, ('title' => 'Proper placement of. with no space in front of it'));
check_passes($f, ('title' => 'Proper placement of: with no space in front of it'));
check_passes($f, ('title' => 'Proper placement of; with no space in front of it'));
check_passes($f, ('title' => 'Proper placement of? with no space in front of it'));
check_passes($f, ('title' => 'Proper placement of! with no space in front of it'));
check_passes($f, ('title' => 'Proper placement of --- with spaces around'));

$f = 'check_titles';
check_fails($f, ('title' => 'The title is not surrounded by curled brackets'));
check_passes($f, ('title' => '{This title is surrounded}'));

$f = 'check_shortenings';
check_fails($f, ('journal' => 'J. Log. Comp.'));
check_passes($f, ('booktitle' => 'Communications of the ACM'));

$f = 'check_author';
check_fails($f, ('author' => 'Donald E. Knuth'));
check_fails($f, ('author' => 'Knuth, Donald E'));
check_fails($f, ('author' => 'Knuth, Donald E. et al.'));
check_passes($f, ('author' => 'Knuth'));
check_passes($f, ('author' => 'Knuth and others'));
check_passes($f, ('author' => 'Knuth and Duane'));
check_passes($f, ('author' => 'Knuth, Donald E.'));
check_passes($f, ('author' => 'Knuth, Donald E. and others'));
check_passes($f, ('author' => 'Knuth, Donald E. and Duane, Bibby'));

sub check_fails {
  my ($f, %item) = @_;
  no strict 'refs';
  my $error = $f->(%item);
  if ($error eq '') {
    show_item(%item);
    print "No error here, why?\n";
    exit 1;
  }
}

sub check_passes {
  my ($f, %item) = @_;
  no strict 'refs';
  my $error = $f->(%item);
  if ($error ne '') {
    show_item(%item);
    print "$error\n";
    print "Error here, why?\n";
    exit 1;
  }
}

1;