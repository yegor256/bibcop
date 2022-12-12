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

assert(clean_tex('Hello,   \LaTeX{}!'), 'Hello, \LaTeX{}!');
assert(clean_tex("Hello,\n\\TeX{}!"), 'Hello, \TeX{}!');
assert(clean_tex("  Gamma!"), 'Gamma!');
assert(clean_tex("Hello!  "), 'Hello!');
assert(clean_tex('{Alpha}'), 'Alpha');
assert(clean_tex('{{Beta}}'), 'Beta');
assert(clean_tex('Hello, {world!}'), 'Hello, {world!}');

1;