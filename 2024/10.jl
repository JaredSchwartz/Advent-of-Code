using Mmap
function read_file(file::String)::Matrix{Int}
    bytes = Mmap.mmap(file)
    full_width = findfirst(==(UInt8('\n')), bytes)
    width = full_width - 1 # account for newline chars
    return parse.(Int,Char.(permutedims(reshape(bytes, full_width, width)))[:, 1:end-1])
end

function counter(start::CartesianIndex{2}, part1::Bool, nines=Set{CartesianIndex{2}}())
    count = 0
    for step in STEPS
        newval = start + step
        checkbounds(Bool, mat, newval) || continue
        mat[newval] == mat[start] + 1 || continue
        if mat[newval] == 9
            push!(nines, newval)
            count += 1
            continue
        end
        count += counter(newval, part1, nines)
    end
    return part1 ? length(nines) : count
end

const STEPS = CartesianIndex.([(1,0), (0,-1), (0,1), (-1,0)])

function answer1(file::String)
    mat = read_file(file)
    start_positions = findall(==(0),mat)
    return sum(counter.(start_positions,true))
end

function answer2(file::String)
    mat = read_file(file)
    start_positions = findall(==(0),mat)
    return sum(counter.(start_positions,false))
end