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
	docs = pss.root_folder.docs = remove_slash(pss.root_folder.docs)
	cd(source_root*docs) do
		queue = [true, 1, "."]
		while !isempty(queue)
			omode, num, dirname = popfirst!(queue)
			tree.current = num
			cd(dirname) do
				preprocess_build(tree, pss; outlined = omode, path = "", queue = queue)
			end
		end
	end
	cd(source_root*docs) do
		wrap_rec(tree, pss; path = "", pathv = [])
	end
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
	unoutlined = readdir("."; sort = true)
	for fullname in get(toml, "ignore", nothing)
		find = searchsortedfirst(unoutlined, fullname)
		iszero(find) || deleteat!(unoutlined, find)
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
			push!(queue, (omode, num+i, fullname))
		end
	end
end
