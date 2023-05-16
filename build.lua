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
  version = "0.0.10",
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
    "0000%-00%-00", os.date("%Y-%m-%d")
  )
end

function runtest_tasks(name, run)
  if run == 1 then
    return "bibtex " .. name
  else
    return ""
  end
end
