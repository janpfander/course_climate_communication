# Reads the course schedule from its single sources: the .session divs in
# syllabus.qmd and first_session in _variables.yml (same logic as the overview
# table in index.qmd). Sourced by tools/build_groups_pdf.R and by the email
# send scripts. Paths are relative to the project root.

# One row per session: session, date (dd.mm.yyyy), topic, lecturer, groups
# (the raw groups="1,2" attribute, NA for sessions without presentations).
read_schedule <- function(root = ".") {
  vars <- yaml::read_yaml(file.path(root, "_variables.yml"))
  lines <- readLines(file.path(root, "syllabus.qmd"), warn = FALSE)
  sess <- grep('\\{\\.session ', lines, value = TRUE)
  attr_of <- function(x, name) {
    ifelse(grepl(paste0(" ", name, '="'), x),
           sub(paste0('.*', name, '="([^"]*)".*'), "\\1", x),
           NA_character_)
  }
  n <- as.integer(attr_of(sess, "number"))
  computed <- format(as.Date(vars$course$first_session) + (n - 1) * 7, "%d.%m.%Y")
  date_override <- attr_of(sess, "date")
  data.frame(
    session = n,
    date = ifelse(is.na(date_override), computed, date_override),
    topic = attr_of(sess, "topic"),
    lecturer = attr_of(sess, "lecturer"),
    groups = attr_of(sess, "groups")
  )
}

# "1,2" -> "Groups 1 & 2", "3" -> "Group 3", NA -> "No presentations"
groups_label <- function(x) {
  vapply(x, function(g) {
    if (is.na(g)) return("No presentations")
    g <- trimws(strsplit(g, ",")[[1]])
    paste(if (length(g) > 1) "Groups" else "Group", paste(g, collapse = " & "))
  }, character(1), USE.NAMES = FALSE)
}

# One row per group: group, session, date, topic. Stops unless every group in
# `expected` presents in exactly one session.
presentation_dates <- function(schedule, expected) {
  s <- schedule[!is.na(schedule$groups), ]
  per_session <- strsplit(s$groups, ",")
  out <- data.frame(
    group = as.integer(trimws(unlist(per_session))),
    session = rep(s$session, lengths(per_session)),
    date = rep(s$date, lengths(per_session)),
    topic = rep(s$topic, lengths(per_session))
  )
  stopifnot(
    "a group is listed in more than one session" = !anyDuplicated(out$group),
    "groups in syllabus.qmd do not match the groups drawn" = setequal(out$group, expected)
  )
  out[order(out$group), ]
}
