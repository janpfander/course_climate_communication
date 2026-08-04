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

-- Session dates are computed: first_session (from _variables.yml) + 7 days per
-- session. A session div can still set date="dd.mm.yyyy" to override (e.g. a
-- moved class).
local function first_session_time()
  local f = io.open("_variables.yml", "r")
  if not f then return nil end
  local y, m, d
  for line in f:lines() do
    y, m, d = line:match('first_session:%s*"?(%d%d%d%d)%-(%d%d)%-(%d%d)')
    if y then break end
  end
  f:close()
  if y then
    -- noon avoids any daylight-saving edge cases in the day arithmetic
    return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
  end
end

local function session_date(a)
  if a.date and a.date ~= "" then return a.date end
  local t0 = first_session_time()
  local n = tonumber(a.number)
  if not (t0 and n) then return a.date or "" end
  return os.date("%d.%m.%Y", t0 + (n - 1) * 7 * 86400)
end

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
        { pandoc.Plain { pandoc.Str(session_date(a)) } },
        topic,
        lit,
      })
    end
  end

  local st = pandoc.SimpleTable(pandoc.Inlines {}, aligns, widths, headers, rows)
  return pandoc.utils.from_simple_table(st)
end
