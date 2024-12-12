function process_element(element::Int)::Vector{Int}
    if element == 0
        return [1]
    elseif isodd(ndigits(element))
        return [element * 2024]
    else
        div = 10^(ndigits(element) ÷ 2)
        return [element ÷ div, element % div]
    end
end

function miner(input::Dict{Int,Int}, steps_remaining::Int)::Int
    steps_remaining == 0 && return sum(values(input))
    
    output = Dict{Int,Int}()
    for (num, count) in input
        for new_num in process_element(num)
            output[new_num] = get(output, new_num, 0) + count
        end
    end
    
    return miner(output, steps_remaining - 1)
end

function answer(file::String, steps::Int)
    input = parse.(Int, split(readline(file)))
    
    initial_dict = Dict(num => 1 for num in input)
    
    return miner(initial_dict, steps)
end

answer("./11/input.txt", 25)
answer("./11/input.txt", 75)