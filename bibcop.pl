#!/usr/bin/perl
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

use warnings;
use strict;

# If you want to add an extra check, just create a new procedure
# named as "check_*".

# Check the presence of mandatory keys.
sub check_mandatory_keys {
  my (%item) = @_;
  my %keys = (
    'article' => ['doi', 'year', 'title', 'author'],
    'inproceedings' => ['booktitle', 'title', 'author', 'year', 'doi', 'pages'],
    'book' => ['title', 'author', 'year', 'doi'],
    'misc' => ['title', 'author', 'year'],
  );
  my $type = $item{':type'};
  my $mandatory = $keys{$type};
  foreach my $key (@$mandatory) {
    if (not(exists $item{$key})) {
      return "A mandatory '$key' key for '$type' is missing"
    }
  }
  my %required = map { $_ => 1 } @$mandatory;
  foreach my $key (keys %item) {
    if ($key =~ /^:/) {
      next;
    }
    if (not(exists $required{$key})) {
      return "The '$key' key is not suitable for '$type', use only these: (@$mandatory)"
    }
  }
}

if (@ARGV+0 == 0) {
  print "The path of .bib file is required\n";
} else {
  open(my $fh, '<', $ARGV[0]);
  my $bib; { local $/; $bib = <$fh>; }
  my @items = bibitems($bib);
  print '% ' . (@items+0) . ' bibitems found in ' . $ARGV[0] . "\n";
  for my $i (0..(@items+0 - 1)) {
    my %item = %{ $items[$i] };
    print "\% Checking $item{':name'} (#$i)...\n";
    foreach my $err (process_item(%item)) {
      print "\\PackageWarningNoLine{bibcop}{$err in the '$item{':name'}' bibitem}\n";
    }
    print "\n";
  }
}

# Check one item.
sub process_item {
  my (%item) = @_;
  my @checks;
  foreach my $entry (keys %bibcop::) {
    if ($entry =~ /^check_/) {
      push(@checks, $entry);
    }
  }
  my @errors;
  foreach my $check (@checks) {
    no strict 'refs';
    my $err = $check->(%item);
    if ($err ne '') {
      push(@errors, $err);
    }
  }
  return @errors;
}

# Parse the incoming .bib file and return an array
# of hash-maps, where each one is a bibitem.
sub bibitems {
  my ($bib) = @_;
  my @items;
  my $s = 'top';
  my %item;
  my $acc = '';
  my $key = '';
  my $lineno = 0;
  my $nest = 0;
  my $escape = 0;
  for my $pos (0..length($bib)-1) {
    my $char = substr($bib, $pos, 1);
    if ($char eq ' ') {
      # ignore the white space
    } elsif ($char eq "\n") {
      # ignore the EOL
      $lineno = $lineno + 1;
    } elsif ($char eq '@' and $s eq 'top') {
      %item = ();
      $s = 'start';
      $acc = '';
    } elsif ($char =~ /[a-z]/ and $s eq 'start') {
      # @article
    } elsif ($char eq '{' and $s eq 'start') {
      $item{':type'} = substr($acc, 1);
      $acc = '';
      $s = 'body';
    } elsif ($char =~ /[a-zA-Z]/ and $s eq 'body') {
      $acc = '';
      $s = 'key';
    } elsif ($char =~ /[a-zA-Z0-9_]/ and $s eq 'key') {
      # reading the key
    } elsif ($char =~ /[a-zA-Z0-9]/ and $s eq 'value') {
      # reading the value without quotes or brackets
    } elsif ($char eq ',' and $s eq 'key') {
      $item{':name'} = $acc;
      $s = 'body';
    } elsif ($char eq '=' and $s eq 'key') {
      $key = $acc;
      $s = 'value';
      $acc = '';
    } elsif ($char eq ',' and $s eq 'value') {
      $s = 'body';
    } elsif ($char eq '}' and $s =~ /body|value/) {
      my %copy = %item;
      push(@items, \%copy);
      $s = 'top';
    } elsif ($char eq '}' and $s eq 'key') {
      $item{':name'} = $acc;
      my %copy = %item;
      push(@items, \%copy);
      $s = 'top';
    } elsif ($char eq '"' and $s eq 'value') {
      $s = 'quote';
      $acc = '';
    } elsif ($char eq '"' and $s eq 'quote') {
      $item{lc($key)} = substr($acc, 1);
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
      } elsif ($char eq '{' and $escape ne 1) {
        $nest = $nest + 1;
      } elsif ($char eq '}' and $escape ne 1) {
        $nest = $nest - 1;
        if ($nest eq 0) {
          $item{lc($key)} = substr($acc, 1);
          $s = 'value';
        }
      }
      $escape = 0;
    } else {
      print "\\PackageWarningNoLine{bibcop}{Don't know what to do with '$char' at line #$lineno (s=$s)}\n";
      last;
    }
    $acc = $acc . $char;
  }
  return @items;
}

1;