testfile = "./2/test.txt"
inputfile = "./2/input.txt"

function parse_file(file::String)::Vector{Vector{Int}}
    lines = eachline(open(file,"r"))
    items = [parse.(Int, i) for i in split.(lines, r" +")]
    return items
end

# Answer 1
function report_processor(report::Vector{Int})::Bool
    shifted_report = circshift(report, 1)
    diffs = report[2:end] - shifted_report[2:end]
    direction_cond = all(diffs .> 0) | all(diffs .< 0)
    sizes_cond = all(1 .<= abs.(diffs) .<= 3)
    return direction_cond & sizes_cond
end

function answer1(file::String)::Int
    reports = parse_file(file)
    output = report_processor.(reports)
    return count(output)
end

# Answer 2
function surpressor(report::Vector{Int})::Bool
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
    output = surpressor.(reports)
    return count(output)
end