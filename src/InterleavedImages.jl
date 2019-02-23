module InterleavedImages

using Images, AxisArrays
const axes = Base.axes #for name conflict with AxisArrays

using CachedArrays #only for a utility function

import Base: size, getindex, setindex!

export InterleavedImage

include("interleaved.jl")

end # module
