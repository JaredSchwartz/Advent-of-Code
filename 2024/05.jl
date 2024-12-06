function parse_file(file::String)
    text = read(file,String)
    texts = split(text,"\n\n")
    rules = permutedims(hcat([parse.(Int, split(i, '|')) for i in split(texts[1], '\n')]...))
    updates = [parse.(Int, split(i, ',')) for i in split(texts[2], '\n')]
    return rules, updates
end 

function evaluator(rules::Matrix{Int},update::Vector{Int})::Matrix{Int}
    mask = vec(all(rules .∈ Ref(update), dims=2))
    filtered_rules = rules[mask,:]
    invalid_rules = [findfirst(update .== rule[2]) < findfirst(update .== rule[1]) for rule in eachrow(filtered_rules)]
    return filtered_rules[invalid_rules,:]
end

function fixer(rules::Matrix{Int}, update::Vector{Int})::Vector{Int}
    update_c = copy(update)
    while true
        violated_rules = evaluator(rules, update_c)
        isempty(violated_rules) && return update_c
        
        for rule in eachrow(violated_rules)
            prefix, suffix = rule[1], rule[2]
            prefix_pos = findfirst(update_c .== prefix)
            suffix_pos = findfirst(update_c .== suffix)
            insert_pos = prefix_pos < suffix_pos ? suffix_pos-1 : suffix_pos
            
            deleteat!(update_c, prefix_pos)
            insert!(update_c, insert_pos, prefix)
        end
    end
    return update_c
end

function answer1(file::String)::Int
    rules, updates = parse_file(file)
    isvalid = isempty.(evaluator.(Ref(rules), updates))
    valids = updates[isvalid]
    middles = getindex.(valids, cld.(length.(valids), 2))
    return sum(middles)
end

function answer2(file::String)::Int
    rules, updates = parse_file(file)
    isinvalid = .!isempty.(evaluator.(Ref(rules), updates))
    invalids = updates[isinvalid]
    fixed = fixer.(Ref(rules), invalids)
    middles = getindex.(fixed, cld.(length.(fixed),2))
    return sum(middles)
end