function load_setting(fpath::AbstractString)
	toml = TOML.parse(fpath)
	# if haskey(toml, "version") && !(DTP_VERSION in Pkg.Types.semver_spec(toml["version"]))
	#     error("version does not meet setting ($(toml["version"]))")
	# end
	extensions = toml["extensions"]
	extensions::Vector
	pss = PagesSetting(SettingFrame(default_pagessettingframe))
end
