
module TableWidgets

using Formatting
using IJulia.CommManager


export TextWidget, writetable, update, TableWidget


include("textwidget.jl")
include("writetable.jl")
include("tablewidget.jl")


end # module
