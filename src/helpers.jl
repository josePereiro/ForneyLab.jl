export isApproxEqual, huge, tiny, KLpq, rules, format, isvalid, invalidate!

# ensureMatrix: ensure that the input is a 2D array or nothing
ensureMatrix{T<:Number}(arr::Array{T, 2}) = arr
ensureMatrix{T<:Number}(arr::Array{T, 1}) = reshape(arr, 1, 1)
ensureMatrix(n::Nothing) = nothing

# Define what is considered big and small, mostly used for setting vague messages.
huge(::Type{Float64}) = 1e12
huge() = huge(Float64)
tiny(::Type{Float64}) = 1./huge(Float64)
tiny() = tiny(Float64)

# Functions for getting and setting invalid distribution parameters
# A parameter value is invalid if the first entry is NaN
isvalid(v::Vector{Float64}) = !isnan(v[1])
isvalid(v::Matrix{Float64}) = !isnan(v[1,1])
isvalid(v::Float64) = !isnan(v)
function invalidate!(v::Vector{Float64})
    v[1] = NaN
    return v
end
function invalidate!(v::Matrix{Float64})
    v[1,1] = NaN
    return v
end

function format(d::Float64)
    if 0.01 < d < 100.0 || -100 < d < -0.01 || d==0.0
        return @sprintf("%.2f", d)
    else
        return @sprintf("%.2e", d)
    end
end

function format(d::Vector{Float64})
    s = "["
    for d_k in d[1:end-1]
        s*=format(d_k)
        s*=", "
    end
    s*=format(d[end])
    s*="]"
    return s
end

function format(d::Matrix{Float64})
    s = "["
    for r in 1:size(d)[1]
        s *= format(vec(d[r,:]))
    end
    s *= "]"
end

# isApproxEqual: check approximate equality
isApproxEqual(arg1, arg2) = maximum(abs(arg1-arg2)) < tiny()

# isRoundedPosDef: is input matrix positive definite? Round to prevent fp precision problems that isposdef() suffers from.
isRoundedPosDef{T<:FloatingPoint}(arr::Array{T, 2}) = ishermitian(round(arr, int(log(10, huge())))) && isposdef(arr, :L)

function viewFile(filename::String)
    # Open a file with the application associated with the file type
    @windows? run(`cmd /c start $filename`) : (@osx? run(`open $filename`) : (@linux? run(`xdg-open $filename`) : error("Cannot find an application for $filename")))
end

global unnamed_counter = 0
function unnamedStr()
    global unnamed_counter::Int64 += 1
    return "unnamed$(unnamed_counter)"
end

function KLpq(x::Vector{Float64}, p::Vector{Float64}, q::Vector{Float64})
    # Calculate the KL divergence of p and q
    length(x) == length(p) == length(q) || error("Lengths of x, p and q must match")
    dx = diff(x)
    return -sum(p[1:end-1].*log(q[1:end-1]./p[1:end-1]).*dx)
end

function truncate(str::ASCIIString, max::Integer)
    # Truncate srt to max positions
    if length(str)>max
        return "$(str[1:max-3])..."
    end
    return str
end

function pad(str::ASCIIString, size::Integer)
    # Pads str with spaces until its length reaches size
    str_trunc = truncate(str, size)
    return "$(str_trunc)$(repeat(" ",size-length(str_trunc)))"
end

immutable HTMLString
    s::ByteString
end
import Base.writemime
writemime(io::IO, ::MIME"text/html", y::HTMLString) = print(io, y.s)

function rules(node_type::Union(DataType, Nothing)=nothing; format=:table)
    # Prints a table or list of node update rules
    rule_dict = YAML.load_file("$(Pkg.dir("ForneyLab"))/src/update_equations.yaml")
    all_rules = rule_dict["rules"]

    # Select node specific rules
    if node_type != nothing
        rule_list = Dict()
        for (id, rule) in all_rules
            if rule["node"] == "$(node_type)"
                merge!(rule_list, {id=>rule}) # Grow the list of rules
            end
        end
    else
        rule_list = all_rules
    end

    node="node"; reference="reference"; formula="formula"; diagram="diagram"
    # Write rule list to output
    if format==:table
        println("|                  id                    |                  node                  |                   reference                   |")
        println("|----------------------------------------|----------------------------------------|-----------------------------------------------|")
        for (id, rule) in rule_list
            println("|$(pad(id,40))|$(pad(rule[node],40))|$(pad(rule[reference],47))|")
        end
        println("\nUse rules(NodeType) to view all rules of a specific node type; use rules(..., format=:list) to view the formulas in latex output.")
    elseif format==:list
        for (id, rule) in rule_list
            display(HTMLString("<b>$(id)</b>; $(rule[reference]):"))
            display(HTMLString("<font face=\"monospace\">$(rule[diagram])</font>"))
            display(LaTeXString(rule[formula]))
            display(HTMLString("<br>"))
        end
    else
        error("Unknown format $(format), use :table or :list instead")
    end
end