function read_file(file::String)
    splits = [split(i, ": ") for i in eachline(file)]
    sums = [parse.(Int, i[1]) for i in splits]
    vals = [parse.(Int, split(i[2], " ")) for i in splits]
    return [(sums[i], vals[i]) for i in eachindex(sums)]
end

function concat(a::Int, b::Int)::Int
    b_length = ndigits(b)
    a * 10^b_length + b
end

using Base.Iterators

function process_item(item::Tuple{Int,Vector{Int}}, funs::Vector{Function})
    total, vals = item
    op_count = length(vals) - 1
    perms = Iterators.product(fill(eachindex(funs), op_count)...)
    for perm in perms
        val = vals[1]
        for (i, func_val) in enumerate(perm)
            func = funs[func_val]
            val = func(val, vals[i+1])
            val > total && break
        end
        val == total && return total
    end
    return 0
end

function answer1(file::String)
    outs = read_file(file)
    functions = Function[(+), (*)]
    return sum(process_item.(outs, Ref(functions)))
end

function answer2(file::String)
    outs = read_file(file)
    functions = Function[(+), (*), concat]
    return sum(process_item.(outs, Ref(functions)))
end

#= Optimized Verison =#

using Base.Threads

@inline function apply_operation(op_idx::Int, a::Int, b::Int)::Int
    op_idx == 1 && return (a + b)
    op_idx == 2 && return (a * b)
    op_idx == 3 && return (a * 10^ndigits(b) + b)
end

using Base.Threads
function process_item(item::Tuple{Int64,Vector{Int64}}, n_funcs::Int)::Int
    total, vals = item
    operation_count = length(vals) - 1
    total_perms = n_funcs^operation_count
    chunk_size = cld(total_perms, nthreads())
    
    # Create array of tasks
    tasks = [@async begin
        start = (t - 1) * chunk_size
        stop = min(start + chunk_size - 1, total_perms - 1)
        for i in start:stop
            running_total= vals[1]
            perm_index = i
            position_val = 1
            while position_val <= operation_count && running_total <= total
                op_idx = (perm_index % n_funcs) + 1
                running_total = apply_operation(op_idx, running_total, vals[position_val+1])
                perm_index ÷= n_funcs
                position_val += 1
            end   
            running_total == total && return total
        end
        return 0
    end for t in 1:nthreads()]
    
    while !isempty(tasks)
        result = fetch(popfirst!(tasks))
        result != 0 && return result
    end
    return 0
end

function answer1(file::String)
    outs = read_file(file)
    total = 0
    for i in outs total += process_item(i,2) end
    return total
end

function answer2(file::String)
    outs = read_file(file)
    total = 0
    for i in outs total += process_item(i,3) end
    return total
end