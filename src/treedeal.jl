function build(source_root::AbstractString, target_root::AbstractString, fpath::AbstractString = "DoctreeBuild.toml")
	pss = load_setting(fpath)
	@info "Setting" pss
	generate(source_root, target_root, pss)
end

function build(source_root::AbstractString, target_root::AbstractString, pss::PagesSetting)
	@assert isdir(source_root)
	if pss.remove_original
		rm(target_root; force=true, recursive=true)
	end
	pss.trace.source_root = source_root = expand_slash(abspath(source_root))
	pss.trace.target_root = target_root = expand_slash(abspath(target_root))
	tree = Doctree("root")
	root_folder = pss.root_folder
	docs = root_folder.docs = remove_slash(pss.root_folder.docs)
	cd(source_root*docs) do
		queue = [(true, 1, ".")]
		while !isempty(queue)
			omode, num, dirname = popfirst!(queue)
			tree.current = num
			cd(dirname) do
				preprocess_build(tree, pss; outlined = omode, path = "", queue = queue)
			end
		end
	end
	cd(source_root*docs) do
		queue = [(1, "", 0)]
		while !isempty(queue)
			nid, path, pathl = popfirst!(queue)
			tree.current = nid
			process_build(tree, pss; path = path, pathl = pathl, queue = queue)
		end
	end
	cd(srcdir) do
		for (k, v) in root_folder.copies
			isdir(k) && cp(k, joinpath(target_root, v); force=true)
		end
	end
	build_mainpage(tree, pss)
	build_404(tree, pss)
	build_main_script(tree, pss)
	build_info_script(tree, pss)
end

function preprocess_build(tree::Doctree, pss::PagesSetting; outlined::Bool, path::String, queue)
	trace = pss.trace
	trace.path = path
	trace.source_path = trace.source_root*pss.root_folder.docs*path
	tpath = trace.target_path = trace.target_root*"docs/"*path
	mkpath(tpath)
	toml = get(pss.tree, path, Dict())
	tb = self(tree)
	tb.setting = toml
	# get <outline> and <unoutlined>
	if haskey(toml, "noignore")
		unoutlined = sort(toml["noignore"])
	else
		unoutlined = readdir("."; sort = true)
		for fullname in get(toml, "ignore", nothing)
			find = searchsortedfirst(unoutlined, fullname)
			iszero(find) || deleteat!(unoutlined, find)
		end
	end
	outline = outlined ? get(toml, "outline", [])::Vector : []
	for fullname in outline
		find = searchsortedfirst(unoutlined, fullname)
		iszero(find) && error("required item $fullname in outline does not exist")
		deleteat!(unoutlined, find)
	end
	num = Base.length(tree.data)
	i = 1
	len1 = Base.length(outline)
	len2 = Base.length(unoutlined)
	len = len1 + len2
	tb.children = num+1:num+len
	ts = get(toml, "titles", Dict())::Dict
	methods = get(toml, "methods", Dict())::Dict
	for i in 1:len
		omode = i<=len1
		@inbounds fullname = omode ? outline[i] : unoutlined[i-len1]
		if isfile(fullname)
			name, ext = splitext2(fullname)
			title = get(ts, fullname, "")
			fbase = FileBase(omode, true, tree.current, name, ext, title, "", "")
			method = Symbol(get(methods, fullname, :default))
			trace.leafname = fullname
			filedeal(Val(Symbol(suf)); fbase = fbase, method = method, pss = pss)
			if fbase.title == ""
				fbase.title = name
			end
			push!(tree.data, fbase)
		else
			title = get(ts, fullname, fullname)
			dbase = DirBase(omode, tree.current, fullname, title, nothing, Dict())
			push!(tree.data, dbase)
			push!(queue, (omode, num+i, fullname))
		end
	end
end

function process_build(tree::Doctree, pss::PagesSetting; path::String, pathl::Int, queue)
	trace = pss.trace
	tpath = trace.target_path = trace.target_root*"docs/"*path
	tb = self(tree)
	toml = tb.setting
	vec = get(toml, "outline", [])
	vec::Vector
	len = length(vec)
	prevpages = get(toml, "prevpages", Dict())
	nextpages = get(toml, "nextpages", Dict())
	for nid in tb.children
		base = tree.data[nid]
		if isa(base, DirBase)
			push!(queue, (nid, path*base.name, pathl))
			continue
		end
		base::FileBase
		base.need_wrap || continue
		fullname = fullname(base)
		prevpage = ""
		nextpage = ""
		pmark = haskey(prevpages, fullname)
		nmark = haskey(nextpages, fullname)
		if pmark
			th = prevpages[fullname]
			prevpage = isempty(th) ? "" : get_pagestr(tree, pss, th, true)
		end
		if nmark
			th = nextpages[fullname]
			nextpage = isempty(th) ? "" : get_pagestr(tree, pss, th, false)
		end
		outline_index = first_invec(fullname, vec)
		if iszero(outline_index)
			if !pmark
				prevpage = """<a class="docs-footer-prevpage" href="$(pss.pages.build_index)">« $(language_pack(pss, "^index"))</a>"""
			end
		else
			i = outline_index
			if !pmark
				if i==1
					prevnid = prev_outlined(tree, nid)
					prevpage = iszero(prevnid) ?
						"""<a class="docs-footer-prevpage" href="$(pss.pages.build_index)">« $(language_pack(pss, "^index"))</a>""" :
						get_pagestr(tree, pss, prevnid, true, simple_href=false)
				else
					prevpage = get_pagestr(tree, pss, @inbounds(vec[i-1]), true)
				end
			end
			if !nmark
				if i==len
					nextnid = next_outlined(tree, nid)
					nextpage = iszero(nextnid) ?
						"" :
						get_pagestr(tree, pss, nextnid, false, simple_href=false)
				else
					nextpage = get_pagestr(tree, pss, @inbounds(vec[i+1]), false)
				end
			end
		end
		title = base.title
		protitle = pss.project.title
		description = isroot(tb) ? "$title - $(protitle)" : "$(tb.title)/$(title) - $(protitle)"
		navtext = isroot(tb) ? title : "$(tb.title) / $(title)"
		ps = PageSetting(
			description = description,
			editpath = editpath(pss, path),
			insert = base.data,
			navbar_title = navtext,
			nextpage = nextpage,
			prevpage = prevpage,
			tURL = "../"^pathl
		)
		html = build_wrapping_html(pss, ps)
		write(tpath*base.target, html)
	end
	build_index(tree, pss; path = path, pathl = pathl)
end
