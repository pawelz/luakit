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

local subscribe = [=[
	var b=document.body;
	var GR________bookmarklet_domain='http://www.google.com';
	if(b&&!document.xmlVersion) {
		void(z=document.createElement('script'));
		void(z.src='http://www.google.com/reader/ui/subscribe-bookmarklet.js');
		void(b.appendChild(z));
	} else {
		location='http://www.google.com/reader/view/feed/'+encodeURIComponent(location.href)
	}
]=]

add_cmds({

	lousy.bind.cmd("google_bookmark",
		function (w, c)
			local encuri = luakit.uri_encode(w:get_current().uri)
			local encdes = luakit.uri_encode(w:eval_js(getdesc, "google.lua"))
			local enctit = luakit.uri_encode(w.win.title)
			w:new_tab("https://www.google.com/bookmarks/api/bookmarklet?output=popup&srcUrl="..encuri.."&snippet="..encdes.."&title="..enctit, false)
		end),

	lousy.bind.cmd("google_subscribe",
		function (w, c)
			w:eval_js(subscribe)
		end),

})
