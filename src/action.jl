function action(setting::Union{AbstractString, PagesSetting} = "DoctreeBuild.toml")
	build(".", "public", setting)
end
