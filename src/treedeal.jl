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
	docs = pss.root_folder.docs
	cd(source_root*docs) do
		scan_rec(tree, pss; outlined = true, path = "$(docs)/", pathv = [docs])
	end
end

function scan_rec(tree::Doctree, pss::PagesSetting; outlined::Bool, path::String, pathv::Vector{String})
	trace = pss.trace
	trace.path = path
	trace.source_path = trace.source_root*path
	tpath = trace.target_path = trace.target_root*path
	mkpath(tpath)
	toml = get(pss.tree, ";", Dict())
	tb = self(tree)
	tb.setting = toml
	# get <outline> and <unoutlined>
	unoutlined = readdir("."; sort = true)
	for fullname in get(toml, "ignore", nothing)
		deleteat!(unoutlined, searchsortedfirst(unoutlined, fullname))
	end
	outline = outlined ? get(toml, "outline", [])::Vector : []
	for fullname in outline
		deleteat!(unoutlined, searchsortedfirst(unoutlined, fullname))
	end
	num = Base.length(tree.data)
	i = 1
	len1 = Base.length(outline)
	len2 = Base.length(unoutlined)
	len = len1 + len2
	tb.children = num+1:num+len
	ts = get(toml, "titles", Dict())::Dict
	saved_rec = Tuple{Int, String, Bool}[]
	methods = get(toml, "methods", Dict())::Dict
	for i in 1:len
		omode = i<=len1
		@inbounds fullname = omode ? outline[i] : unoutlined[i-len1]
		if isfile(fullname)
			name, ext = splitext2(fullname)
			title = get(ts, fullname, "")
			fbase = FileBase(omode, false, tree.current, name, ext, title, "", "")
			method = Symbol(get(methods, fullname, :default))
			pss.trace.leafname = fullname
			filedeal(Val(Symbol(suf)); fbase = fbase, method = method, pss = pss)
			if fbase.title == ""
				fbase.title = name
			end
			push!(tree.data, fbase)
		else
			title = get(ts, fullname, fullname)
			dbase = DirBase(omode, tree.current, fullname, title, nothing, Dict())
			push!(tree.data, dbase)
			push!(saved_rec, (num+i, fullname, omode))
		end
	end
	for (num, dirname, omode) in saved_rec
		push!(pathv, dirname)
		tree.current = num
		cd(dirname)
		scan_rec(tree, pss; outlined = omode, path = "$(path)$(dirname)/", pathv = pathv)
		pop!(pathv)
		backtoparent!(tree)
		cd("..")
	end
end
