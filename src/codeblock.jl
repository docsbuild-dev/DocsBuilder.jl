"""
Fail if: starts with '"' or escaping `\\\\`

```jl
julia> split_codeblocktitle("1 \"2 3\" 4 ")
3-element Vector{String}:
 "1"
 "2 3"
 "4"
```
"""
function split_codeblocktitle(title::AbstractString)
	v = Vector{String}()
	if isempty(title)
		return v
	end
	inquote = false
	record = index = firstindex(title) # deepcopy
	prev = prevind(title, index)
	prevchar = '\0'
	while true
		ch = title[index]
		if ch == ' '
			if !inquote
				if record<=prev
					push!(v, title[record:prev])
				end
				record = nextind(title, index)
			end
		elseif ch == '"'
			if inquote
				inquote = false
			elseif prevchar == ' '
				inquote = true
				record = index
			end
		elseif ch == '\\'
			if inquote
				index = nextind(title, index)
			end
		end
		if index == lastindex(title)
			if record<=index
				push!(v, title[record:index])
			end
			break
		end
		prev = index
		prevchar = ch
		index = nextind(title, index)
	end
	for i in eachindex(v)
		if first(v[i], 1) == "\""
			v[i] = unescape_string(chop(v[i], head=1, tail=1))
		end
	end
	return v
end

# codeblock
# |- normal_codeblock
# |- special_codeblock
function codeblock_to_html(info::AbstractString, literal::AbstractString, pss::PagesSetting)
	langs = split_codeblocktitle(info)
	if isempty(langs)
		@warn "No codeblock type information given." literal
		return normal_codeblock_to_html("plain", literal)
	end
	langs[1] = replace(lowercase(langs[1]), '-' => '_')
	language = langs[1]
	sym = Symbol(language)
	return typed_codeblock_to_html(Val(sym), literal, pss, langs)
end

function normal_codeblock_to_html(language::AbstractString, str::AbstractString)
	code = html_nobr_safe(str)
	return "<div data-lang='$language'><div class='codeblock-header'></div><pre class='codeblock-body language-$language'><code>$code</code></pre></div><br />"
end

"Treats normal codeblocks as default."
function typed_codeblock_to_html(::Val, code::AbstractString, pss::PagesSetting, args)
	language = String(args[1])
	if language == "julia_repl"
		language = "julia-repl"
	end
	return normal_codeblock_to_html(language, code)
end

function typed_codeblock_to_html(::Val{:encoded}, content::AbstractString, pss::PagesSetting, args)
	return "<div class='encoded'>$(ify_md(content, pss, false))</div>"
end

function typed_codeblock_to_html(::Val{insert}, content::AbstractString, pss::PagesSetting, args)
	popfirst!(args)
	language = isempty(args) ? :html : Symbol(lowercase(popfirst!(args)))
	language::Symbol
	return literal_to_html(Val(language), content, pss, args)
end

literal_to_html(::Val{html}, content, _, _) = content
