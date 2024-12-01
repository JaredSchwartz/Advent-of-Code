testfile = "./1/test.txt"
inputfile = "./1/input.txt"

function parse_file(file::String)
    lines = eachline(open(file,"r"))
    items = [parse.(Int, i) for i in split.(lines, r" +")]
    v1 = getindex.(items, 1)
    v2 = getindex.(items, 2)
    return v1, v2
end

# Answer 1
function a(file::String)
    v1, v2 = parse_file(file)
    diffs = abs.(sort(v2) - sort(v1))
    return sum(diffs)
end

a(testfile)
a(inputfile)

# Answer 2
function a2(file::String)
    v1, v2 = parse_file(file)
    counts = [count(v2 .== num) for num in v1]
    mults = counts .* v1
    return sum(mults)
end

a2(testfile)
a2(inputfile)