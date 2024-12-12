function read_file(file::String, split_blocks::Bool=false)
    vals = parse.(Int, Char.(mmap(file)))
    files = Tuple{Int,Int,Int}[]
    spaces = Tuple{Int,Int}[]
    pos = 1
    
    for (i, val) in enumerate(vals)
        if iseven(i)
            push!(spaces, (pos, val))
            pos += val
            continue
        end
        
        if !split_blocks
            push!(files, (div(i-1,2), pos, val))
            pos += val
            continue
        end
        
        append!(files, ((div(i-1,2), pos+j-1, 1) for j in 1:val))
        pos += val
    end
    
    return files, spaces, sum(vals)
end

function solver(files::Tuple{Int,Int,Int}, spaces::Tuple{Int,Int}, total_length::Int)
    final = fill(-1, total_length)
    for (id, start, size) in files
        final[start:start+size-1] .= id
    end
    
    for (id, oldpos, size) in reverse(files)
        for (i, (space_start, space_size)) in enumerate(spaces)
            if space_size < size || space_start >= oldpos
                continue
            end
            
            final[oldpos:oldpos+size-1] .= -1
            final[space_start:space_start+size-1] .= id
            spaces[i] = (space_start + size, space_size - size)
            break
        end
    end
    
    return sum(id * (i-1) for (i, id) in enumerate(final) if id >= 0)
end

function answer1(file::String)
    files, spaces, total_length = read_file(file, true)
    return solver(files, spaces, total_length)
end

function answer2(file::String)
    files, spaces, total_length = read_file(file, false)
    return solver(files, spaces, total_length)
end

answer1("./9/input.txt")
answer2("./9/input.txt")