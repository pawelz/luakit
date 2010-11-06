local getdesc = [=[
	(function() {
		var mes=document.getElementsByTagName("meta");
		for(var i=0,me; me=mes[i]; i++) {
			mea=me.getAttribute("name");
			if(mea && mea.toUpperCase() == "DESCRIPTION") {
				return me.getAttribute("content");
			}
		}
		return "";
	})()
]=]

add_cmds({
	lousy.bind.cmd("google_bookmark",
		function (w, c)
			local encuri = luakit.uri_encode(w:get_current().uri)
		    local encdes = luakit.uri_encode(w:eval_js(getdesc, "google.lua"))
		    local enctit = luakit.uri_encode(w.win.title)
		    w:new_tab("https://www.google.com/bookmarks/api/bookmarklet?output=popup&srcUrl="..encuri.."&snippet="..encdes.."&title="..enctit, false)
		end),
})
