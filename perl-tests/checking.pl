#!/usr/bin/perl
# SPDX-FileCopyrightText: Copyright (c) 2022-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

package bibcop;

use strict;
use warnings;

# not enough fields
fails((':type' => 'book', 'title' => 'The TeX Book'));
fails((':type' => 'book', 'author' => 'Knuth, Donald'));
fails((':type' => 'book', 'year' => '1984'));

# dot inside title
fails((':type' => 'misc', 'year' => '1984', 'author' => 'Jeff', 'title' => '{Comm. of the ACM}'));

# wrong author name
fails((':type' => 'misc', 'year' => '1984', 'author' => 'Knuth, Donald E', 'title' => '{CACM}'));

# year inside title
fails((':type' => 'misc', 'year' => '1984', 'author' => 'Knuth', 'title' => '{1984 CACM}'));

# dot inside title
fails((':type' => 'misc', 'year' => '1984', 'author' => 'Knuth', 'title' => '{CACM.}'));

# wrong format of pages
fails((':type' => 'misc', 'year' => '1984', 'author' => 'Knuth', 'title' => '{CACM}', 'pages'=>'4a'));
fails((':type' => 'misc', 'year' => '1984', 'author' => 'Knuth', 'title' => '{CACM}', 'pages'=>'4-5'));
fails((':type' => 'misc', 'year' => '1984', 'author' => 'Knuth', 'title' => '{CACM}', 'pages'=>'54--21'));

# redundant space in title
fails((':type' => 'misc', 'year' => '1984', 'author' => 'Knuth', 'title' => '{The Article , a Good One}'));

# wrong doi
fails((':type' => 'misc', 'year' => '1984', 'author' => 'Knuth', 'title' => '{The Title}', 'doi' => 'http://dx.doi.org/1/1'));

# wrong capitalization
fails((':type' => 'misc', 'year' => '1984', 'author' => 'Knuth', 'title' => '{Object-oriented Programming}'));

passes((
  ':type' => 'book',
  'author' => "Knuth, Donald E. \n and Duane, Bibby",
  'title' => '{The TeX Book}',
  'year' => '1984',
  'edition' => '1',
  'doi' => '10.5555/1102013',
  'publisher' => 'Addison-Wesley Professional'
));
passes((
  ':type' => 'inproceedings',
  'author' => 'James and others',
  'title' => '{A \(\pi\)-Study vs. Other Studies}',
  'booktitle' => '{Proceedings of the ICCQ}',
  'year' => '1984',
  'volume' => '32',
  'doi' => '10.5555/1102013',
  'pages' => '89--100'
));
passes((
  ':type' => 'inproceedings',
  'author' => '{IEEE}',
  'title' => '{The {wrong} {word}}',
  'booktitle' => '{Proceedings of the ICCQ}',
  'year' => '1984',
  'volume' => '32',
  'doi' => '10.1016/0743-7315(91)90016-3',
  'pages' => '22--33'
));
passes((
  ':type' => 'misc',
  'author' => 'Doe, John',
  'title' => '{{The Title}}',
  'year' => '1984',
  'howpublished' => '\\url{https://www.yegor256.com}',
  'note' => 'it is a blog post'
));
passes((
  ':type' => 'phdthesis',
  'author' => 'Doe, John',
  'title' => '{The Title}',
  'year' => '1984',
  'school' => 'Stanford'
));

sub fails {
  my (%entry) = @_;
  my @errors = process_entry(%entry);
  if (@errors+0 eq 0) {
    show_entry(%entry);
    print "No error here, why?\n";
    exit 1;
  }
}

sub passes {
  my (%entry) = @_;
  my @errors = process_entry(%entry);
  if (@errors+0 gt 0) {
    show_entry(%entry);
    foreach my $err (@errors) {
      print "$err\n";
    }
    print "Error here, why?\n";
    exit 1;
  }
}

1;
