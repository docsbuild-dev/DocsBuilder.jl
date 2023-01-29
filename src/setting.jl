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
        :scripts => quickframe_page_scripts(),
    ),
    :pages => sframe(
        :build_404 => "404.html",
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
        :docs => "docs",
        :copies => Dict(
            "assets" => "assets",
            "script" => "script",
            "extra" => "extra",
        )
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
