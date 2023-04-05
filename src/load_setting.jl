function load_setting(fpath::AbstractString)
	toml = TOML.parsefile(fpath)
	# if haskey(toml, "version") && !(DTP_VERSION in Pkg.Types.semver_spec(toml["version"]))
	#     error("version does not meet setting ($(toml["version"]))")
	# end
	extensions = get(toml, "extensions", [])
	extensions::Vector
	pss = PagesSetting(SettingFrame(default_pagessettingframe))
	pss.tree = toml["tree"]
	for (key, value) in toml["tree"]
		pss.tree[normpath(key)] = value
	end
	pss
end

function settingof(tree, path::AbstractString)
	tree[normpath(path)]
end

function language_pack(pss, key)
	lang = pss.meta.lang
	endswith(key, '+')
end
