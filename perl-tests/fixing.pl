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

fixes('author', 'Knuth, Donald E', 'Knuth, Donald E.');
fixes('author', 'Knuth, Donald E and Duane, Bibby', 'Knuth, Donald E. and Duane, Bibby');
fixes('author', ' Knuth, Donald E   and others ', 'Knuth, Donald E. and others');
fixes('author', 'Knuth, Donald E.', 'Knuth, Donald E.');
fixes('author', 'Jerome, K Jerome', 'Jerome, K. Jerome');
fixes('author', 'Landin, Peter J.', 'Landin, Peter J.');
fixes('author', 'Brandon, Lucia', 'Brandon, Lucia');

fixes('title', 'The TeX Book', 'The TeX Book');
fixes('title', 'Executing A program On The MIT architecture', 'Executing a Program on the MIT Architecture');
fixes('title', 'Executing a program on the MIT Tagged-token Dataflow architecture', 'Executing a Program on the MIT Tagged-Token Dataflow Architecture');

fixes('booktitle', 'Proceedings Of IEEE Symposium On Art', 'Proceedings of IEEE Symposium on Art');
fixes('booktitle', 'Symposium on Computers', 'Proceedings of the Symposium on Computers');

fixes('pages', '13', '13');
fixes('pages', '196--230', '196--230');
fixes('pages', '100-110', '100--110');
fixes('pages', '2---33', '2--33');
fixes('pages', '22—23', '22--23');
fixes('pages', '05---07', '5--7');

fixes('number', '02', '2');
fixes('number', '007', '7');
fixes('number', '16', '16');

sub fixes {
  my ($tag, $before, $expected) = @_;
  my $fixer = "fix_$tag";
  no strict 'refs';
  my $after = $fixer->($before);
  if ($after ne $expected) {
    print "Didn't fix \"$before\" into \"$expected\", but into \"$after\" instead\n";
    exit 1;
  }
}

1;