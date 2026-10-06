# The Psychology of Climate Change Communication

Course website for *The Psychology of Climate Change Communication: theoretical
insights and practical applications*, a course taught at ETH Zurich in
Autumn 2026 by [Viktoria Cologna](https://www.viktoriacologna.com/) and
[Jan Pfänder](https://janpfander.github.io/).

The website is live at
<https://janpfander.github.io/course_climate_communication/>.

## About the course

Climate change communication influences how individuals, organizations, and
societies perceive climate change, and how they react to it. The course draws
on research from environmental psychology and communication science to
understand how people respond to climate change messages and what makes
communication effective. Lectures by the instructors alternate with talks by
invited guest speakers, including practitioners from a federal office, an NGO,
and journalism.

Students work in groups to evaluate a real example of climate change
communication and propose evidence-informed improvements. The course is
pass/fail, based on an oral group presentation and an individual written
reflection. Full details, session descriptions, and readings are in the
[syllabus](https://janpfander.github.io/course_climate_communication/syllabus.html),
which is also available as PDF and Word document on the website.

## What is on the website

- **Home** — course description, session overview table, and a calendar feed
  (subscribe or download `.ics`) with all sessions.
- **Syllabus** — learning objectives, organisational information, assessment
  guidelines, and the session-by-session schedule with assigned readings.
- **Course evaluation** — the assessment guidelines as a standalone document.
- **Slides and materials** — posted throughout the semester as sessions take
  place.

## Repository structure

The site is built with [Quarto](https://quarto.org/) and published from
`docs/` via GitHub Pages.

| Path | Purpose |
|---|---|
| `index.qmd` | Homepage: description, session overview table, calendar feed |
| `syllabus.qmd` | Syllabus: rendered to HTML, PDF, and docx |
| `evaluation.qmd` | Standalone course evaluation guidelines (for Moodle), rendered to HTML, PDF, and docx |
| `_variables.yml` | Course facts used across pages: instructors, room, times, dates, deadlines |
| `_quarto.yml` | Site configuration and navigation |
| `_brand.yml` | Brand colors and logo |
| `references.bib` | Bibliography |
| `_includes/` | Text shared by the syllabus and the evaluation document via `{{< include >}}`: `header.md` (logos, instructors) and `assessment.md` |
| `assets/` | `styles.css` and `theme-dark.scss` (styling, light and dark theme), `apa-cv.csl` (citation style that prints full references inline), `course-structure.lua` (Pandoc filter that turns the session blocks in `syllabus.qmd` into the course structure table), `slides/` (theme and title slide of the Quarto decks) |
| `tools/` | Scripts for the group assignment and the group list PDF, citation whitelist |
| `slides/` | Lecture slides: Quarto revealjs decks (`NN-slides.qmd`) and PDFs (`NN-slides.pdf`). PowerPoint sources (`NN-slides.pptx`) are kept here but gitignored |
| `images/` | Logos |
| `docs/` | Rendered site, served by GitHub Pages |

Four more folders exist only on the instructors' machines and are gitignored:
`notes/`, `resources/`, `emails/`, and `students/`.

## License

Content is licensed under
[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/).

## Using this repository as a template

The notes below describe how the site is maintained. They are only relevant if
you want to reuse this repository for your own course.

### Schedule and calendar feed

The schedule has one source of truth: the `.session` divs in `syllabus.qmd`.
Everything else is derived at render time:

- Session dates = `first_session` in `_variables.yml` + 7 days per session
  (add `date="dd.mm.yyyy"` to a session div only to override a single moved class).
- The overview table on the homepage (`index.qmd`) is read from those divs.
- The calendar feed `course-sessions.ics` is written by the `write-ics` chunk in
  `index.qmd`, copied to `docs/`, and served at
  `https://janpfander.github.io/course_climate_communication/course-sessions.ics`.
  Each render stamps the current time (`DTSTAMP`, `LAST-MODIFIED`) and a
  `SEQUENCE` based on the git history of `syllabus.qmd` and `_variables.yml`, so
  subscribed calendars pick up changes.

Workflow after any change to sessions, times, or room:

1. Edit `syllabus.qmd` (sessions) or `_variables.yml` (weekday, times, room, first session).
2. `quarto render`
3. Commit `syllabus.qmd` and `docs/` (the root `course-sessions.ics` is gitignored, only the `docs/` copy is served), then push.
   Subscribers see the change on their client's next refresh (typically within a day).
   People who downloaded the `.ics` file once will not get updates.

### Group presentations

Which groups present in which session is set on the session divs in
`syllabus.qmd` with a `groups` attribute, e.g. `groups="1,2"`. Sessions without
the attribute show "No presentations". The homepage table and the calendar feed
read it at render time. If two groups swap dates, change the attribute, then
`quarto render` and rebuild the PDF.

Student data never enters the repository. The roster, the group lists, and the
PDF with names live in `students/`, which is gitignored. The random draw is
frozen once announced. Later changes (a student drops the course or moves to
another group) are recorded as one row each in `students/group_changes.csv`
and applied by a script, so the current list can always be rebuilt from the
draw plus the change log.

| Script | Purpose |
|---|---|
| `tools/assign_groups.R` | Random draw of the groups from the roster, writes `students/groups_draw_<date>.csv`. Runs once and stops if the file exists |
| `tools/update_groups.R` | Applies `students/group_changes.csv` to the frozen draw and writes the current list `students/groups.csv`. Run after every new row in the change log |
| `tools/build_groups_pdf.R` | Builds `students/Group_assignment_and_presentation_schedule.pdf` (schedule and names per group, with a version date) for Moodle. Renders in a temporary directory outside the website project |
| `tools/schedule.R` | Reads the schedule from `syllabus.qmd` and `_variables.yml`, sourced by the PDF script and the email scripts |

### Slides

Decks live flat in `slides/`, keyed by the two-digit session number:

| File | Git | Published as |
|---|---|---|
| `slides/NN-slides.qmd` (Quarto revealjs) | committed | `docs/slides/NN-slides.html` |
| `slides/NN-slides.pdf` | committed | `docs/slides/NN-slides.pdf` (copied via `resources` in `_quarto.yml`) |
| `slides/NN-slides.pptx` | ignored (`*.pptx` in `.gitignore`) | never |

The schedule table on the homepage looks for these files at render time and
shows an HTML and/or PDF button per session. `slides/_template-slides.qmd` is
the starting point for a new Quarto deck (files starting with `_` are not
rendered).

All Quarto decks share `slides/_metadata.yml` (authors, bibliography, reveal.js
options) and the theme in `assets/slides/`: `theme.scss` (website colors from
`_brand.yml`) and `title-slide.html` (title slide with the Eawag logo top
right and the large course logo, the only slide that carries logos). A deck
itself only sets `title` and `subtitle`.

- **Quarto deck:** copy the template to `slides/NN-slides.qmd` and
  `quarto render`. Then print the deck to PDF by hand (works in Firefox and
  Chrome, see the [Quarto docs](https://quarto.org/docs/presentations/revealjs/presenting.html#print-to-pdf)):
  open `docs/slides/NN-slides.html`, press `E` for print view, open the print
  dialog, choose *Save as PDF*, landscape, no margins, background graphics on,
  and save as `slides/NN-slides.pdf`. Render again so the PDF is copied to
  `docs/slides/`. Commit the `.qmd`, the `.pdf`, and `docs/`.
- **PowerPoint deck:** save `slides/NN-slides.pptx` and export
  `slides/NN-slides.pdf` from PowerPoint, then `quarto render` and commit the
  `.pdf` and `docs/`.

### Course facts

Instructor names, contact details, room, weekday, times, and deadlines live in
`_variables.yml` and are inserted into the pages with `{{< var ... >}}`. Change
them there rather than in the pages.
