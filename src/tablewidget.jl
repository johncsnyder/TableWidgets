

type TableWidget
    table
    header
    widget
    maxrows
    n
    expfmt
end



function TableWidget(ncols; header=nothing, fixed_width=0, maxrows=10, n=2, expfmt = latex_expfmt)
    if fixed_width != 0 && !is(header,nothing)
        header = map(x -> lpad(x,fixed_width), header)
    end
    
    TableWidget(cell(0,ncols),header,TextWidget(""),maxrows,n,expfmt)
end


function Base.push!(tlw::TableWidget,row)
    tlw.table = vcat(tlw.table,row')
    update_display(tlw)
end


function update_display(tlw::TableWidget)
    io = IOBuffer()
    nrows = size(tlw.table,1)
    start = tlw.maxrows == 0 ? 1 : max(1, nrows-tlw.maxrows)
    writetable(io, tlw.table[start:end,:], header=tlw.header, n=tlw.n, expfmt=tlw.expfmt)
    s = takebuf_string(io)
    update(tlw.widget,s)
end

function Base.writemime(io, mime::MIME"text/html", tlw::TableWidget)
    writemime(io,mime,tlw.widget)
end

