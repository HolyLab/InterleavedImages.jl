struct InterlacedStackSeries{T} <: AbstractArray{T,4}
    A1::AbstractArray{T,4}
    A2::AbstractArray{T,4}
    function InterlacedStackSeries(A1::AbstractArray{T,4}, A2::AbstractArray{T,4}) where {T}
        if size(A1) != size(A2)
            error("The two image arrays must be of the same size")
        end
        new{T}(A1, A2)
    end
end

size(B::InterlacedStackSeries) = (Base.front(size(B.A1))..., size(B.A1,4) + size(B.A2,4))

Base.IndexStyle(::Type{<:InterlacedStackSeries}) = IndexCartesian()

function getindex(B::InterlacedStackSeries, dim1, dim2, dim3, dim4::Int)
    t_ind = dim4
    halft = t_ind>>1
    return isodd(t_ind) ? getindex(B.A1, dim1, dim2, dim3, halft+1) : getindex(B.A2, dim1, dim2, dim3, halft)
end

getindex(B::InterlacedStackSeries, idx::CartesianIndex) = B[idx.I...]

function getindex(B::InterlacedStackSeries{T}, I...) where {T}
    prealloc = zeros(T, CachedSeries._idx_shape(B, (I...))...)
    tinds = last(I)
    for (i,t) in enumerate(tinds)
        halft = t>>1
        if isodd(t)
            prealloc[:,:,:,i] = getindex(B.A1, I[1], I[2], I[3], halft+1)
        else
            prealloc[:,:,:,i] = getindex(B.A2, I[1], I[2], I[3], halft)
        end
    end
    return prealloc
end

function setindex!(B::InterlacedStackSeries, v, dim1, dim2, dim3, dim4::Int)
    t_ind = dim4
    halft = t_ind>>1
    isodd(t_ind) ? setindex!(B.A1,v,dim1,dim2,dim3,halft+1) : setindex!(B.A2,v,dim1,dim2,dim3,halft)
end

#Note: this ditches img2's properites in favor of img1's. Will fix if it turns out to be a problem.
InterlacedStackSeries(img1::ImageMeta, img2::ImageMeta) = ImageMeta(InterlacedStackSeries(data(img1), data(img2)), properties(img1))
InterlacedStackSeries(img1::AxisArray, img2::AxisArray) = match_axisspacing(InterlacedStackSeries(data(img1), data(img2)), img1)
