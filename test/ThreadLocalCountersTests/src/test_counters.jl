module TestCounters

using Test
using ThreadLocalCounters

sumall(c) = sum(x.n for x in c.counters)

""" Get a tlc defined in this module by name. """
tlc_by_name(name) = only(
    c for c in ThreadLocalCounters.list() if (c._module === @__MODULE__) && c.name === name
)

function test_tlc()
    tlc = tlc_by_name(:test_tlc)
    empty!(tlc)

    nhits = 4 * Threads.nthreads()
    Threads.@threads for _ in 1:nhits
        @tlc test_tlc
    end

    @test sumall(tlc) == nhits
    ThreadLocalCounters.clear()
    @test sumall(tlc) == 0
end

end  # module
