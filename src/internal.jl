make_counters(nthreads = Threads.nthreads()) =
    RecordArrays.fill((n = 0,), nthreads; align = 64)

mutable struct ThreadLocalCounter
    name::Symbol
    _module::Module
    line::LineNumberNode
    counters::typeof(make_counters(1))
end

ThreadLocalCounter(name::Symbol, m::Module, line::LineNumberNode) =
    ThreadLocalCounter(name, m, line, make_counters())

function init!(tlc::ThreadLocalCounter)
    tlc.counters = make_counters()
    return tlc
end

function inc!(tlc::ThreadLocalCounter)
    tlc.counters.n[Threads.threadid()] += 1
end
# TODO: put `@inbounds`, once `init!` is tested well?

function Base.empty!(tlc::ThreadLocalCounter)
    fill!(tlc.counters.n, 0)
    return tlc
end

const TLC_BUCKET = StaticStorages.BucketKey()

"""
    @tlc [name]

Count the time this expression is evaluated using thread-local counters.
"""
macro tlc(name::Symbol = :_default_)
    tlc = ThreadLocalCounter(name, __module__, __source__)
    StaticStorages.put!(__module__, TLC_BUCKET, tlc)

    @gensym initmodule
    initializer = quote
        module $initmodule
        __init__() = $init!($(QuoteNode(tlc)))
        end
    end
    @assert initializer.head === :block
    initializer.head = :toplevel
    Base.eval(__module__, initializer)

    quote
        $inc!($(QuoteNode(tlc)))
        nothing
    end
end

"""
    ThreadLocalCounters.list()

Get a list of all thread-local counters.
"""
ThreadLocalCounters.list
ThreadLocalCounters.list() =
    collect(ThreadLocalCounter, values(StaticStorages.getbucket(TLC_BUCKET)))

"""
    ThreadLocalCounters.clear()

Reset all counters. The caller must ensure that no thread is accessing the
counters.
"""
function ThreadLocalCounters.clear()
    foreach(empty!, values(StaticStorages.getbucket(TLC_BUCKET)))
end

function Base.show(io::IO, ::MIME"text/plain", tlc::ThreadLocalCounter)
    if get(io, :typeinfo, Any) !== ThreadLocalCounter
        print(io, "ThreadLocalCounter: ")
    end
    show(io, [x.n for x in tlc.counters])
    if tlc.name !== :_default_
        print(io, ' ')
        printstyled(io, tlc.name; color = :blue)
    end
    print(io, " @", tlc._module, ' ')
    print(io, tlc.line, ' ')
end
