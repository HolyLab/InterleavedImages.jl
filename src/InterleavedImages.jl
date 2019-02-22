module InterleavedImages

using Images, AxisArrays
using CachedSeries #only for a utility function

import Base: size, getindex, setindex!

export InterleavedImage

include("interleaved.jl")

end # module
