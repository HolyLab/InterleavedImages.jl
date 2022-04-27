module InterleavedImages

using ImageMetadata, AxisArrays
const axes = Base.axes #for name conflict with AxisArrays

using CachedArrays #only for match_axisspacing

import Base: size, getindex, setindex!

export InterleavedImage

include("interleaved.jl")

end # module
