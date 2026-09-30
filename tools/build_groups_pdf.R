# Builds the PDF for Moodle: presentation schedule and names per group.
# Run from the project root: Rscript tools/build_groups_pdf.R
# Re-run after any change to students/groups.csv (tools/update_groups.R) or
# to the groups="..." attributes in syllabus.qmd (two groups swapping dates).
# The PDF states its version date so that the copy on Moodle can be checked.
#
# Input:  students/groups.csv (from tools/update_groups.R), syllabus.qmd,
#         _variables.yml
# Output: students/Group_assignment_and_presentation_schedule.pdf (gitignored)
#
# The document contains student names, so it is rendered in a temporary
# directory outside the Quarto website project and never reaches docs/.

source("tools/schedule.R")

groups_file <- "students/groups.csv"
pdf_file <- "students/Group_assignment_and_presentation_schedule.pdf"

vars <- yaml::read_yaml("_variables.yml")
groups <- read.csv(groups_file, colClasses = "character", fileEncoding = "UTF-8")
groups$group <- as.integer(groups$group)
schedule <- read_schedule()
dates <- presentation_dates(schedule, expected = unique(groups$group))

# Pipe table. `widths` sets the relative column widths via the dash counts.
cell <- function(x) gsub("|", "\\|", x, fixed = TRUE)
pipe_table <- function(df, widths) {
  row <- function(x) paste0("| ", paste(x, collapse = " | "), " |")
  c(row(names(df)),
    row(strrep("-", widths)),
    apply(df, 1, function(r) row(cell(r))))
}

schedule_tbl <- data.frame(
  "#" = schedule$session,
  Date = schedule$date,
  Topic = schedule$topic,
  "Group presentations" = groups_label(schedule$groups),
  check.names = FALSE
)

members <- vapply(dates$group, function(g) {
  m <- groups[groups$group == g, ]
  m <- m[order(m$familienname, m$rufname), ]
  paste(m$rufname, m$familienname, collapse = ", ")
}, character(1))
groups_tbl <- data.frame(
  Group = dates$group,
  Presentation = dates$date,
  Members = members
)

qmd <- c(
  "---",
  'title: "Group assignment and presentation schedule"',
  sprintf('subtitle: "The Psychology of Climate Change Communication — %s"', vars$course$semester),
  "format:",
  "  pdf:",
  "    papersize: a4",
  "---",
  "",
  "```{=latex}",
  "\\begin{center}",
  "\\begin{minipage}[c]{1.2in}",
  "  \\includegraphics[width=1.1in]{logo.png}",
  "\\end{minipage}\\hspace{2em}",
  "\\begin{minipage}[c]{2in}",
  "  \\includegraphics[width=2in]{eth_logo.png}",
  "\\end{minipage}",
  "\\end{center}",
  "\\vspace{0.5em}",
  "```",
  "",
  sprintf("Students were randomly assigned to %d groups. %s %s–%s, room %s.",
          length(unique(groups$group)), vars$course$weekday,
          vars$course$start, vars$course$end, vars$course$room),
  "",
  sprintf("Version of %s (%d students). Groups change when students drop the course or change group, this version replaces earlier ones.",
          format(Sys.Date(), "%d.%m.%Y"), nrow(groups)),
  "",
  "## Presentation schedule",
  "",
  pipe_table(schedule_tbl, widths = c(4, 12, 58, 26)),
  "",
  "## Groups",
  "",
  pipe_table(groups_tbl, widths = c(9, 16, 75)),
  ""
)

build_dir <- file.path(tempdir(), "groups_pdf")
dir.create(build_dir, showWarnings = FALSE)
writeLines(qmd, file.path(build_dir, "groups.qmd"), useBytes = TRUE)
file.copy(c("images/logo.png", "images/eth_logo.png"), build_dir, overwrite = TRUE)

status <- system2("quarto", c("render", shQuote(file.path(build_dir, "groups.qmd"))))
if (status != 0) stop("quarto render failed")

stopifnot(file.copy(file.path(build_dir, "groups.pdf"), pdf_file, overwrite = TRUE))
unlink(build_dir, recursive = TRUE)
cat("Wrote", pdf_file, "\n")
