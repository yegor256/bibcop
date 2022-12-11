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

my @i1 = bibitems('@misc{knuth1984, author={Donald Knuth}, Title="The TeX Book"}');
# show(@i1);
assert(@i1+0, 1);
assert($i1[0]{':name'}, 'knuth1984');
assert($i1[0]{':type'}, 'misc');
assert($i1[0]{'author'}, 'Donald Knuth');
assert($i1[0]{'title'}, 'The TeX Book');

my @i2 = bibitems('@misc{patrick, author={{Patrick S\:{u}skind}}}');
# show(@i2);
assert(@i2+0, 1);
assert($i2[0]{'author'}, '{Patrick S\:{u}skind}');

my @i3 = bibitems('@misc{p1} @article{p2,author="Jeff"} ');
show(@i3);
assert(@i3+0, 2);
assert($i3[0]{':name'}, 'p1');
assert($i3[1]{':name'}, 'p2');
assert($i3[1]{'author'}, 'Jeff');

bibitems('');
bibitems('@misc{k1,a={{x}{y}{}},b="{f}{x}",}');
bibitems('@article{k1_34} @misc{do43ss,Title=,Year=1998}');
bibitems("\@article{t1}\n\n\n\@misc{ff,year=1998}");

1;