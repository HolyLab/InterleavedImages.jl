module InterlacedStacks

using Images, AxisArrays
using CachedSeries #only for a utility function

import Base: size, getindex, setindex!

export InterlacedStackSeries

include("interlaced.jl")

end # module
