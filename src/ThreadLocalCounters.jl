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

end  # module Internal

end  # baremodule ThreadLocalCounters
