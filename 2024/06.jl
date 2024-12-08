using Mmap
function read_file(file::String)::Matrix{UInt8}
    bytes = Mmap.mmap(file)
    full_width = findfirst(==(UInt8('\n')), bytes)
    width = full_width - 1 # account for newline chars
    return permutedims(reshape(bytes, full_width, width))[:, 1:end-1]
end

const STEPS = CartesianIndex.([(-1, 0), (0, 1), (1, 0), (0, -1)])

const SYMS = (
    guard=UInt8('^'),
    obst=UInt8('#')
)

function guardwalk(mat::Matrix{UInt8}, startpoint::CartesianIndex{2}, start_dir::Int, loop_detector_mode::Bool)
    direction = start_dir
    newpoint = startpoint
    point = CartesianIndex(0, 0)
    !loop_detector_mode && (visited_matrix = BitMatrix(undef, size(mat)))
    !loop_detector_mode && fill!(visited_matrix, false)
    stepcounter = 0

    @inbounds while checkbounds(Bool, mat, newpoint)
        iscorner = mat[newpoint] == SYMS.obst
        direction = iscorner ? mod1(direction + 1, 4) : direction
        point = iscorner ? point : newpoint
        !loop_detector_mode && !iscorner && (visited_matrix[point] = true)
        newpoint = point + STEPS[direction]

        stepcounter += loop_detector_mode
        loop_detector_mode && stepcounter >= 6_000 && return true
    end

    return loop_detector_mode ? false : findall(visited_matrix)
end

function answer1(file::String)
    mat = read_file(file)
    startpoint = findfirst(==(SYMS.guard), mat)
    return length(guardwalk(mat, startpoint, 1, false))
end

function answer2(file::String)
    mat = read_file(file)
    startpoint = findfirst(==(SYMS.guard), mat)
    allpoints = guardwalk(mat, startpoint, 1, false)
    points = setdiff!(allpoints, Set([startpoint]))
    output = Vector{Bool}(undef, length(points))
    matbuffer = similar(mat)
    for (i, point) in enumerate(points)
        copyto!(matbuffer, mat)
        matbuffer[point] = UInt8(SYMS.obst)
        output[i] = guardwalk(matbuffer, startpoint, 1, true)
    end
    return count(output)
end