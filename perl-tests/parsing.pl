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

my @i1 = entries('@Misc{knuth-1984:x, author  ={Donald Knuth}, Title="The TeX Book "}');
# show(@i1);
assert_eq(@i1+0, 1);
assert_eq($i1[0]{':name'}, 'knuth-1984:x');
assert_eq($i1[0]{':type'}, 'Misc');
assert_eq($i1[0]{'author'}, 'Donald Knuth');
assert_eq($i1[0]{'title'}, 'The TeX Book ');

my @i2 = entries('@misc{patrick, author={{Patrick S\:{u}skind}},}');
# show(@i2);
assert_eq(@i2+0, 1);
assert_eq($i2[0]{'author'}, '{Patrick S\:{u}skind}');

my @i3 = entries('@misc{p1} @article{p2,author="Jeff"} ');
# show(@i3);
assert_eq(@i3+0, 2);
assert_eq($i3[0]{':name'}, 'p1');
assert_eq($i3[1]{':name'}, 'p2');
assert_eq($i3[1]{'author'}, 'Jeff');

my @i4 = entries('@misc{x1, year =   1989   }');
# show(@i4);
assert_eq(@i4+0, 1);
assert_eq($i4[0]{'year'}, '1989');

my @i5 = entries('@misc{x2,year=2021,}');
# show(@i5);
assert_eq(@i5+0, 1);
assert_eq($i5[0]{'year'}, '2021');

my @i6 = entries('@misc{x2,year=2021,year=1989}');
# show(@i6);
assert_eq(@i6+0, 1);
assert_eq($i6[0]{'year'}, '2021');

my @i7 = entries("\% a comment\n \@misc{7}\n");
# show(@i7);
assert_eq(@i7+0, 1);

my @i8 = entries("\@misc{foo33, title={It's 100\\% true!}}\n");
# show(@i8);
assert_eq(@i8+0, 1);

# These are all parsing errors
assert_eq(entries('no bibs')+0, 0);
assert_eq(entries('@misc{---}')+0, 0);
assert_eq(entries('@misc{hello, ??}')+0, 0);

assert_eq(entries('')+0, 0);
assert_eq(entries('@misc{k1,a={{x}{y}{}},b="{f}{x}",}')+0, 1);
assert_eq(entries('@article{k1_34} @misc{do43ss,Title=,Year=1998}')+0, 2);
assert_eq(entries("\@article{t1}\n\n\n\@misc{ff,year=1998}")+0, 2);
assert_eq(entries('@misc{42i-88/7.7,a=hello}')+0, 1);

1;
