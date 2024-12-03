testfile = "./3/test.txt"
inputfile = "./3/input.txt"

function parse_multiply(text::String)
    matches = eachmatch(r"mul\((\d+),(\d+)\)", text)
    pairs = [parse.(Int, i.captures) for i in matches]
    prods = prod.(pairs)
    return sum(prods)
end

function answer1(file::String)
    text = read(file, String)
    return parse_multiply(text)
end

function answer2(file::String)
    text = read(file, String)
    cleaned = replace(text, r"don't\(\).*?(?=do\(\)|$)"s => "")
    return parse_multiply(cleaned)
end