-- Luakit configuration file, more information at http://luakit.org/

-- Load library of useful functions for luakit
require "lousy"

-- Small util function to print output only when luakit.verbose is true
function info(...) if luakit.verbose then print(string.format(...)) end end

-- Load users global config
-- ("$XDG_CONFIG_HOME/luakit/globals.lua" or "/etc/xdg/luakit/globals.lua")
require "globals"

search_engines["wikipedia_pl"]="http://en.wikipedia.org/wiki/Special:Search?search={0}"

-- Load users theme
-- ("$XDG_CONFIG_HOME/luakit/theme.lua" or "/etc/xdg/luakit/theme.lua")
lousy.theme.init(lousy.util.find_config("theme.lua"))
theme = assert(lousy.theme.get(), "failed to load theme")

-- Load users window class
-- ("$XDG_CONFIG_HOME/luakit/window.lua" or "/etc/xdg/luakit/window.lua")
require "window"

-- Load users mode configuration
-- ("$XDG_CONFIG_HOME/luakit/modes.lua" or "/etc/xdg/luakit/modes.lua")
require "modes"

-- Load users webview class
-- ("$XDG_CONFIG_HOME/luakit/webview.lua" or "/etc/xdg/luakit/webview.lua")
require "webview"

-- Load users keybindings
-- ("$XDG_CONFIG_HOME/luakit/binds.lua" or "/etc/xdg/luakit/binds.lua")
require "binds"

table.insert( binds.mode_binds['normal'], lousy.bind.buf("^gg$",                    function (w, c) w:enter_cmd(":websearch google ") end))
table.insert( binds.mode_binds['normal'], lousy.bind.buf("^we$",                    function (w, c) w:enter_cmd(":websearch wikipedia ") end))
table.insert( binds.mode_binds['normal'], lousy.bind.buf("^wp$",                    function (w, c) w:enter_cmd(":websearch wikipedia_pl ") end))
table.insert( binds.commands, lousy.bind.cmd({"rsget",       "dr"},                 function (w, c) w:eval_js_from_file(lousy.util.find_data("scripts/rsget.js")) end))
table.insert( binds.commands, lousy.bind.cmd({"test"},                              function (w, c) w:eval_js_from_file(lousy.util.find_data("tests/test.js")) end))
table.insert( binds.commands, lousy.bind.cmd({"print"},                             function (w, c) w:eval_js("print()", "rc.lua") end))

-- Init scripts
require "follow"
require "formfiller"
require "go_input"
require "follow_selected"
require "go_next_prev"
require "go_up"

-- Init bookmarks lib
require "bookmarks"
bookmarks.load()
bookmarks.dump_html()

window.new(uris)

-- vim: et:sw=4:ts=8:sts=4:tw=80
