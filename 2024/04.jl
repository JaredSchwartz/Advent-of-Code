testfile = "./4/test.txt"
inputfile = "./4/input.txt"
inputfile1 = "./4/input1.txt"
using BenchmarkTools

#=Original Verison=#
function parse_array(file::String)::Matrix{Int}
    replacements = Dict("X" => "1", "M" => "2", "A" => "3", "S" => "4")
    text = read(file, String)
    text = replace(text, replacements...)
    array = hcat(collect.(split(text, "\r\n"))...)
    array = parse.(Int, array)
    return array
end

function answer1(file::String)::Int
    arr = parse_array(file)
    steps = CartesianIndex.([(0,1), (0,-1), (1,0), (-1,0), (1,1), (1,-1), (-1,1), (-1,-1)])
    xmas_counter = 0
    start_points = findall(arr .== 1)
    for point in start_points
        for step in steps
            candidate_m = point + step
            !checkbounds(Bool, arr, candidate_m) && continue
            arr[candidate_m] != 2 && continue
            
            candidate_a = candidate_m + step
            !checkbounds(Bool, arr, candidate_a) && continue
            arr[candidate_a] != 3 && continue
            
            candidate_s = candidate_a + step
            !checkbounds(Bool, arr, candidate_s) && continue
            arr[candidate_s] != 4 && continue

            xmas_counter += 1
        end
    end
    return xmas_counter
end

function answer2(file::String)::Int
    arr = parse_array(file)
    steps = CartesianIndex.([(1,1), (1,-1), (-1,1), (-1,-1)])
    start_points = findall(arr .== 3)
    x_mas_counter = 0
    for point in start_points
        pathcounter = 0
        for step in steps
            candidate_m = point + step
            !checkbounds(Bool,arr,candidate_m) && continue
            arr[candidate_m] != 2 && continue

            candidate_s = point + (step * -1)
            !checkbounds(Bool,arr,candidate_s) && continue
            arr[candidate_s] != 4 && continue

            pathcounter += 1
        end
        pathcounter != 2 && continue
        x_mas_counter += 1
    end
    return x_mas_counter
end

#=
Optimized Verison

The strategy with this optimization was threefold:
1. Reduce the amount of processing on the input data
2. Simplify the pattern matching logic
3. Implement multithreading

To reduce the processing, I reworked the read to use a memory-mapped byte array
of the file that could then be reshaped into the matrix format. I also updated
the operations to operate on ASCII (1 byte per letter), rather than converting
to Char which uses Unicode (4 bytes per letter). The rest of the functions were
altered to operate on ASCII. This necessitated setting up global constants for
the ASCII characters to share between the functions with no overhead.

Relatedly, I also switched to using tuples, rather than cartesian indices, as
they are lighter-weight and don't allocate memory in the same ways.

The pattern matching logic was simplified in part 1 by checking only the
boundary of the last letter (S), rather than on each iteration. Also I used a
branchless technique to combine the various conditions for the letters to then
add to the count.

Part 2 was simplified by checking whether the 'A' in the middle was on the edge
of the matrix, rather than checking each corner. I also implemented early
stopping if the count of the paths equaled two, cutting the processing by up to
half for each center point.

Threading was accomplished with the @Threads macro and thread-local counters.
=#
using Mmap
using Base.Threads

const LETTERS = (
    X = UInt8('X'),
    M = UInt8('M'),
    A = UInt8('A'),
    S = UInt8('S')
)

function read_file(file::String)::Matrix{UInt8}
    bytes = Mmap.mmap(file)
    full_width = findfirst(==(UInt8('\n')), bytes)
    width = full_width - 2 # account for carriage return and newline chars
    return reshape(bytes, full_width, width)
end

function answer1_optimized(file::String)::Int
    arr = read_file(file)
    
    steps = (
        (0,1), (0,-1), (1,0), (-1,0),
        (1,1), (1,-1), (-1,1), (-1,-1)
    )
    
    start_points = Tuple.(findall(arr .== LETTERS.X))
    counter = zeros(Int, Threads.nthreads())
    
    @threads for point in start_points
        tid = Threads.threadid()
        @inbounds for step in steps
            endpoint = point .+ (step .* 3)
            checkbounds(Bool, arr, endpoint...) || continue
            
            m_pos = point .+ step
            a_pos = point .+ (step .* 2)
            s_pos = endpoint
            
            counter[tid] += (arr[m_pos...] == LETTERS.M) & 
                            (arr[a_pos...] == LETTERS.A) & 
                            (arr[s_pos...] == LETTERS.S)
        end
    end
    return sum(counter)
end

function answer2_optimized(file::String)::Int
    arr = read_file(file)
    rows, cols = size(arr)
    
    steps = ((1,1), (1,-1), (-1,1), (-1,-1))

    start_points = Tuple.(findall(arr .== LETTERS.A))
    counter = zeros(Int, Threads.nthreads())
    
    @threads for point in start_points
        row, col = point
        (row == 1 || row == rows || col == 1 || col == cols) && continue
        
        tid = Threads.threadid()
        pathcount = 0
        
        @inbounds for step in steps
            m_pos = point .+ step
            arr[m_pos...] == LETTERS.M || continue
            
            s_pos = point .+ (step .* -1)
            arr[s_pos...] == LETTERS.S || continue
            
            pathcount += 1
            pathcount == 2 || continue
            counter[tid] += 1
            break
        end
    end
    
    return sum(counter)
end

@assert answer1(inputfile) == answer1_optimized(inputfile1)
@assert answer2(inputfile) == answer2_optimized(inputfile1)
@btime answer1(inputfile)
@btime answer2(inputfile)
@btime answer1_optimized(inputfile1)
@btime answer2_optimized(inputfile1)