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

function rep(str::AbstractString)
	return replace(str, '`' => "\\`")
end
function generate_menu(tree::Doctree, pss::PagesSetting, ind::Int = 1)
	return "['',$(_generate_menu(tree, pss, ind))]"
end
function _generate_menu(tree::Doctree, pss::PagesSetting, ind::Int)
	str = ""
	for nid in tree.data[ind].children
		base = tree.data[nid]
		if !base.is_outlined
			break
		end
		if isa(base, FileBase)
			str *= "`$(rep(base.target))|$(rep(base.title))`,"
		else
			str *= "[`$(rep(base.name))|$(rep(base.title))`,$(_generate_menu(tree, pss, nid))],"
		end
	end
	return str
end
function build_info_script(tree::Doctree, pss::PagesSetting)
	open("$(pss.trace.target_root)$(pss.root_build.info_script)", "w") do io
		println(io, "const __lang=`$(rep(pss.meta.lang))`")
		println(io, "const buildmessage=`$(rep(pss.meta.buildmessage))`")
		println(io, "const page_foot=`$(rep(pss.page.foot))`")
		ms = pss.page.scripts
		println(io, "const menu=", generate_menu(tree, pss))
		println(io, "const configpaths=$(ms[:requirejs][:configpaths])")
		println(io, "const configshim=$(ms[:requirejs][:configshim])")
		println(io, "const hljs_languages=$(ms[:hljs_languages])")
		println(io, "const main_requirement=$(ms[:main_requirement])")
	end
end

function build_httpstatuspage(_::Doctree, pss::PagesSetting, code::Integer)
	path = pss.root_build.httpstatuspage[code]
	tarpage = joinpath(pss.target_root, path)
	str = ""
	if isfile(path)
		methods = settingof(path).methods
		if analyze
		else
		end
	else
		str = "Error (HTTP Status Code: $code)"
	end
end
