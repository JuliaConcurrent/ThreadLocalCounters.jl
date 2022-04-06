# ThreadLocalCounters

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaconcurrent.github.io/ThreadLocalCounters.jl/dev)
[![CI](https://github.com/JuliaConcurrent/ThreadLocalCounters.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaConcurrent/ThreadLocalCounters.jl/actions/workflows/ci.yml)

ThreadLocalCounters.jl provides a macro `@tlc` to associate a counter to a code location.

```julia
julia> using ThreadLocalCounters

julia> hello_world() = @tlc hello_world;
```

The installed counter can be enumerated using `ThreadLocalCounters.list`:

```JULIA
julia> ThreadLocalCounters.list(; all = true)
1-element Vector{ThreadLocalCounters.Internal.ThreadLocalCounter}:
 [0] hello_world @Main #= REPL[2]:2 =#
```

The thread-local counter is incremented each time the program hits the associated code
location:

```JULIA
julia> hello_world();

julia> ThreadLocalCounters.list()
1-element Vector{ThreadLocalCounters.Internal.ThreadLocalCounter}:
 [1] hello_world @Main #= REPL[2]:2 =#

julia> hello_world();

julia> ThreadLocalCounters.list()
1-element Vector{ThreadLocalCounters.Internal.ThreadLocalCounter}:
 [2] hello_world @Main #= REPL[2]:2 =#
```
