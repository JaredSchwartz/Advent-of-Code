testfile = "./2/test.txt"
inputfile = "./2/input.txt"

function parse_file(file::String)::Vector{Vector{Int}}
    lines = eachline(open(file,"r"))
    items = [parse.(Int, i) for i in split.(lines, r" +")]
    return items
end

# Answer 1
function report_processor(report::Vector{Int})::Bool
    diffs = diff(report)
    return all(1 .<= diffs .<= 3) | all(-1 .>= diffs .>= -3)
end

function answer1(file::String)::Int
    reports = parse_file(file)
    output = report_processor.(reports)
    return count(output)
end

# Answer 2
function suppressor(report::Vector{Int})::Bool
    position_vals = similar(report, Bool)
    for i in eachindex(report)
        r = copy(report)
        deleteat!(r,i)
        position_vals[i] = report_processor(r)
    end
    return any(position_vals)
end

function answer2(file::String)::Int
    reports = parse_file(file)
    output = suppressor.(reports)
    return count(output)
end