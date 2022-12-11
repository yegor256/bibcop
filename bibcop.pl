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

use warnings;
# use strict;

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
      push(@items, \%item);
      $s = 'top';
    } elsif ($char eq '}' and $s eq 'key') {
      $item{':name'} = $acc;
      push(@items, \%item);
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
      break;
    }
    $acc = $acc . $char;
  }
  return @items;
}

# Check the presence of the 'year'
sub year_is_present {
  my (%item) = @_;
  if (not(exists $item{'year'})) {
    return 'The \'year\' key is missing'
  }
}

my @checks = (
  'year_is_present'
);

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
    foreach my $check (@checks) {
      my $err = $check->(%item);
      if ($err ne '') {
        print "\\PackageWarningNoLine{bibcop}{$err in the '$item{':name'}' bibitem}\n";
      }
    }
    print "\n";
  }
}

1;