


# function numdecdigits(x)
#     d = 0
#     while round(x-round(x),15-d) != 0
#         x *= 10
#         d += 1
#     end
#     d
# end


# function numintdigits(x)
#     d = 0
#     while round(Int,x) != 0
#         x /= 10
#         d += 1
#     end
#     d
# end



# returns the exponent if x is expressed in scientific notation (base 10)
# e.g.
# 0.00123 = 1.23e-3
# so exponent is -3
function exponent10(x)
    if x == zero(x)
        return 0
    elseif x > zero(x)
        return floor(Int,log10(x))
    else
        return ceil(Int,log10(-x))
    end
end


# return the part of x without the exponent if expressed in scientific notation
# e.g.
# 0.00123 = 1.23e-3
# mantissa = 1.23
mantissa10(x) = x*exp10(-exponent10(x))




latex_expfmt(e) = string(" × 10^{",e,'}')
standard_expfmt(e) = string('e',e)



function formatter(x::AbstractFloat;
                   n::Int = 2,                      # number of significant figures
                   expfmt = latex_expfmt)           # exponent formatter

    (isnan(x) || isinf(x)) && return (string(x),' ',"")
    
    e = exponent10(x)                               # exponent
    m = round(x*exp10(-e), n-1)                     # mantissa

    # case 1: use scientific notation if number is extra long
    if e > 4 || e < -4
        s = string(format("{:.$(n-1)f}", m), expfmt(e))
        l,r = split(s, '.')
        return (l,'.',r)
    else
        xf = m*exp10(e)

        if n > e+1
            l,r = split(format("{:.$(n-e-1)f}", xf), '.')
            return (l,'.',r)
        elseif n == e+1
            l = format("{:d}", round(Int,xf))
            return (l,'.',"")
        else
            l = format("{:d}", round(Int,xf))
            return (l,' ',"")
        end
    end
end



formatter(x::Integer; kwargs...) = (string(x),' ',"")

formatter(x::AbstractString; kwargs...) = (x,' ',"")





function writetable(io::IO,
                    table::Matrix;
                    header = nothing,                    # column names
                    notes = nothing,
                    expfmt = latex_expfmt,
                    n = 2)                               # number of significant digits
    
    s = map(x -> formatter(x,n=n,expfmt=expfmt), table)

    if !is(notes, nothing)
        for (k,v) in notes
            i,j = k
            x = s[i,j]
            s[i,j] = (x[1],x[2],x[3] * " ($v)")
        end
    end

    ll,lr = map(x -> length(x[1]), s), map(x -> length(x[3]), s)                    # lengths of left, right parts of columns
    wl,wr = maximum(ll,1), maximum(lr,1)                                            # left, right column part widths
    w = wl+wr+1                                                                     # column widths

    addcols = cols -> string("| ", join(cols, " | "), " |")                         # combine columns in one row
    addparts = (s,wl,wr) -> string(lpad(s[1],wl), s[2], rpad(s[3],wr))              # combine left, middle, right parts of table entry

    s = [addparts(s[i,j],wl[j],wr[j]) for i in 1:size(s,1), j in 1:size(s,2)]

    if !is(header, nothing)
        wh = map(length, header)                                                    # column header widths
        s = [lpad(s[i,j], wh[j]) for i in 1:size(s,1), j in 1:size(s,2)]            # pad column to header width
        pheader = [rpad(header[i], w[i]) for i in 1:length(header)]                 # padded column header
        hs = addcols(pheader)                                                       # header string
        w = map(max,w,wh)
        hline = addcols([repeat("-", l) for l in w])
        ts = join([addcols(s[i,:]) for i in 1:size(s,1)], "\n")
        return write(io, hs, '\n', hline, '\n', ts)
    else
        ts = join([addcols(s[i,:]) for i in 1:size(s,1)], "\n")
        return write(io, ts)
    end
end
