#!/usr/bin/perl
# (The MIT License)
#
# Copyright (c) 2022-2024 Yegor Bugayenko
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

use POSIX;

require './bibcop.pl';

fixes_entry({':name' => 'knuth78', ':type' => 'book', 'title' => 'The TeX Book'}, "\@book{knuth78,\n  title = {{The TeX Book}},\n}\n\n");
fixes_entry({':name' => 'k', ':type' => 'article', 'title' => 'Book', 'pages' => ''}, "\@article{k,\n  title = {{Book}},\n}\n\n");

my $today = strftime('%d-%m-%Y', localtime(time));
fixes_entry({':name' => 'f', ':type' => 'misc', 'url' => 'http://google.com'}, "\@misc{f,\n  howpublished = {\\url{http://google.com}},\n  note = {[Online; accessed $today]},\n}\n\n");

fixes_entry({':name' => 'f', ':type' => 'article', 'booktitle' => 'ONE'}, "\@article{f,\n  journal = {{ONE}},\n}\n\n");
fixes_entry({':name' => 'f', ':type' => 'inproceedings', 'journal' => 'ONE'}, "\@inproceedings{f,\n  booktitle = {{Proceedings of the ONE}},\n}\n\n");

sub fixes_entry {
  my ($hash, $expected) = @_;
  my %entry = %$hash;
  my $after = entry_fix(%entry);
  if ($after ne $expected) {
    print "Didn't fix \"entry\" into \"$expected\", but into \"$after\" instead\n";
    exit 1;
  }
}

1;