using Mmap

function read_file(file::String)::Matrix{Char}
    bytes = Mmap.mmap(file)
    full_width = findfirst(==(UInt8('\n')), bytes)
    width = full_width - 1
    return Char.(permutedims(reshape(bytes, full_width, width)))[:, 1:end-1]
end

const STEPS = CartesianIndex.([(1,0), (0,-1), (0,1), (-1,0)])

function flood_fill!(seen::Set{CartesianIndex{2}}, grid::Matrix{Char}, pos::CartesianIndex{2}, char::Char)
    pos ∈ seen && return CartesianIndex{2}[]
    checkbounds(Bool, grid, pos) || return CartesianIndex{2}[]
    grid[pos] == char || return CartesianIndex{2}[]
    
    push!(seen, pos)
    
    return [pos; flood_fill!.(Ref(seen), Ref(grid), pos .+ STEPS, char)...]
end

function find_regions(mat::Matrix{Char})
    regions = Vector{Vector{CartesianIndex{2}}}()
    seen = Set{CartesianIndex{2}}()
    
    for idx in CartesianIndices(mat)
        idx ∉ seen && push!(regions, flood_fill!(seen, mat, idx, mat[idx]))
    end

    return regions
end

function answer(filename::String, part_2::Bool=true)
    mat = read_file(filename)
    regions = find_regions(mat)
    
    total = 0
    for region in regions
        edges = [(pos, step) for pos in region, step in STEPS 
                if pos + step ∉ region]
        
        part_2 && (total += length(edges) * length(region); continue)

        pairs = 0
        for (i, (p1, step1)) in enumerate(edges), (p2, step2) in edges[i+1:end]
            step1 == step2 || continue
            p1 - p2 ∈ STEPS && (pairs += 1)
        end
        
        total += (length(edges) - pairs) * length(region)
    end
    return total
end

answer("./12/test.txt", true)