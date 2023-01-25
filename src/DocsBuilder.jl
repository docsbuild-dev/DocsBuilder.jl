module DocsBuilder

# Tool Set
include("htmlmanage.jl")
include("tools.jl")

# Setting
include("setting.jl")
using TOML
include("load_setting.jl")

# Tree
include("doctree.jl")
include("treedeal.jl")

# File Dealing
include("filedeal.jl")
include("codeblock.jl")
include("tohtml.jl")
include("scripts.jl")

# User-friendly
include("action.jl")
include("template.jl")

end
