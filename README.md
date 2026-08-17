# The Psychology of Climate Change Communication — course website

Quarto website, published from `docs/` via GitHub Pages.

## Updating the schedule (and the calendar feed)

The schedule has one source of truth: the `.session` divs in `syllabus.qmd`.
Everything else is derived at render time:

- Session dates = `first_session` in `_variables.yml` + 7 days per session
  (add `date="dd.mm.yyyy"` to a session div only to override a single moved class).
- The overview table on the homepage (`index.qmd`) is read from those divs.
- The calendar feed `course-sessions.ics` is written by the `write-ics` chunk in
  `index.qmd`, copied to `docs/`, and served at
  `https://janpfander.github.io/course_climate_communication/course-sessions.ics`.
  Each render stamps the current time (`DTSTAMP`, `LAST-MODIFIED`) and a
  `SEQUENCE` based on the git history of `syllabus.qmd`, so subscribed calendars
  pick up changes.

Workflow after any change to sessions, times, or room:

1. Edit `syllabus.qmd` (sessions) or `_variables.yml` (weekday, times, room, first session).
2. `quarto render`
3. Commit `syllabus.qmd` and `docs/` (the root `course-sessions.ics` is gitignored, only the `docs/` copy is served), then push.
   Subscribers see the change on their client's next refresh (typically within a day).
   People who downloaded the `.ics` file once will not get updates.
