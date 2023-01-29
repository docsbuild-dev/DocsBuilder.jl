function expand_slash(str)
	ch = str[end]
	return (ch == '/' || ch == '\\') ? str : str*'/'
end
function remove_slash(str)
	lastind = thisind(str, sizeof(str))
	@inbounds ch = str[lastind]
	return (ch == '/' || ch == '\\') ? str[1:prevind(str, lastind)] : str
end

function first_invec(x, vec::Vector)
	i = 0
	for (j, val) in enumerate(vec)
		if val == x
			i = j
			break
		end
	end
	return i
end

function spitext2(fullname)
	dot = findlast('.', fullname)
	isnothing(dot) && return (fullname, "")
	@inbounds (fullname[1:prevind(fullname, dot)], fullname[dot+1:end])
end

function get_pagestr(tree, pss, nid::Int, is_prev; simple_href::Bool = true)
	tb = tree.data[nid]
	href = get_href(tree, nid; build_index = pss.pages.build_index, simple = simple_href)
	arrow = is_prev ? "« $(tb.title)" : "$(tb.title) »"
	return "<a class='docs-footer-$(is_prev ? "prev" : "next")page' href='$(href)'>$(arrow)</a>"
end
function get_pagestr(tree, pss, fullname::String, is_prev)
	nid = findchild(tree, tree.current, fullname)
	if nid == 0
		@info tree
		error("Check (setting) prev/nextpages: no item matches <$fullname>")
	end
	return get_pagestr(tree, pss, nid, is_prev)
end
