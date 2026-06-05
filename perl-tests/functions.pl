#!/usr/bin/perl
# SPDX-FileCopyrightText: Copyright (c) 2022-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

package bibcop;

use strict;
use warnings;

assert_eq(clean_tex('Hello,   \LaTeX{}!'), 'Hello, \LaTeX{}!');
assert_eq(clean_tex("Hello,\n\\TeX{}!"), 'Hello, \TeX{}!');
assert_eq(clean_tex("  Gamma!"), 'Gamma!');
assert_eq(clean_tex("Hello!  "), 'Hello!');
assert_eq(clean_tex('{Alpha}'), 'Alpha');
assert_eq(clean_tex('{{Beta}}'), 'Beta');
assert_eq(clean_tex('Hello, {world!}'), 'Hello, {world!}');

assert_eq(strip_outer_braces('{Alpha}'), 'Alpha');
assert_eq(strip_outer_braces('{Alpha {Beta} Gamma}'), 'Alpha {Beta} Gamma');
assert_eq(strip_outer_braces('{Alpha} and {Beta}'), '{Alpha} and {Beta}');
assert_eq(strip_outer_braces('Alpha'), 'Alpha');

my %cited = citations('\citation{alpha, beta}
\abx@aux@cite{0}{gamma}
\abx@aux@segm{0}{0}{delta}');
assert_eq(join(',', sort keys %cited), 'alpha,beta,delta,gamma');

1;
