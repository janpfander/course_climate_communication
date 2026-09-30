# Applies the recorded group changes (drop-outs and moves after the draw) to
# the frozen draw and writes the current group list.
# Run from the project root after adding a row to students/group_changes.csv:
#   Rscript tools/update_groups.R
# then Rscript tools/build_groups_pdf.R and re-upload the PDF to Moodle.
#
# Input:  students/groups_draw_2026-09-28.csv (frozen, from tools/assign_groups.R)
#         students/group_changes.csv (one row per change, appended by hand)
# Output: students/groups.csv (current groups, read by the PDF and email scripts)
#
# Columns of group_changes.csv:
#   date          day the change was recorded (ISO). Changes apply in this order
#   change        "drop" (student left the course) or "move" (changed group)
#   familienname, rufname, email   as in the draw (matched by email)
#   from_group    the student's group before the change
#   to_group      new group for a move, empty for a drop
#   note          free text: who reported it, how it was announced

draw_file <- "students/groups_draw_2026-09-28.csv"
changes_file <- "students/group_changes.csv"
groups_file <- "students/groups.csv"

groups <- read.csv(draw_file, colClasses = "character", fileEncoding = "UTF-8")
changes <- read.csv(changes_file, colClasses = "character", fileEncoding = "UTF-8",
                    na.strings = "")
changes <- changes[order(changes$date), ]
valid_groups <- unique(groups$group)

for (i in seq_len(nrow(changes))) {
  ch <- changes[i, ]
  who <- paste(ch$rufname, ch$familienname)
  row <- which(tolower(groups$email) == tolower(ch$email))
  if (length(row) != 1) stop(who, ": email not found once in the current list")
  if (groups$group[row] != ch$from_group) {
    stop(who, " is in group ", groups$group[row], ", not ", ch$from_group)
  }
  if (ch$change == "drop") {
    if (!is.na(ch$to_group)) stop(who, ": a drop must have an empty to_group")
    groups <- groups[-row, ]
  } else if (ch$change == "move") {
    if (!ch$to_group %in% valid_groups) stop(who, ": unknown to_group ", ch$to_group)
    groups$group[row] <- ch$to_group
  } else {
    stop(who, ": change must be drop or move, got ", ch$change)
  }
}

groups$group <- as.integer(groups$group)
groups <- groups[order(groups$group, groups$familienname, groups$rufname), ]
write.csv(groups, groups_file, row.names = FALSE, fileEncoding = "UTF-8")

cat("Applied", nrow(changes), "changes, wrote", groups_file, "with", nrow(groups), "students\n")
cat("Group sizes:\n")
print(table(group = groups$group))
