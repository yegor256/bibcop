-- (The MIT License)
--
-- Copyright (c) 2022-2025 Yegor Bugayenko
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the 'Software'), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

module = "bibcop"
ctanupload = true
typesetopts = "-interaction=batchmode -shell-escape -halt-on-error"
checkopts = "-interaction=batchmode -shell-escape -halt-on-error"
exefiles = {"bibcop.pl"}
sourcefiles = {"*.dtx", "*.ins", "*-????-??-??.sty", "bibcop.pl"}
checkengines = {"pdftex", "luatex", "xetex"}
tagfiles = {"build.lua", "bibcop.dtx"}
docfiles = {"bibcop.pl", "bibcop-logo.pdf"}
checkfiles = {"bibcop.pl"}
scriptfiles  = {"bibcop.pl"}
scriptmanfiles = {"bibcop.1"}
cleanfiles = {"build", "_docshots", "*.run.xml", "*.log", "*.bcf", "*.glo", "*.fls", "*.idx", "*.out", "*.fdb_latexmk", "*.aux", "*.sty", "*.zip", "bibcop.pdf", "*.bbl"}
dynamicfiles = {"*.bbl"}
tagfiles = {"bibcop.dtx", "bibcop.pl", "build.lua", "bibcop.1"}
typesetruns = 2
checkruns = 2

uploadconfig = {
  pkg = "bibcop",
  version = "0.0.0",
  author = "Yegor Bugayenko",
  uploader = "Yegor Bugayenko",
  email = "yegor256@gmail.com",
  note = "Bug fixes",
  announcement = "",
  ctanPath = "/biblio/bibtex/utils/bibcop",
  bugtracker = "https://github.com/yegor256/bibcop/issues",
  home = "",
  description = "Style Checker of .bib Files",
  development = "",
  license = "mit",
  summary = "This LaTeX package checks the quality of your .bib file and emits warning message if any issues found.",
  repository = "https://github.com/yegor256/bibcop",
  support = "",
  topic = {"ext-code", "biblio-supp"}
}

function update_tag(file, content, tagname, tagdate)
  return string.gsub(
    string.gsub(content, "0%.0%.0", tagname),
    "0000/00/00", os.date("%Y/%m/%d")
  )
end

function runtest_tasks(name, run)
  if run == 1 then
    return "bibtex " .. name
  else
    return ""
  end
end
