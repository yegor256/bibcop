<img src="https://raw.githubusercontent.com/yegor256/bibcop/master/bibcop-logo.svg" height="92px"/>

[![l3build](https://github.com/yegor256/bibcop/actions/workflows/l3build.yml/badge.svg)](https://github.com/yegor256/bibcop/actions/workflows/l3build.yml)
[![CTAN](https://img.shields.io/ctan/v/bibcop)](https://ctan.org/pkg/bibcop)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/bibcop/blob/master/LICENSE.txt)

This LaTeX package checks the quality of your `.bib` file and
emits warning message if any issues found. You may also like
[biblint](https://github.com/Kingsford-Group/biblint) tool —
it does almost the same but from the command line.

First, [install it](https://en.wikibooks.org/wiki/LaTeX/Installing_Extra_Packages)
from [CTAN](https://ctan.org/pkg/bibcop)
and then use in the preamble (if you use BibTeX, for example):

```tex
\documentclass{article}
\usepackage{bibcop}
\begin{document}
\bibliographystyle{plain}
\bibliography{main}
\end{document}
```

Otherwise, you can download [`bibcop.sty`](https://raw.githubusercontent.com/yegor256/bibcop/gh-pages/bibcop/bibcop.sty) and add to your project.

You can also download [bibcop.pl](https://raw.githubusercontent.com/yegor256/bibcop/master/bibcop.pl)
and use it as a command line tool
to check your `.bib` files and to auto-fix them:

```
$ ./bibcop.pl --fix main.bib > fixed.bib
```

This command will read the `main.bib` file and create `fixed.bib`, which
will have the fixed and properly formatted content (well, to some extent).

## How to Contribute

If you want to contribute yourself, make a fork, then create a branch, 
then run `l3build ctan` in the root directory.
It should compile everything without errors. If not, submit an issue and wait.
Otherwise, make your changes and then run `l3build ctan` again. If the build is
still clean, submit a pull request.

If you want to add a new check, add it as a Perl subroutine to the `bibcop.pl` file.
Don't forget to add a test to one of the test files that stay in the `perl-tests/` directory.
When ready, run this, in order to check that all tests pass:

```bash
$ ./tests.pl
```

You should see the `GREAT!` message.