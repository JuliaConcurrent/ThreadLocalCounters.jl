baremodule ThreadLocalCounters

export @tlc

macro tlc end
function list end
function clear end

module Internal

using ..ThreadLocalCounters: ThreadLocalCounters
import ..ThreadLocalCounters: @tlc

import StaticStorages
import RecordArrays

include("internal.jl")

# Use README as the docstring of the module:
@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia"m => "```jldoctest README")
end ThreadLocalCounters

end  # module Internal

end  # baremodule ThreadLocalCounters
