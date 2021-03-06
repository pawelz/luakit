---------------------------------------------------------------------------
-- @author Henning Hasemann &lt;hhasemann@web.de&gt;
-- @author Mason Larobina &lt;mason.larobina@gmail.com&gt;
---------------------------------------------------------------------------

-- Grab environment we need
local table = table
local string = string
local io = io
local os = os
local unpack = unpack
local type = type
local pairs = pairs
local ipairs = ipairs
local util = require("lousy.util")
local capi = { luakit = luakit }

-- Bookmark functions that operate on a flatfile and output to html
module("bookmarks")

-- Loaded bookmarks
local data = {}

-- Some default settings
bookmarks_file = capi.luakit.data_dir .. '/bookmarks'
html_out       = capi.luakit.cache_dir  .. '/bookmarks.html'

-- Templates
block_template = [==[<div class="tag"><h1>{tag}</h1><ul>{links}</ul></div>]==]
link_template  = [==[<li><a href="{uri}">{name}</a></li>]==]

html_template = [==[
<html>
<head>
    <title>{title}</title>
    <style type="text/css">
    {style}
    </style>
</head>
<body>
{tags}
</body>
</html>
]==]

-- Template subs
html_page_title = "Bookmarks"

html_style = [===[
    body {
        font-family: monospace;
        margin: 25px;
        line-height: 1.5em;
        font-size: 12pt;
    }
    div.tag {
        width: 100%;
        padding: 0px;
        margin: 0 0 25px 0;
    }
    .tag ul {
        padding: 0;
        margin: 0;
        list-style-type: none;
    }
    .tag h1 {
        font-size: 12pt;
        font-weight: bold;
        font-style: normal;
        font-variant: small-caps;
        padding: 0 0 5px 0;
        margin: 0;
        color: #333333;
        border-bottom: 1px solid #aaa;
    }
    .tag a:link {
        color: #0077bb;
        text-decoration: none;
    }
    .tag a:hover {
        color: #0077bb;
        text-decoration: underline;
    }
]===]

--- Clear in-memory bookmarks
function clear()
    data = {}
end

--- Save the in-memory bookmarks to flatfile.
-- @param file The destination file or the default location if nil.
function save(file)
    if not file then file = bookmarks_file end

    local lines = {}
    for _, bm in pairs(data) do
        local subs = { uri = bm.uri, tags = table.concat(bm.tags or {}, " "), }
        local line = string.gsub("{uri}\t{tags}", "{(%w+)}", subs)
        table.insert(lines, line)
    end

    -- Write table to disk
    local fh = io.open(file, "w")
    fh:write(table.concat(lines, "\n"))
    io.close(fh)
end

--- Add a bookmark to the in-memory bookmarks table
function add(uri, tags, replace, save_bookmarks)
    if not uri then return error("must supply uri") end
    if not tags then tags = {} end

    -- Create tags table from string
    if type(tags) == "string" then tags = util.string.split(tags) end

    if not replace and data[uri] then
        local bm = data[uri]
        -- Merge tags
        for _, tag in ipairs(tags) do
            if not util.table.hasitem(bm, tag) then table.insert(bm, tag) end
        end
    else
        -- Insert new bookmark
        data[uri] = { uri = uri, tags = tags }
    end

    -- Save by default
    if save_bookmarks ~= false then save() end
end


--- Load bookmarks from a flatfile to memory.
-- @param file The bookmarks file or the default bookmarks location if nil.
-- @param clear_first Should the bookmarks in memory be dumped before loading.
function load(file, clear_first)
    if clear_first then clear() end

    -- Find a bookmarks file
    if not file then file = bookmarks_file end
    if not os.exists(file) then return end

    -- Read lines into bookmarks data table
    local fh = io.lines(file or bookmarks_file, "r")
    for line in fh do
        local uri, tags = unpack(util.string.split(line, "\t"))
        if uri ~= "" then add(uri, tags, false, false) end
    end
end

function dump_html(file)
    if not file then file = html_out end

    -- Get a list of all the unique tags in all the bookmarks and build a
    -- relation between a given tag and a list of bookmarks with that tag.
    local tags = {}
    for _, bm in pairs(data) do
        for _, t in ipairs(bm.tags) do
            if not tags[t] then tags[t] = {} end
            tags[t][bm.uri] = bm
        end
    end

    -- For each tag build
    local lines = {}
    for _, tag in ipairs(util.table.keys(tags)) do
        local links = {}
        for _, uri in ipairs(util.table.keys(tags[tag])) do
            local bm = tags[tag][uri]
            local link_subs = {
                uri = bm.uri,
                name = util.escape(bm.uri),
            }
            local link = string.gsub(link_template, "{(%w+)}", link_subs)
            table.insert(links, link)
        end

        local block_subs = {
            tag   = tag,
            links = table.concat(links, "\n")
        }
        local block = string.gsub(block_template, "{(%w+)}", block_subs)
        table.insert(lines, block)
    end

    local html_subs = {
        tags  = table.concat(lines, "\n\n"),
        title = html_page_title,
        style = html_style
    }
    local html = string.gsub(html_template, "{(%w+)}", html_subs)
    local fh = io.open(file, "w")
    fh:write(html)
    io.close(fh)

    -- Return path to file
    return "file://"..file
end
