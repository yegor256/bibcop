#!/usr/bin/perl
# SPDX-FileCopyrightText: Copyright (c) 2022-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

package bibcop;

use strict;
use warnings;

fixes('author', 'Knuth, Donald E', 'Knuth, Donald E.');
fixes('author', 'Knuth, Donald E and Duane, Bibby', 'Knuth, Donald E. and Duane, Bibby');
fixes('author', ' Knuth, Donald   E   and others ', 'Knuth, Donald E. and others');
fixes('author', 'Knuth, Donald E.', 'Knuth, Donald E.');
fixes('author', 'Jerome,   K Jerome', 'Jerome, K. Jerome');
fixes('author', 'Landin, Peter   J.', 'Landin, Peter J.');
fixes('author', 'Brandon, Lucia', 'Brandon, Lucia');
fixes('author', 'Lucia Brandon', 'Brandon, Lucia');
fixes('author', 'Peter J. Landin', 'Landin, Peter J.');
fixes('author', 'Tan Yiyu and Lo {Wan You}', 'Yiyu, Tan and Lo {Wan You}');
fixes('author', 'van Buren, Andre', 'van Buren, Andre');
fixes('author', 'Munsen, C.J.', 'Munsen, C. J.');
fixes('author', 'J.J.G., Hanson', 'J. J. G., Hanson');

fixes('title', 'The TeX Book', 'The TeX Book');
fixes('title', 'Executing A program On The MIT architecture', 'Executing a Program on the MIT Architecture');
fixes('title', 'Executing a program on the MIT Tagged-token Dataflow architecture', 'Executing a Program on the MIT Tagged-Token Dataflow Architecture');
fixes('title', 'TeX: a Great Tool', 'TeX: A Great Tool');
fixes('title', 'TeX: A Great Tool', 'TeX: A Great Tool');
fixes('title', 'Does It Work? an empirical study', 'Does It Work? An Empirical Study');
fixes('title', 'it works? of course!', 'It Works? Of Course!');
fixes('title', 'first; second!', 'First; Second!');
fixes('title', 'Face-to-Face discussion', 'Face-to-Face Discussion');
fixes('title', 'Face-To-Face Talk', 'Face-to-Face Talk');
fixes('title', 'long question---short answer', 'Long Question --- Short Answer');
fixes('title', 'long question --- short answer', 'Long Question --- Short Answer');
fixes('title', 'does it work?---of course!', 'Does It Work? --- Of Course!');
fixes('title', 'does it work? --- of course!', 'Does It Work? --- Of Course!');
fixes('title', 'GitHub Audience?---a Thematic Analysis', 'GitHub Audience? --- A Thematic Analysis');
fixes('title', 'our in-house rules', 'Our In-House Rules');
fixes('title', 'user\'s story', 'User\'s Story');
fixes('title', 'step in, step out', 'Step in, Step Out');
fixes('title', 'are we there yet?', 'Are We There yet?');
fixes('title', 'GitHub Audience? --- a Thematic Analysis', 'GitHub Audience? --- A Thematic Analysis');

fixes('booktitle', 'Proceedings Of IEEE Symposium On Art', 'Proceedings of Symposium on Art');
fixes('booktitle', 'Symposium on Computers', 'Proceedings of the Symposium on Computers');
fixes('booktitle', 'Proceedings of the 2014 7th Conference', 'Proceedings of the 7th Conference');
fixes('booktitle', 'Proceedings of the 7th ACM/IEEE Conference', 'Proceedings of the 7th Conference');
fixes('booktitle', 'Proceedings of the First Conference', 'Proceedings of the 1st Conference');
fixes('booktitle', 'Proceedings of the Second Conference', 'Proceedings of the 2nd Conference');
fixes('booktitle', 'Proceedings of the Tenth Conference', 'Proceedings of the 10th Conference');

fixes('publisher', 'ACM New York, NY, USA', 'ACM');
fixes('publisher', 'ACME', 'ACME');
fixes('publisher', 'IEEE Computer Society', 'IEEE');
fixes('publisher', 'IEEE-Society', 'IEEE');
fixes('publisher', 'IEEEth', 'IEEEth');

fixes('pages', '13', '13');
fixes('pages', '13-', '13');
fixes('pages', '13--', '13');
fixes('pages', '-13', '13');
fixes('pages', '--13', '13');
fixes('pages', 'abc1', 'abc1');
fixes('pages', '196--230', '196--230');
fixes('pages', '100-110', '100--110');
fixes('pages', '117–128', '117--128');
fixes('pages', '2---33', '2--33');
fixes('pages', '22—23', '22--23');
fixes('pages', '05---07', '5--7');
fixes('pages', '42---13', '13--42');
fixes('pages', '103--91', '91--103');

fixes('number', '02', '2');
fixes('number', '007', '7');
fixes('number', '16', '16');

fixes('month', '02', '2');
fixes('month', 'January', '1');
fixes('month', 'Dec', '12');
fixes('month', '9', '9');
fixes('month', 'mar', '3');
fixes('month', 'march', '3');
fixes('month', 'March', '3');
fixes('month', 'MARCH  ', '3');
fixes('month', ' mar  ', '3');
fixes('month', 'something', 'something');

fixes('unicode', 'Fernández, Luis and Peña, Rosalía', 'Fern\\\'{a}ndez, Luis and Pe\~{n}a, Rosal\\\'{i}a');
fixes('unicode', 'Programmers’ Life', 'Programmers\' Life');

sub fixes {
  my ($tag, $before, $expected) = @_;
  my $fixer = "fix_$tag";
  no strict 'refs';
  my $after = $fixer->($before);
  if ($after ne $expected) {
    print "Didn't fix \"$before\" into \"$expected\", but into \"$after\" instead\n";
    exit 1;
  }
}

1;
