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

fails((':type' => 'book', 'title' => 'The TeX Book'));
fails((':type' => 'book', 'author' => 'Donald Knuth'));
fails((':type' => 'book', 'year' => '1984'));
passes((
  ':type' => 'book',
  'author' => 'Donald Knuth',
  'title' => '{The TeX Book}',
  'year' => '1984',
  'doi' => 'test'
));
passes((
  ':type' => 'inproceedings',
  'author' => 'James',
  'title' => '{The Title}',
  'booktitle' => '{Proceedings of ICCQ}',
  'year' => '1984',
  'volume' => '32',
  'doi' => 'd',
  'pages' => '22--33'
));

sub fails {
  my (%item) = @_;
  my @errors = process_item(%item);
  if (@errors+0 eq 0) {
    show_item(%item);
    print "No error here, why?\n";
    exit 1;
  }
}

sub passes {
  my (%item) = @_;
  my @errors = process_item(%item);
  if (@errors+0 gt 0) {
    show_item(%item);
    foreach my $err (@errors) {
      print "$err\n";
    }
    print "Error here, why?\n";
    exit 1;
  }
}

1;