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

use strict;
use warnings;

fails(('title' => 'The TeX Book'));
fails(('author' => 'Donald Knuth'));
fails(('year' => '1984'));
passes(('author' => 'Donald Knuth', 'title' => '{The TeX Book}', 'year' => '1984'));

sub fails {
  my (%item) = @_;
  my @errors = check(%item);
  if (@errors+0 eq 0) {
    show_item(%item);
    print "No error here, why?\n";
    exit 1;
  }
}

sub passes {
  my (%item) = @_;
  my @errors = check(%item);
  if (@errors+0 gt 0) {
    show_item(%item);
    print "Error here, why?\n";
    exit 1;
  }
}

1;