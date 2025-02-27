#!/usr/bin/perl
# SPDX-FileCopyrightText: Copyright (c) 2022-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

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
