function template(;github_workflow::Bool = true, print_help::Bool = true)
	mkpath("docs")
	mkpath("assets")
	write("DoctreeBuild.toml", "[pages]")
	if github_workflow
        mkpath(".github/workflows")
        write(".github/workflows/builddocs.yml", "")
    end
    if print_help
        @info "Remember to fill in DoctreeBuild.toml"
    end
end
