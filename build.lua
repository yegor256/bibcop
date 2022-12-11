module = "bibcop"
ctanupload = true
typesetopts = "-interaction=batchmode -shell-escape -halt-on-error"
checkopts = "-interaction=batchmode -shell-escape -halt-on-error"
sourcefiles = {"*.dtx", "*.ins", "*-????-??-??.sty", "bibcop.pl"}
checkengines = {"pdftex", "luatex", "xetex"}
tagfiles = {"build.lua", "bibcop.dtx"}
docfiles = {"bibcop.pl"}
checkfiles = {"bibcop.pl"}
cleanfiles = {"build", "_docshots", "*.run.xml", "*.log", "*.bcf", "*.glo", "*.fls", "*.idx", "*.out", "*.fdb_latexmk", "*.aux", "*.sty", "*.zip", "bibcop.pdf", "*.bbl"}
dynamicfiles = {"*.bbl"}
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
  ctanPath = "/macros/latex/contrib/bibcop",
  bugtracker = "https://github.com/yegor256/bibcop/issues",
  home = "",
  description = "Style Checker of .bib Files",
  development = "",
  license = "mit",
  summary = "This LaTeX package checks the quality of your .bib file and emits warning message if any issues found.",
  repository = "https://github.com/yegor256/bibcop",
  support = "",
  topic = {"bibliography"}
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