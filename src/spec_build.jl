function build_index(tree::Doctree, pss::PagesSetting; path::String, pathl::Int)
	bd = ps.pages.build_index
	to_wrap = "<ul>"
	tb = self(tree)
	for nid in tb.children
		base = tree.data[nid]
		if isa(base, FileBase)
			to_wrap *= "<li class='item file-item'><a href='$(base.target)'>$(base.title)</a></li>"
		else
			to_wrap *= "<li class='item directory-item'><a href='$(base.name)/$(bd)'>$(base.title)</a></li>"
		end
	end
	to_wrap *= "</ul>"
	title = (isroot(tb) ? language_pack(pss, "^main+") : tb.title) * language_pack(pss, "^index")
	ps = PageSetting(
		description = "$(title) - $(pss.project.title)",
		editpath = editpath(pss, path),
		insert = to_wrap,
		navbar_title = title,
		nextpage = "",
		prevpage = isroot(tb) ?
			"" :
			"<a class='docs-footer-prevpage' href='../$(bd)'>« $(language_pack(pss, "^parent-index"))</a>",
		tURL = "../"^pathl
	)
	html = build_wrapping_html(pss, ps)
	write(pss.trace.target_path*bd, html)
end
