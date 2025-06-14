#!/usr/bin/perl
# SPDX-FileCopyrightText: Copyright (c) 2022-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

# 0000/00/00 0.0.0
package bibcop;

use warnings;
use strict;
use POSIX;
use File::Basename;

# Hash of incoming command line arguments.
my %args = map { $_ => 1 } @ARGV;

# If you want to add an extra check, just create a new procedure
# named as "check_*".

# Only these tags are allowed and only these types of entries.
my %blessed = (
  'article' => ['doi', 'year', 'title', 'author', 'journal', 'volume', 'number', 'month?', 'pages?'],
  'inproceedings' => ['doi', 'booktitle', 'title', 'author', 'year', 'pages?', 'month?', 'organization?', 'volume?'],
  'incollection' => ['doi', 'booktitle', 'title', 'author', 'year', 'editor', 'pages?', 'month?', 'volume?', 'publisher?'],
  'book' => ['title', 'author', 'year', 'publisher', 'doi?', 'edition?'],
  'phdthesis' => ['title', 'author', 'year', 'school', 'doi?'],
  'misc' => ['title', 'author', 'year', 'eprint?', 'archiveprefix?', 'primaryclass?', 'month?', 'organization?', 'doi?', 'howpublished?', 'note?'],
);

# See https://research.arizona.edu/faq/what-do-you-mean-when-you-say-use-title-case-proposalproject-titles
my %minors = map { $_ => 1 } qw/in of at to by the a an and or as if up via yet nor but off on for into vs versus/;

# Check the presence of mandatory tags.
sub check_mandatory_tags {
  if (exists $args{'--no:tags'}) {
    return;
  }
  my (%entry) = @_;
  my $type = $entry{':type'};
  if (not exists $blessed{$type}) {
    return "The type of entry '$type' is not allowed"
  }
  my $mandatory = $blessed{$type};
  foreach my $tag (@$mandatory) {
    if ($tag =~ /^.*\?$/) {
      next;
    }
    if (not(exists $entry{$tag})) {
      my $listed = listed_tags(%entry);
      if ($tag eq 'doi' and exists $args{'--no:doi'}) {
        next;
      }
      return "A mandatory '$tag' tag for '\@$type' is missing among $listed"
    }
  }
  if (exists $blessed{$type}) {
    my %required = map { $_ => 1 } @$mandatory;
    foreach my $tag (keys %entry) {
      if ($tag =~ /^:/) {
        next;
      }
      if (not(exists $required{$tag}) && not(exists $required{$tag . '?'})) {
        return "The '$tag' tag is not suitable for '$type', use only these: (@$mandatory)"
      }
    }
  }
}

# Check that all major words are capitalized.
sub check_capitalization {
  if (exists $args{'--no:caps'}) {
    return;
  }
  my (%entry) = @_;
  my %tags = map { $_ => 1 } qw/title booktitle journal publisher organization/;
  foreach my $tag (keys %entry) {
    if (not exists $tags{$tag}) {
      next;
    }
    my @ends = qw/ ; ? . --- : ! /;
    my $value = $entry{$tag};
    my @words = only_words($value);
    my $pos = 0;
    foreach my $word (@words) {
      $word =~ s/\.$//g;
      $pos = $pos + 1;
      if (not $word =~ /^[A-Za-z]/) {
        next;
      }
      if ($word =~ /^\{.*|.*\}$/) {
        next;
      }
      if (exists $minors{$word}) {
        if ($pos eq 1) {
          return "The minor word '$word' in the '$tag' must be upper-cased since it is the first one"
        }
        my $before = $words[$pos - 2];
        if (grep(/^\Q$before\E$/, @ends)) {
          return "The minor word '$word' in the '$tag' must be upper-cased, because it follows the '$before'"
        }
        next;
      }
      if (exists $minors{lc($word)}) {
        if ($pos eq 1) {
          next;
        }
        my $before = $words[$pos - 2];
        if (grep(/^\Q$before\E$/, @ends)) {
          next;
        }
        return "All minor words in the '$tag' must be lower-cased, while @{[as_position($pos)]} word '$word' is not"
      }
      if ($word =~ /^[a-z].*/) {
        return "All major words in the '$tag' must be capitalized, while @{[as_position($pos)]} word '$word' is not"
      }
    }
  }
}

# Check that the 'author' is formatted correctly.
sub check_author {
  my (%entry) = @_;
  my @tags = qw/author editor/;
  foreach my $tag (@tags) {
    if (not exists $entry{$tag}) {
      next;
    }
    if ($entry{$tag} =~ /^\{.+\}$/) {
      next;
    }
    my $author = clean_tex($entry{$tag});
    my @authors = split(/\s+and\s+/, $author);
    my $pos = 0;
    for my $a (@authors) {
      $pos += 1;
      if ($a eq 'others') {
        next;
      }
      if (index($a, ' ') != -1 and index($a, ',') == -1) {
        return "The last name should go first, all other names must follow, after a comma in @{[as_position($pos)]} '$tag', as in 'Knuth, Donald E.'";
      }
      my $npos = 0;
      for my $name (split(/[ ,]+/, $a)) {
        $npos += 1;
        if (index($name, '{') != -1) {
          next;
        }
        if ($name =~ /^[A-Z]\.$/) {
          next;
        }
        if ($name =~ /^[A-Z][^.]+$/) {
          next
        }
        if ($name =~ /^(van|de|der|dos|von|e)$/) {
          next
        }
        if ($name =~ /^[A-Z]$/) {
          return "A shortened name must have a tailing dot in @{[as_position($pos)]} '$tag', as in 'Knuth, Donald E.'";
        }
        return "In @{[as_position($pos)]} '$tag' @{[as_position($npos)]} name looks suspicious ($name), use something like 'Knuth, Donald E. and Duane, Bibby'";
      }
    }
  }
}

# Check that titles don't have shortened words with a tailing dot.
sub check_shortenings {
  my (%entry) = @_;
  my %tags = map { $_ => 1 } qw/title booktitle journal/;
  foreach my $tag (keys %entry) {
    if (not exists $tags{$tag}) {
      next;
    }
    my $value = $entry{$tag};
    my @words = split(/ /, clean_tex($value));
    foreach my $word (@words) {
      if (not $word =~ /^[A-Za-z]/) {
        next;
      }
      if ($word eq 'vs.') {
        next;
      }
      if ($word =~ /\.\.\.$/) {
        next;
      }
      if ($word =~ /^.*\.$/) {
        return "Do not shorten the words in the '$tag', such as '$word'"
      }
    }
  }
}

# Check the right format of the 'title' and 'booktitle.'
sub check_wrapping {
  if (exists $args{'--no:wraps'}) {
    return;
  }
  my (%entry) = @_;
  my @tags = qw/title booktitle/;
  foreach my $tag (@tags) {
    if (not exists($entry{$tag})) {
      next;
    }
    my $title = $entry{$tag};
    if (not $title =~ /^\{.+\}$/) {
      return "The '$tag' must be wrapped in double curled brackets"
    }
  }
}

# Check the right format of the tags for arXiv.
# See https://arxiv.org/help/arxiv_identifier
sub check_arXiv {
  my (%entry) = @_;
  if (exists($entry{'archiveprefix'})) {
    if (not exists $entry{'eprint'}) {
      return "The 'eprint' is mandatory when 'archiveprefix' is there"
    }
    if (not $entry{'eprint'} =~ /^[0-9]{4}\.[0-9]{4,5}(v[0-9]+)?$/) {
      return "The 'eprint' must have two integers separated by a dot"
    }
    my $eprint = $entry{'eprint'};
    my ($head, $tail) = split(/\./, $eprint);
    my $year = substr($head, 0, 2);
    my $month = substr($head, 2);
    if ($month > 12) {
      return "The month '$month' of the 'eprint' is wrong, it can't be bigger than 12"
    }
    if (not exists $entry{'primaryclass'}) {
      return "The 'primaryclass' is mandatory when 'archiveprefix' is there"
    }
    if (not $entry{'primaryclass'} =~ /^[a-z]{2,}\.[A-Z]{2}$/) {
      return "The 'primaryclass' must have two parts, like 'cs.PL'"
    }
  }
}

# Check that organization is not mentioned in the booktitle.
sub check_org_in_booktitle {
  if (exists $args{'--no:org'}) {
    return;
  }
  my (%entry) = @_;
  my @orgs = qw/ACM IEEE/;
  if (exists($entry{'booktitle'})) {
    my $title = $entry{'booktitle'};
    foreach my $o (@orgs) {
      if ($title =~ /^.*\Q$o\E.*$/) {
        return "The '$o' organization must not be mentioned in the booktitle, use 'publisher' tag instead"
      }
    }
    if ($title =~ /^.*(ACM|IEEE).*$/) {
      return "Don't mention the organization in the booktitle, use 'publisher' tag instead"
    }
  }
}

# Check that no values have tailing dots.
# Check that there are no spaces before commands.
sub check_typography {
  my (%entry) = @_;
  my %symbols = (
    '...' => 'ellipses',
    '.' => 'dot',
    ',' => 'comma',
    ';' => 'semi-colon',
    ':' => 'colon',
    '!' => 'exclamation mark',
    '?' => 'question mark',
    '-' => 'dash',
    '--' => 'double dash',
    '---' => 'triple dash',
    '(' => 'opening bracket',
    ')' => 'closing bracket',
    '[' => 'opening square bracket',
    ']' => 'closing square bracket',
  );
  my @need_spaces_around = ( '---', '...' );
  my @no_spaces_around = ( '--', '-' );
  my @no_space_before = ( '.', ',', ';', ':', '?', '!', ')', ']' );
  my @no_space_after = ( '(', '[' );
  my @need_space_before = ( '(', '[' );
  my @need_space_after = ( ')', ']', ',' );
  my @good_tails = ( 'Inc.', 'Ltd.' );
  my @bad_tails = ( '.', ',', ';', ':', '-' );
  foreach my $tag (keys %entry) {
    if ($tag =~ /^:.*/) {
      next;
    }
    if ($tag eq 'doi') {
      next;
    }
    my $value = $entry{$tag};
    foreach my $s (@bad_tails) {
      if ($s eq '.' and ($tag eq 'author' or $tag eq 'editor')) {
        next;
      }
      my $good = 0;
      foreach my $gt (@good_tails) {
        if ($value =~ /^.*\Q$gt\E$/) {
          $good = 1;
        }
      }
      if (not $good) {
        if ($value =~ /^.*\Q$s\E$/) {
          return "The '$tag' must not end with a $symbols{$s}"
        }
      }
    }
    foreach my $s (@no_space_before) {
      if ($value =~ /^.*\s\Q$s\E(?!\Q$s\E).*$/) {
        return "In the '$tag', do not put a space before the $symbols{$s}"
      }
    }
    foreach my $s (@no_space_after) {
      if ($value =~ /^.*\Q$s\E\s.*$/) {
        return "In the '$tag', do not put a space after the $symbols{$s}"
      }
    }
    foreach my $s (@need_space_before) {
      if ($value =~ /^.*[^\{\s\\]\Q$s\E.*$/) {
        return "In the '$tag', put a space before the $symbols{$s}"
      }
    }
    foreach my $s (@need_space_after) {
      my $p = join('', @no_space_before);
      if ($value =~ /^.*[^\\]\Q$s\E[^\}\s\Q$p\E].*$/) {
        return "In the '$tag', put a space after the $symbols{$s}"
      }
    }
    foreach my $s (@need_spaces_around) {
      if ($value =~ /^.*[^\s]\Q$s\E.*$/ or $value =~ /^.*\Q$s\E[^\s].*$/) {
        return "In the '$tag', put spaces around the $symbols{$s}"
      }
    }
    foreach my $s (@no_spaces_around) {
      if ($value =~ /^.*\s\Q$s\E\s.*$/) {
        return "In the '$tag', don't put spaces around the $symbols{$s}"
      }
    }
  }
}

# Check that the type is small letters.
sub check_type_capitalization {
  my (%entry) = @_;
  my $type = $entry{':type'};
  if (not $type =~ /^[a-z]+$/) {
    return "The type '$type' must be lower-cased"
  }
}

# Check that no values have non-ASCII symbols.
sub check_ascii {
  my (%entry) = @_;
  foreach my $tag (keys %entry) {
    if ($tag =~ /^:.*/) {
      next;
    }
    my $value = $entry{$tag};
    for my $pos (0..length($value)-1) {
      my $char = substr($value, $pos, 1);
      my $ord = ord($char);
      if ($ord == 9 || $ord == 10 || $ord == 13) {
        next;
      }
      if ($ord < 20) {
        return "In the '$tag', don't use control symbol '0x" . (sprintf '%04x', $ord) . "'"
      }
      if ($ord > 0x7f) {
        return "In the '$tag', don't use Unicode symbol '0x" . (sprintf '%04x', $ord) . "'"
      }
    }
  }
}

# Check the year is not mentioned in titles.
sub check_year_in_titles {
  my (%entry) = @_;
  my @tags = qw/title booktitle journal/;
  foreach my $tag (@tags) {
    if (not exists($entry{$tag})) {
      next;
    }
    my @words = only_words($entry{$tag});
    foreach my $word (@words) {
      if ($word =~ /^[1-9][0-9]{3}$/) {
        return "The '$tag' must not contain the year $word, it is enough to have the 'year' tag"
      }
    }
  }
}

# Check the right format of the 'booktitle' in the 'inproceedings' entry.
sub check_booktitle_of_inproceedings {
  if (exists $args{'--no:inproc'}) {
    return;
  }
  my (%entry) = @_;
  if ($entry{':type'} eq 'inproceedings') {
    if (exists $entry{'booktitle'}) {
      my @words = only_words($entry{'booktitle'});
      if (lc($words[0]) ne 'proceedings' or lc($words[1]) ne 'of' or lc($words[2]) ne 'the') {
        return "The booktitle must start with 'Proceedings of the ...'"
      }
    }
  }
}

# Check the right format of the 'doi.'
sub check_doi {
  if (exists $args{'--no:doi'}) {
    return;
  }
  my (%entry) = @_;
  if (exists $entry{'doi'}) {
    my $doi = $entry{'doi'};
    if (not $doi =~ /^[0-9a-zA-Z.]+\/[0-9a-zA-Z._\-)(><:;\/]+$/) {
      return "The format of the 'doi' is wrong"
    }
  }
}

# Check the right format of the 'howpublished.'
sub check_howpublished {
  my (%entry) = @_;
  if (exists $entry{'howpublished'}) {
    my $how = $entry{'howpublished'};
    if (not $how =~ /^\\url\{.+\}$/) {
      return "The format of the 'howpublished' is wrong, use \\url{} inside"
    }
    my $url = substr($how, 5, -1);
    if (not $url =~ /^https?:\/\/.+$/) {
      return "The format of the URL in 'howpublished' is wrong, doesn't start with https://: '$url'"
    }
    my $max = 64;
    my $len = length($url);
    if ($len > $max) {
      return "The length of the URL in 'howpublished' is too big ($len > $max), use URL shortener: '$url'"
    }
  }
}

# Check the right format of the 'year.'
sub check_year {
  my (%entry) = @_;
  if (exists $entry{'year'}) {
    my $year = $entry{'year'};
    if ($year =~ /^\{.+\}$/) {
      return;
    }
    if (not $year =~ /^[0-9]+$/) {
      return "The format of the 'year' is wrong, may only contain numbers or must be wrapped in curly braces"
    }
    if (not $year =~ /^[0-9]{4}$/) {
      return "Exactly four digits must be present in the 'year', or it must be wrapped in curly braces"
    }
  }
}

# Check the right format of the 'month.'
sub check_month {
  my (%entry) = @_;
  if (exists $entry{'month'}) {
    my $month = $entry{'month'};
    if (not $month =~ /^[1-9]|10|11|12$/) {
      return "The format of the 'month' is wrong"
    }
  }
}

# Check the right format of the 'volume.'
sub check_volume {
  my (%entry) = @_;
  if (exists $entry{'volume'}) {
    my $volume = $entry{'volume'};
    if (not $volume =~ /^[1-9][0-9]*$/) {
      return "The format of the 'volume' is wrong"
    }
  }
}

# Check the right format of the 'number.'
sub check_number {
  my (%entry) = @_;
  if (exists $entry{'number'}) {
    my $number = $entry{'number'};
    if (not $number =~ /^[1-9][0-9]*$/) {
      return "The format of the 'number' is wrong"
    }
  }
}

# Check the right format of the 'pages.'
sub check_pages {
  my (%entry) = @_;
  if (exists $entry{'pages'}) {
    my $pages = $entry{'pages'};
    if (not $pages =~ /^([1-9][0-9]*--[1-9][0-9]*|[1-9][0-9]*)$/) {
      return "The format of the 'pages' is wrong"
    }
    my @parts = split(/--/, $pages);
    if (@parts+0 eq 2) {
      if ($parts[0] eq $parts[1]) {
        return "The 'pages' mentions the same page twice, just use it once"
      }
      if ($parts[0] > $parts[1]) {
        return "The 'pages' are in the wrong order, since $parts[0] is greater than $parts[1]"
      }
    }
  }
}

# Check unescaped symbols.
sub check_unescaped_symbols {
  my (%entry) = @_;
  my @symbols = ( '&' );
  foreach my $tag (keys %entry) {
    if ($tag =~ /^:.*/) {
      next;
    }
    my $value = $entry{$tag};
    foreach my $s (@symbols) {
      if ($value =~ /^(.*[^\\{]|)\Q$s\E.*$/) {
        return "The '$tag' contains a dangerous unescaped symbol (wrap it in curled brackets if you really need it)"
      }
    }
  }
}

# Check one entry.
sub process_entry {
  my (%entry) = @_;
  my @checks;
  foreach my $entry (keys %bibcop::) {
    if ($entry =~ /^check_/) {
      push(@checks, $entry);
    }
  }
  my @sorted = sort @checks;
  my @errors;
  foreach my $check (@sorted) {
    no strict 'refs';
    my $err = $check->(%entry);
    if (defined $err and $err ne '') {
      push(@errors, $err);
    }
  }
  return @errors;
}

# Fix one entry.
sub entry_fix {
  my (%entry) = @_;
  if (not exists $entry{':type'}) {
    error("I don't know what to do with an entry without a type");
  }
  my $type = $entry{':type'};
  if (not exists $blessed{$type}) {
    error("I don't know what to do with \@$type type of BibTeX entry");
  }
  if (not exists $entry{':name'}) {
    error("I don't know what to do with an entry without a name");
  }
  my $tags = $blessed{$type};
  my %allowed = map { $_ => 1 } @$tags;
  my @lines;
  if (exists $entry{'booktitle'} and $entry{':type'} eq 'article') {
    $entry{'journal'} = $entry{'booktitle'};
  }
  if (exists $entry{'journal'} and $entry{':type'} eq 'inproceedings') {
    $entry{'booktitle'} = $entry{'journal'};
  }
  foreach my $tag (keys %entry) {
    if ($tag =~ /^:/) {
      next;
    }
    my $value = clean_tex($entry{$tag});
    if ($tag eq 'url') {
      my $today = strftime('%d-%m-%Y', localtime(time));
      push(@lines, "  howpublished = {\\url{$value}},");
      push(@lines, "  note = {[Online; accessed $today]},");
      next;
    }
    if (not exists $allowed{$tag} and not exists $allowed{$tag . '?'}) {
      next;
    }
    my $fixer = "fix_$tag";
    my $fixed = $value;
    if (defined &{$fixer}) {
      no strict 'refs';
      $value = $fixer->($value);
    }
    $value = fix_unicode($value);
    if ($tag =~ /title|booktitle|journal/) {
      $value = '{' . $value . '}';
    }
    if (not $value eq '') {
      push(@lines, "  $tag = {$value},");
    }
  }
  my $fixed = "\@$type\{$entry{':name'},\n";
  my @sorted = sort @lines;
  foreach my $line (@sorted) {
    $fixed = $fixed . $line . "\n";
  }
  $fixed = $fixed . "}\n\n";
  return $fixed;
}

sub fix_author {
  my ($value) = @_;
  $value =~ s/\s{2,}/ /g;
  my @authors = split(/\s+and\s+/, $value);
  foreach my $author (@authors) {
    $author =~ s/^\s+|\s+$//g;
    if (index($author, ' {') != -1 or index($author, '} ') != -1) {
      next;
    }
    $author =~ s/ ([A-Z])($| )/ $1.$2/g;
    if (index($author, ',') == -1) {
      my @words = split(/\s+/, $author);
      my $total = @words+0;
      if ($total > 1) {
        $author = $words[$total - 1] . ', ' . join(' ', @words[0 .. $total - 2]);
      }
    }
    $author =~ s/([A-Z])\.(?![ ,])/$1. /g;
    $author =~ s/^\s+|\s+$//g;
  }
  return join(' and ', @authors);
}

sub fix_number {
  my ($value) = @_;
  $value =~ s/^0+//g;
  return $value;
}

sub fix_month {
  my ($value) = @_;
  my %months = (
    '1' => 'jan|january',
    '2' => 'feb|february',
    '3' => 'mar|march',
    '4' => 'apr|april',
    '5' => 'may',
    '6' => 'jun|june',
    '7' => 'jul|july',
    '8' => 'aug|august',
    '9' => 'sep|september',
    '10' => 'oct|october',
    '11' => 'nov|november',
    '12' => 'dec|december',
  );
  $value =~ s/^(0| )+//g;
  $value =~ s/(0| )+$//g;
  while(my($v, $re) = each %months) {
    if ($value =~ qr/$re/i) {
      $value = $v;
      last;
    }
  }
  return $value;
}

sub fix_capitalization {
  my ($value) = @_;
  my @words = split(/\s+/, $value);
  my $pos = 0;
  foreach my $word (@words) {
    $pos += 1;
    if (not $word =~ /^[A-Za-z]/) {
      next;
    }
    my $start = 1;
    if ($pos > 1) {
      my $before = $words[$pos - 2];
      if (not $before =~ /(:|\?|!|;|-)$/) {
        $start = 0;
      }
    }
    my @parts = split(/-/, $word, -1);
    my $p = 0;
    foreach my $part (@parts) {
      $p += 1;
      my $lcp = lc($part);
      my $head = $lcp;
      $head =~ s/[,\.!\?;:]$//g;
      if (exists $minors{$head}) {
        if ($p > 1) {
          my $pre = $parts[$p - 2];
          if (not $pre eq '') {
            $part = $lcp;
            next;
          }
        } elsif (@parts+0 == 1) {
          if (not $start) {
            $part = $lcp;
            next;
          }
        }
      }
      $part =~ s/^([a-z])/\U$1/g;
    }
    $word = join('-', @parts);
  }
  return join(' ', @words);
}

sub fix_title {
  my ($value) = @_;
  $value = fix_capitalization($value);
  $value =~ s/([^ ])---/$1 ---/g;
  $value =~ s/---([^ ])/--- $1/g;
  return $value;
}

sub fix_pages {
  my ($value) = @_;
  if ($value =~ /^[1-9][0-9]*$/ || $value eq '') {
    return $value;
  }
  my ($left, $right) = split(/---|--|-|–|—|\s/, $value);
  if (!defined $left || $left eq '') {
    $left = $right;
  }
  if (!defined $right || $right eq '') {
    $right = $left;
  }
  $left =~ s/^0+//g;
  $right =~ s/^0+//g;
  if ($left !~ /^[0-9]*$/ or $right !~ /^[0-9]*$/) {
    return $value;
  }
  $left = $left + 0;
  $right = $right + 0;
  if ($left > $right) {
    my $tmp = $left;
    $left = $right;
    $right = $tmp;
  }
  if ($left eq $right) {
    return $left;
  }
  return $left . '--' . $right;
}

sub fix_booktitle {
  my ($value) = @_;
  $value = fix_capitalization($value);
  if (index($value, 'Proceedings ') != 0) {
    $value = 'Proceedings of the ' . $value;
  }
  $value =~ s/ (19|20)[0-9]{2} / /g;
  my @orgs = qw/ACM IEEE ACM\/IEEE IEEE\/ACM/;
  foreach my $org (@orgs) {
    $value =~ s/ \Q$org\E / /g;
  }
  my %numbers = (
    'First' => '1st',
    'Second' => '2nd',
    'Third' => '3rd',
    'Fourth' => '4th',
    'Fifth' => '5th',
    'Sixth' => '6th',
    'Seventh' => '7th',
    'Eighth' => '8th',
    'Ninth' => '9th',
    'Tenth' => '10th'
  );
  keys %numbers;
  while(my($left, $right) = each %numbers) {
    $value =~ s/^Proceedings of the \Q$left\E /Proceedings of the $right /g;
  }
  return $value;
}

sub fix_journal {
  my ($value) = @_;
  $value = fix_capitalization($value);
  return $value;
}

sub fix_org_name {
  my ($value) = @_;
  my @orgs = qw/ACM IEEE/;
  foreach my $org (@orgs) {
    $value =~ s/^\Q$org\E($|[^A-Z0-9a-z].*$)/$org/g;
  }
  return $value;
}

sub fix_publisher {
  my ($value) = @_;
  $value = fix_capitalization($value);
  $value = fix_org_name($value);
  return $value;
}

sub fix_organization {
  my ($value) = @_;
  $value = fix_capitalization($value);
  $value = fix_org_name($value);
  return $value;
}

sub fix_unicode {
  my ($value) = @_;
  my %literals = (
    'ò' => '\`{o}', 'ó' => '\\\'{o}', 'ô' => '\^{o}', 'ö' => '\"{o}', 'ő' => '\H{o}', 'ǒ' => '\v{o}', 'õ' => '\~{o}',
    'à' => '\`{a}', 'á' => '\\\'{a}', 'â' => '\^{a}', 'ä' => '\"{a}', 'å' => '\r{a}', 'ą' => '\k{a}', 'ǎ' => '\v{a}', 'ã' => '\~{a}',
    'ù' => '\`{u}', 'ú' => '\\\'{u}', 'û' => '\^{u}', 'ü' => '\"{u}', 'ů' => '\r{u}', 'ǔ' => '\v{u}', 'ũ' => '\~{u}',
    'ì' => '\`{i}', 'í' => '\\\'{i}', 'î' => '\^{i}', 'ï' => '\"{i}', 'ǐ' => '\v{i}', 'ĩ' => '\~{i}',
    'ń' => '\\\'{n}', 'ň' => '\v{n}', 'ñ' => '\~{n}',
    'ç' => '\c{c}',
    'ł' => '\l{}',
    'ı' => '{\i}',
    'ø' => '\o{}',
    '–' => '--', '—' => '---',
    '’' => '\''
  );
  keys %literals;
  while(my($k, $v) = each %literals) {
    $value =~ s/\Q$k\E/$v/g;
  }
  return $value;
}

# Parse the incoming .bib file and return an array
# of hash-maps, where each one is a bibentry.
sub entries {
  my ($bib) = @_;
  my @entries;
  my $s = 'top';
  my %entry;
  my $acc = '';
  my $tag = '';
  my $interrupted = ''; # where the comment interrupted the proceeding (state name)
  my $lineno = 0;
  my $nest = 0;
  my $escape = 0;
  for my $pos (0..length($bib)-1) {
    my $char = substr($bib, $pos, 1);
    if ($char eq ' ') {
      # ignore the white space
    } elsif ($char eq '%' and not($s eq 'quote')) {
      if ($pos eq 0 or substr($bib, $pos - 1, 1) ne '\\') {
        $interrupted = $s;
        $s = 'comment';
      }
    } elsif ($char eq "\n") {
      # ignore the EOL
      $lineno = $lineno + 1;
      if ($s eq 'comment') {
        $s = $interrupted;
      }
    } elsif ($s eq 'comment') {
      # ignore the comment
    } elsif ($s eq 'top') {
      if ($char eq '@') {
        %entry = ();
        $s = 'start';
        $acc = '';
      } else {
        warning("Each BibTeX entry must start with '\@', what is '$char' at line no.$lineno?");
        last;
      }
    } elsif ($char =~ /[a-zA-Z]/ and $s eq 'start') {
      # @article
    } elsif ($char eq '{' and $s eq 'start') {
      $entry{':type'} = substr($acc, 1);
      $acc = '';
      $s = 'body';
    } elsif ($char =~ /[a-zA-Z0-9]/ and $s eq 'body') {
      $acc = '';
      $s = 'tag';
    } elsif ($char =~ /[a-zA-Z0-9_\.\-\/:]/ and $s eq 'tag') {
      # reading the tag
    } elsif ($char =~ /[a-zA-Z0-9]/ and $s eq 'value') {
      # reading the value without quotes or brackets
    } elsif ($char eq ',' and $s eq 'tag') {
      $entry{':name'} = $acc;
      $s = 'body';
    } elsif ($char eq '=' and $s eq 'tag') {
      my $t = lc($acc);
      if (exists $entry{$t}) {
        warning("The tag '$t' is seen more than once at line no.$lineno");
      }
      $tag = $t;
      $s = 'value';
      $acc = '';
    } elsif ($char eq ',' and $s eq 'value') {
      if (not exists $entry{$tag}) {
        my $tex = substr($acc, 1);
        $tex =~ s/\s//g;
        $entry{$tag} = $tex;
      }
      $s = 'body';
    } elsif ($char eq '}' and $s eq 'body') {
      push(@entries, { %entry });
      $s = 'top';
    } elsif ($char eq '}' and $s eq 'value') {
      if (not exists $entry{$tag}) {
        my $tex = substr($acc, 1);
        $tex =~ s/\s//g;
        $entry{$tag} = $tex;
      }
      push(@entries, { %entry });
      $s = 'top';
    } elsif ($char eq '}' and $s eq 'tag') {
      $entry{':name'} = $acc;
      push(@entries, { %entry });
      $s = 'top';
    } elsif ($char eq '"' and $s eq 'value') {
      $s = 'quote';
      $acc = '';
    } elsif ($char eq '"' and $s eq 'quote') {
      $entry{$tag} = substr($acc, 1);
      $s = 'value';
    } elsif ($s eq 'quote') {
      # nothing
    } elsif ($char eq '{' and $s eq 'value') {
      $nest = 1;
      $s = 'brackets';
      $acc = '';
    } elsif ($s eq 'brackets') {
      if ($char eq '\\') {
        $escape = 1;
      } elsif ($char eq '{' and $escape != 1) {
        $nest = $nest + 1;
      } elsif ($char eq '}' and $escape != 1) {
        $nest = $nest - 1;
        if ($nest == 0) {
          $entry{$tag} = substr($acc, 1);
          $s = 'value';
        }
      }
      $escape = 0;
    } else {
      warning("It is impossible to parse the .bib file, because I do not know what to do with '$char' at line no.$lineno (s=$s)");
      last;
    }
    if ($char eq ' ' and not($s =~ /quote|brackets/)) {
      next;
    }
    $acc = $acc . $char;
  }
  return @entries;
}

# Takes the text and returns only list of words seen there.
sub only_words {
  my ($tex) = @_;
  my $t = clean_tex($tex);
  $t =~ s/([^a-zA-Z0-9\\'])/ $1 /g;
  $t =~ s/- +- +-/---/g;
  $t =~ s/{ /{/g;
  $t =~ s/ }/}/g;
  return split(/ +/, $t);
}

# Take a TeX string and return a cleaner one, without redundant spaces, brackets, etc.
sub clean_tex {
  my ($tex) = @_;
  $tex =~ s/\s+/ /g;
  $tex =~ s/^\s+//g;
  $tex =~ s/\s+$//g;
  while ($tex =~ s/^\{(.+)\}$/$1/g) {};
  return $tex;
}

# Turn a number into a position, like 1 -> 1st, 2 -> 2nd, 3 -> 3rd, 4 -> 4th, and so on.
sub as_position {
  my ($i) = @_;
  my $txt;
  if ($i == 1) {
    $txt = '1st';
  } elsif ($i == 2) {
    $txt = '2nd';
  } elsif ($i == 3) {
    $txt = '3rd';
  } else {
    $txt = "${i}th";
  }
  return "the $txt";
}

# Take a bibentry and print all its tags as a comma-separated string.
sub listed_tags {
  my (%entry) = @_;
  my @list;
  foreach my $tag (keys %entry) {
    if ($tag =~ /^:.*/) {
      next;
    }
    push(@list, $tag);
  }
  my @sorted = sort @list;
  return '(' . join(', ', @sorted) . ')';
}

# Make sure the text can safely be rendered in TeX.
sub escape_tex {
  my ($tex) = @_;
  $tex =~ s/[^a-zA-Z0-9-.,+)(:;@ '"]/?/g;
  return $tex;
}

# Print ERROR message to the console and die.
sub error {
  my ($txt) = @_;
  if (exists $args{'--latex'}) {
    print "\\PackageError{bibcop}{" . escape_tex($txt). "}{}\n";
  } else {
    print STDERR $txt . "\n";
  }
  fail();
}

# Print DEBUG message to the console.
sub debug {
  my ($txt) = @_;
  if (exists $args{'--verbose'}) {
    if (exists $args{'--latex'}) {
      print "\\message{bibcop: " . escape_tex($txt) . "^^J}\n";
    } else {
      print $txt . "\n";
    }
  }
}

# Print INFO message to the console.
sub info {
  my ($txt) = @_;
  if (exists $args{'--latex'}) {
    print '% ';
  }
  print $txt . "\n";
}

# Print INFO message to the console.
sub warning {
  my ($txt) = @_;
  if (exists $args{'--latex'}) {
    print "\\PackageWarningNoLine{bibcop}{" . escape_tex($txt) . "}\n";
  } else {
    print $txt . "\n";
  }
}

sub fail {
  if (exists $args{'--latex'}) {
    exit(0);
  } else {
    exit(1);
  }
}

my $script = basename($0);
$script =~ s/\.pl$//g;
if (not $script eq 'bibcop') {
  goto END;
}

if (@ARGV+0 eq 0 or exists $args{'--help'} or exists $args{'-?'}) {
  info("Bibcop is a style checker of BibTeX files (.bib)\n\n" .
    "Usage:\n" .
    "  bibcop [<options>] <.bib file path>\n\n" .
    "Options:\n" .
    "  -v, --version   Print the current version of Bibcop and exit\n" .
    "  -?, --help      Print this help screen\n" .
    "      --fix       Fix the errors and print a new version of the .bib file to the console\n" .
    "  -i, --in-place  When used together with the --fix, modifies the file in place, doesn't print it to the console\n" .
    "      --verbose   Print supplementary debugging information\n" .
    "      --no:XXX    Disable one of the following checks (e.g. --no:wraps):\n" .
    "                    tags    Only some tags are allowed, while some of them are mandatory\n" .
    "                    caps    All major words in titles and booktitles must be capitalized\n" .
    "                    wraps   Double curly braces are required around titles and booktitles\n" .
    "                    doi     The presence of the 'doi' tag is mandatory in all entries\n" .
    "                    inproc  The booktitle of \@inproceedings must start with 'Proceedings of the'\n" .
    "                    org     The booktitle may not mention ACM or IEEE\n" .
    "      --latex     Report errors in LaTeX format using the \\PackageWarningNoLine command\n\n" .
    "If any issues, please, report to GitHub: https://github.com/yegor256/bibcop");
} elsif (exists $args{'--version'} or exists $args{'-v'}) {
  info('0.0.0 0000/00/00');
} else {
  my ($file) = grep { not($_ =~ /^-.*$/) } @ARGV;
  if (not $file) {
    error('File name must be specified');
  }
  open(my $fh, '<', $file) or error('Cannot open file: ' . $file);
  my $bib; { local $/; $bib = <$fh>; }
  my @entries = entries($bib);
  if (exists $args{'--fix'}) {
    my $fixed = '';
    my %seen;
    for my $i (0..(@entries+0 - 1)) {
      my %entry = %{ $entries[$i] };
      my $name = $entry{':name'};
      if (exists $seen{$name}) {
        next;
      }
      $fixed = $fixed . entry_fix(%entry);
      $seen{$name} = 1;
    }
    my ($head) = $bib =~ /^((?:%.*\n)+\n*)/;
    $fixed = $head . $fixed;
    if (exists $args{'-i'} or exists $args{'--in-place'}) {
      open(my $out, '>', $file) or error('Cannot open file for writing: ' . $file);
      print $out $fixed;
      close($out);
    } else {
      info($fixed);
    }
  } else {
    debug((@entries+0) . ' entries found in ' . $file);
    my $found = 0;
    for my $i (0..(@entries+0 - 1)) {
      my %entry = %{ $entries[$i] };
      debug("Checking $entry{':name'} (no.$i)...");
      foreach my $err (process_entry(%entry)) {
        warning("$err, in the '$entry{':name'}' entry");
        $found += 1;
      }
    }
    if ($found > 0) {
      debug("$found problem(s) found");
      fail();
    }
  }
}

END:

# In order to finish it with success:
1;
