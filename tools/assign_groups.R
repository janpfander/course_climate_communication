# Random assignment of students to presentation groups.
# Run once, from the project root: Rscript tools/assign_groups.R
#
# Input:  students/roster_2026-09-28.xlsx (myStudies export, gitignored)
# Output: students/groups_draw_2026-09-28.csv (gitignored), one row per student
#
# The result is frozen: the script stops if the output exists, so a draw that
# has been announced to students cannot be reshuffled by accident. Later
# changes (drop-outs, students changing group) are never made here: record
# them in students/group_changes.csv and run tools/update_groups.R, which
# writes the current list students/groups.csv.
# Which group presents in which session is set in syllabus.qmd (groups="...").

roster_file <- "students/roster_2026-09-28.xlsx"
groups_file <- "students/groups_draw_2026-09-28.csv"
n_students <- 65
n_groups <- 13
seed <- 20260928

if (file.exists(groups_file)) {
  stop(groups_file, " already exists. The draw is final, delete the file by hand to redraw.")
}

roster <- readxl::read_excel(roster_file, sheet = "EDOZ", col_types = "text")
roster <- data.frame(
  familienname = trimws(roster[["Familienname"]]),
  rufname = trimws(roster[["Rufname"]]),
  email = trimws(roster[["E-Mail"]])
)

stopifnot(
  "unexpected number of students in the roster" = nrow(roster) == n_students,
  "missing name or email" = !anyNA(roster) && all(nzchar(unlist(roster))),
  "duplicated email" = !anyDuplicated(tolower(roster$email))
)

set.seed(seed)
roster <- roster[sample(nrow(roster)), ]
roster$group <- rep(seq_len(n_groups), length.out = nrow(roster))

groups <- roster[order(roster$group, roster$familienname), c("group", "familienname", "rufname", "email")]
write.csv(groups, groups_file, row.names = FALSE, fileEncoding = "UTF-8")

cat("Wrote", groups_file, "\nGroup sizes:\n")
print(table(group = groups$group))
