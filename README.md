# Bibcop: Style Checker of BibTeX .bib files

![bibcop logo](bibcop-logo.png)

[![l3build](https://github.com/yegor256/bibcop/actions/workflows/l3build.yml/badge.svg)](https://github.com/yegor256/bibcop/actions/workflows/l3build.yml)
[![CTAN](https://img.shields.io/ctan/v/bibcop)](https://ctan.org/pkg/bibcop)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yegor256/bibcop/blob/master/LICENSE.txt)

This LaTeX package checks the quality of your `.bib` file and
emits warning messages if any issues are found. You may also like
[biblint](https://github.com/Kingsford-Group/biblint) and
[biblatex-check](https://github.com/pezmc/biblatex-check) tools —
they do _almost_ the same but from the command line.

Read [this blog post][BLOG], in order to understand
the motivation behind this package.

First, [install it][INSTALL] from [CTAN](https://ctan.org/pkg/bibcop)
and then use in the preamble
(if you use [BibTeX](http://www.bibtex.org/), for example):

```tex
\documentclass{article}
\usepackage{bibcop}
\begin{document}
\bibliographystyle{plain}
\bibliography{main}
\end{document}
```

You can also add it as a GitHub Action to your
GitHub repository, with the help of
[bibcop-action](https://github.com/yegor256/bibcop-action).

Otherwise, you can download
[`bibcop.sty`](https://yegor256.github.io/bibcop/bibcop.sty)
and add to your project (together with
[`bibcop.pl`](https://yegor256.github.io/bibcop/bibcop.pl)!).

You can also download
[`bibcop.pl`](https://yegor256.github.io/bibcop/bibcop.pl)
and use it as a command line tool
to check your `.bib` files and to auto-fix them
(you should have [Perl](https://www.perl.org) installed):

```bash
perl bibcop.pl --fix main.bib > fixed.bib
```

This command will read the `main.bib` file and
create `fixed.bib`, which will have the fixed and properly
formatted content (well, to some extent).
Be careful, all comments will be removed.

You can also make changes inline, not creating a new file:

```bash
perl bibcop.pl --fix --in-place main.bib
```

If you install the package using
[`tlmgr`](https://www.tug.org/texlive/tlmgr.html),
you should be able to use `bibcop` directly, without the
necessity to mention Perl:

```bash
tlmgr install bibcop
bibcop --help
```

## How to use as pre-commit hook

If you use [pre-commit], simply add this to your config:

```yaml
-   repo: https://github.com/yegor256/bibcop
    rev: 0.0.32
    hooks:
    -   id: bibcop
        args: []
```

## Architecture

The core logic resides in a single [Perl](https://www.perl.org) script,
  `bibcop.pl`, which parses `.bib` files and runs all checks.
The [LaTeX](https://www.latex-project.org) package (`bibcop.sty`) is a
  thin wrapper that invokes this script at compile time via the `\iexec`
  macro (from [iexec](https://ctan.org/pkg/iexec)), using TeX's
  `--shell-escape` mechanism, by hooking into `\bibliography` and
  `\addbibresource`.
This is the key differentiator from tools like
  [biblint](https://github.com/Kingsford-Group/biblint) and
  [biblatex-check](https://github.com/pezmc/biblatex-check), which run
  only from the command line: bibcop runs automatically during every
  LaTeX compilation without a separate invocation step.

Check functions follow a naming convention: every Perl subroutine whose
  name matches `check_*` is auto-discovered at runtime by introspecting
  the package symbol table inside `process_entry()`.
Adding a new check requires only a new `sub check_*` function with no
  registration step, so a defined check can never be silently skipped.

Only six [BibTeX](http://www.bibtex.org) entry types are permitted:
  `@article`, `@book`, `@incollection`, `@inproceedings`, `@misc`, and
  `@phdthesis`, each with a fixed allowlist of tags in `%blessed`.
Tags outside the allowlist are an error.
This closed-world model is stricter than tools such as
  [biblatex-check](https://github.com/pezmc/biblatex-check), which
  tolerate arbitrary or unknown tags.

The [BibTeX](http://www.bibtex.org) parser in `entries()` is a
  hand-written, character-by-character state machine that depends only
  on Perl's built-in `POSIX` and `File::Basename` modules.
[BibTeX::Parser](https://metacpan.org/pod/BibTeX::Parser) and similar
  [CPAN](https://www.cpan.org) libraries were deliberately avoided so
  that installing bibcop from [CTAN](https://ctan.org/pkg/bibcop)
  requires no separate Perl module installation.

The script detects at runtime whether it is invoked as a CLI tool or
  loaded as a Perl module via `require`, by inspecting `basename($0)`.
This lets the same file serve both the LaTeX package backend and the
  standalone command-line interface without any code duplication.

The package source and documentation coexist in a single `.dtx` file
  following the [DocStrip](https://ctan.org/pkg/docstrip) convention;
  the `.sty` is extracted by [l3build](https://ctan.org/pkg/l3build)
  via `bibcop.ins`.
Tests split into two suites: [l3build](https://ctan.org/pkg/l3build)
  testfiles cover the LaTeX integration layer, while `perl tests.pl`
  runs Perl-level unit tests directly.

Beyond reporting, the `--fix` flag activates an auto-correction mode
  where dedicated `fix_*` subroutines reformat field values: author
  names, page ranges, capitalization, and
  [Unicode](https://unicode.org)-to-TeX transliteration.
This repair capability is absent from both
  [biblint](https://github.com/Kingsford-Group/biblint) and
  [biblatex-check](https://github.com/pezmc/biblatex-check).

## How to Contribute

If you want to contribute yourself, make a fork, then create a branch,
then run `l3build ctan` in the root directory. It should compile
everything without errors. If not, submit an issue and wait.
Otherwise, make your changes and then run `l3build ctan` again.
If the build is still clean, submit a pull request.

If you want to add a new check, add it as a Perl subroutine
to the `bibcop.pl` file. Don't forget to add a test to one of the test
files that stay in the `perl-tests/` directory.
When ready, run this, in order to check that all tests pass:

```bash
perl tests.pl
```

You should see the `GREAT!` message.

Copyright (c) 2022-2026 Yegor Bugayenko, MIT License

[BLOG]: https://www.yegor256.com/2023/09/05/style-checker-for-bibtex-files.html
[INSTALL]: https://en.wikibooks.org/wiki/LaTeX/Installing_Extra_Packages
[pre-commit]: https://pre-commit.com/
