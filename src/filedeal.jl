function filedeal(v::Val; fbase::FileBase, method::Symbol, pss::PagesSetting)
	if method == :default
		method = default_filedealmethod(v)
	end
	if method == :copy
		cp(pss.source_leafpath, pss.target_leafpath; force=true)
		fbase.need_wrap = false
		fbase.target = pss.fullname
		return
	end
	if method == :extra
		filedeal_extra(v; fbase = fbase, pss = pss)
		return
	end
	str = read(pss.source_leafpath, String)
	fbase.target = fbase.name*pss.filesuffix
	if method == :plain
		fbase.data = html_safe(str)
	elseif method == :insert
		fbase.data = str
	elseif method == :codeblock
		fbase.data = normal_codeblock_to_html(fbase.ext, str)
	else
		error("File dealing method \"$(method)\" is not supported.")
	end		
end

default_filedealmethod(::Val) = :copy
default_filedealmethod(::Val{:c}) = :codeblock
default_filedealmethod(::Val{:cpp}) = :codeblock
default_filedealmethod(::Val{:css}) = :copy
default_filedealmethod(::Val{:h}) = :codeblock
default_filedealmethod(::Val{:hpp}) = :codeblock
default_filedealmethod(::Val{:htm}) = :insert
default_filedealmethod(::Val{:html}) = :insert
default_filedealmethod(::Val{:jl}) = :codeblock
default_filedealmethod(::Val{:js}) = :copy
default_filedealmethod(::Val{:py}) = :codeblock
default_filedealmethod(::Val{:ts}) = :copy
default_filedealmethod(::Val{:txt}) = :plain
