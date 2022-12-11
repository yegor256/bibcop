assert(
  bibitems('@misc{test, author={Donald Knuth}, title="The TeX Book"}')+0 == 0,
  'Didn\'t find a single bibitem'
);

1;