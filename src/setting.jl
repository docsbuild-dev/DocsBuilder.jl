struct CallCell
    f
end
mutable struct SettingFrame
    fields::Dict{Symbol, Any}
end
function Base.getproperty(sf::SettingFrame, key::Symbol)
    fs = getfield(sf, :fields)
    x = get(fs, key, nothing)
    isa(x, CallCell) || x = x(sf)
    return x
end
function Base.setproperty!(sf::SettingFrame, key::Symbol, x)
    getfield(sf, :fields)[key] = x
end
sframe(pairs::Pair...) = SettingFrame(Dict(pairs...))
Base.getproperty(::Nothing, _) = nothing
Base.setproperty!(::Nothing, _, _) = nothing

mutable struct PagesSetting
    frame::SettingFrame
end
Base.getproperty(pss::PagesSetting, key::Symbol) = getproperty(getfield(pss, :frame), key)
Base.setproperty!(pss::PagesSetting, key::Symbol, x) = setproperty!(getfield(pss, :frame), key, x)

const pagefoot = "Powered by <a href='https://github.com/JuliaRoadmap/DoctreePages.jl'>DoctreePages.jl</a> and its dependencies."
const pagescripts = sframe(
    :hljs_languages => [],
    :main_requirement => ["jquery", "highlight"],
    :requirejs => sframe(
        :url => "https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.6/require.min.js",
        :configpaths => Dict{String, String}(
            "headroom" => "https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/headroom.min",
            "jquery" => "https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.2/jquery.min",
            "headroom-jquery" => "https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/jQuery.headroom.min",
            "katex" => "https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.16.4/katex.min",
            "highlight" => "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/highlight.min",
        ),
        :configshim => Dict(
            "headroom-jquery" => Dict("deps" => ["jquery", "headroom"])
        ),
    )
)
const default_pagessettingframe = sframe(
    :content => sframe(
        :image => sframe(
            :text_default => "img",
            :text_type => :alt,
        ),
        :link => sframe(
            :server_prefix => "/",
        ),
        :table => sframe(
            :align => :auto,
        )
    ),
    :meta => sframe(
        :buildmessage => "built at $(Libc.strftime(Libc.time())) by DoctreePages.jl v$(DTP_VERSION)",
        :charset => "UTF-8",
        :favicon => nothing,
        :lang => "en",
    ),
    :page => sframe(
        :current => nothing,
        :foot => pagefoot,
        :scripts => pagescripts,
    ),
    :pages => sframe(
        :build_index => "index.html",
        :fileext => ".html",
    ),
    :parsing => sframe(),
    :project => sframe(
        :logo => nothing,
        :title => "Project",
    ),
    :repository => nothing,
    :root_folder => sframe(
        :build_404 => "404.html",
        :build_info_script => "extra/info.js",
        :build_mainpage => "index.html",
        :copies => Dict(
            "assets" => "assets",
            "script" => "script",
            "extra" => "extra",
        )
        :docs => "docs",
    ),
    :remove_original => true,
    :temp => sframe(),
    :theme => :documenter_default,
    :tree => Dict{String, Dict}(),
    :trace => sframe(
        :source_leafpath => CallCell(sf -> sf.source_path*sf.leafname),
        :target_leafpath => CallCell(sf -> sf.target_path*sf.leafname),
    ),
)

function callcell_repopath(sf::SettingFrame)
    rp = sf.repository
    "https://github.com/$(rp.owner)/$(rp.name)/tree/$(rp.branch)/"
end
function quickframe_repository(;branch = "master", name, owner, path = nothing)
    if isnothing(path)
        path = CallCell(callcell_repopath)
    end
    sframe(:branch => branch, :name => name, :owner => owner, :path => path)
end

Base.@kwdef struct PageSetting
    description::String
	editpath::String
    insert::String
    navbar_title::String
    nextpage::String
    prevpage::String
    tURL::String # trace-back-to-root-dir
end
