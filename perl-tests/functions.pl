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

1;
