module TestCounters

using Test
using ThreadLocalCounters

""" Get a tlc defined in this module by name. """
tlc_by_name(name) = only(
    c for c in ThreadLocalCounters.list(; all = true) if
    (c._module === @__MODULE__) && c.name === name
)

function test_tlc()
    tlc = tlc_by_name(:test_tlc)
    empty!(tlc)
    @test tlc ∉ ThreadLocalCounters.list()  # empty counter is not included

    nhits = 4 * Threads.nthreads()
    Threads.@threads for _ in 1:nhits
        @tlc test_tlc
    end
    @test tlc ∈ ThreadLocalCounters.list()

    @test sum(tlc) == nhits
    ThreadLocalCounters.clear()
    @test sum(tlc) == 0
end

end  # module
