function expand_slash(str)
	ch = str[end]
	return (ch == '/' || ch == '\\') ? str : str*'/'
end

function spitext2(fullname)
	dot = findlast('.', fullname)
	isnothing(dot) && return (fullname, "")
	@inbounds (fullname[1:prevind(fullname, dot)], fullname[dot+1:end])
end
