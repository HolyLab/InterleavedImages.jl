struct InterleavedImage{T} <: AbstractArray{T,4}
    A1::AbstractArray{T,4}
    A2::AbstractArray{T,4}
    function InterleavedImage(A1::AbstractArray{T,4}, A2::AbstractArray{T,4}) where {T}
        if size(A1) != size(A2)
            error("The two image arrays must be of the same size")
        end
        new{T}(A1, A2)
    end
end

size(B::InterleavedImage) = (Base.front(size(B.A1))..., size(B.A1,4) + size(B.A2,4))

Base.IndexStyle(::Type{<:InterleavedImage}) = IndexCartesian()

function getindex(B::InterleavedImage, dim1, dim2, dim3, dim4::Int)
    t_ind = dim4
    halft = t_ind>>1
    return isodd(t_ind) ? getindex(B.A1, dim1, dim2, dim3, halft+1) : getindex(B.A2, dim1, dim2, dim3, halft)
end

getindex(B::InterleavedImage, idx::CartesianIndex) = B[idx.I...]

colon_to_inds(A::AbstractArray, I...) = colon_to_inds(indices(A), I...)
colon_to_inds(idxs::Tuple, idxc::Colon, idxsc...) = (first(idxs), colon_to_inds(Base.tail(idxs), idxsc...)...)
colon_to_inds(idxs::Tuple, idxc, idxsc...) = (idxc, colon_to_inds(Base.tail(idxs), idxsc...)...)
colon_to_inds(::Tuple{}) = ()
colon_to_inds(idxs::Tuple, ::Tuple{}) = error("Argument Tuples must be of equal length")
colon_to_inds(::Tuple{}, idxc, idxsc...) = error("Argument Tuples must be of equal length")

_idxs(A, dim, idxs) = idxs
_idxs(A, dim, idxs::Colon) = indices(A,dim)
_idxs(A::AbstractArray, idxs) = colon_to_inds(axes(A), idxs...)
_idx_shape(A::AbstractArray, idxs) = map(length, _idxs(A, idxs))

function getindex(B::InterleavedImage{T}, I...) where {T}
    prealloc = zeros(T, _idx_shape(B, (I...,))...)
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

function setindex!(B::InterleavedImage, v, dim1, dim2, dim3, dim4::Int)
    t_ind = dim4
    halft = t_ind>>1
    isodd(t_ind) ? setindex!(B.A1,v,dim1,dim2,dim3,halft+1) : setindex!(B.A2,v,dim1,dim2,dim3,halft)
end

#Note: this ditches img2's properites in favor of img1's. Will fix if it turns out to be a problem.
InterleavedImage(img1::ImageMeta, img2::ImageMeta) = ImageMeta(InterleavedImage(data(img1), data(img2)), properties(img1))
InterleavedImage(img1::AxisArray, img2::AxisArray) = match_axisspacing(InterleavedImage(data(img1), data(img2)), img1)
