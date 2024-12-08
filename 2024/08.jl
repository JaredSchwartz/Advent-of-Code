using Combinatorics
using Mmap

function read_file(file::String)::Matrix{UInt8}
    bytes = Mmap.mmap(file)
    full_width = findfirst(==(UInt8('\n')), bytes)
    width = full_width - 1 # account for newline chars
    return permutedims(reshape(bytes, full_width, width))[:, 1:end-1]
end

function answer1(file::String)
    mat = read_file(file)
    points = findall(!=(UInt8('.')), mat)
    vals = mat[points]
    antinodes = Set{CartesianIndex{2}}()
    for val in unique(vals)
        coords = points[vals.==val]
        combs = combinations(coords, 2)
        for comb in combs
            p1, p2 = comb
            diff = p1 - p2
            p1 += diff
            checkbounds(Bool, mat, p1) && push!(antinodes, p1)
            p2 -= diff
            checkbounds(Bool, mat, p2) && push!(antinodes, p2)
        end
    end
    return length(antinodes)
end

function answer2(file::String)
    mat = read_file(file)
    points = findall(!=(UInt8('.')), mat)
    vals = mat[points]
    antinodes = Set{CartesianIndex{2}}()
    for val in unique(vals)
        coords = points[vals.==val]
        combs = combinations(coords, 2)
        for comb in combs
            p1, p2 = comb
            diff = p1 - p2
            while checkbounds(Bool, mat, p1)
                push!(antinodes, p1)
                p1 += diff
            end
            while checkbounds(Bool, mat, p2)
                push!(antinodes, p2)
                p2 -= diff
            end
        end
    end
    return length(antinodes)
end