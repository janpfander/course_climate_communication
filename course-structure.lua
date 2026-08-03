-- Builds the Course Structure table from .session divs inside a
-- .course-structure div. Sessions are authored as plain markdown in the qmd so
-- citation keys autocomplete in Positron and pass through citeproc, while the
-- output is still a real table (longtable in PDF, so it paginates).
--
-- Authoring format:
--   ::::: {.course-structure}
--   :::: {.session number="1" date="15.09.2026" lecturer="..." topic="..."}
--   Description paragraphs (become the Topic cell, under a bold topic line).
--   ::: {.literature}
--   Literature paragraphs / citations (become the Literature cell).
--   :::
--   ::::
--   :::::

function Div(div)
  if not div.classes:includes("course-structure") then
    return nil
  end

  local headers = {
    { pandoc.Plain { pandoc.Str "#" } },
    { pandoc.Plain { pandoc.Str "Date" } },
    { pandoc.Plain { pandoc.Str "Topic" } },
    { pandoc.Plain { pandoc.Str "Literature" } },
  }
  local aligns = { pandoc.AlignDefault, pandoc.AlignDefault,
                   pandoc.AlignDefault, pandoc.AlignDefault }
  local widths = { 0.05, 0.12, 0.45, 0.38 }
  local rows = {}

  for _, b in ipairs(div.content) do
    if b.t == "Div" and b.classes:includes("session") then
      local a = b.attributes
      local topic = {}
      local lit = {}

      local title = pandoc.Inlines { pandoc.Strong { pandoc.Str(a.topic or "") } }
      if a.lecturer and a.lecturer ~= "" then
        title:insert(pandoc.Str(" — " .. a.lecturer))
      end
      table.insert(topic, pandoc.Para(title))

      for _, sb in ipairs(b.content) do
        if sb.t == "Div" and sb.classes:includes("literature") then
          for _, lb in ipairs(sb.content) do
            table.insert(lit, lb)
          end
        else
          table.insert(topic, sb)
        end
      end

      table.insert(rows, {
        { pandoc.Plain { pandoc.Str(a.number or "") } },
        { pandoc.Plain { pandoc.Str(a.date or "") } },
        topic,
        lit,
      })
    end
  end

  local st = pandoc.SimpleTable(pandoc.Inlines {}, aligns, widths, headers, rows)
  return pandoc.utils.from_simple_table(st)
end
