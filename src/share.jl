function build_shared(tree::Doctree, pss::PagesSetting, ind)
	tb = tree.data[1]
	tb::FileBase
	ps = PageSetting(
		description = "$(tb.title) - $(pss.project.title)",
		editpath = editpath(pss, path),
		insert = tb.data,
		navbar_title = tb.title,
		nextpage = "",
		prevpage = "",
		tURL = "./"
	)
	html = build_wrapping_html(pss, ps)
	write(pss.trace.target_leafpath, html)
end
