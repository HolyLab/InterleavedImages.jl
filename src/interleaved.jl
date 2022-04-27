abstract type InterleaveMarker end

struct Iyes <: InterleaveMarker end
struct Ino <: InterleaveMarker end

struct InterleavedImage{T,N,AA1<:AbstractArray{T,N}, AA2<:AbstractArray{T,N}, IMS<:NTuple{N,InterleaveMarker}} <: AbstractArray{T,N}
    oddA::AA1
    evenA::AA2
    imarkers::IMS
end

function InterleavedImage(oddA::AbstractArray{T,N}, evenA::AbstractArray{T,N}, idim::Int=N) where {T,N}
    if size(oddA) != size(evenA)
        error("The two image arrays must be of the same size")
    end
    if idim > N || idim < 1
        error("Interleaved dim out of range")
    end
    ims = ((ifelse(x==idim, Iyes(), Ino()) for x = 1:N)...,)
    return InterleavedImage(oddA, evenA, ims)
end

imarkers(img::InterleavedImage) = img.imarkers
interleaved_dim(A::InterleavedImage) = findfirst(isa.(imarkers(A), Iyes))
oddchild(A::InterleavedImage) = A.oddA
evenchild(A::InterleavedImage) = A.evenA

Base.IndexStyle(::Type{<:InterleavedImage}) = IndexCartesian()

_size(szs::Tuple, curm::Iyes, ims...) = (first(szs)*2, _size(Base.tail(szs), ims...)...)
_size(szs::Tuple, curm::Ino, ims...) = (first(szs), _size(Base.tail(szs), ims...)...)
_size(szs::Tuple{}, ims...) = ()

size(B::InterleavedImage) = _size(size(B.oddA), B.imarkers...)

#returns the appropriate child array and translates the query I
#into an index for that array
function arr_idx(img::InterleavedImage{T,N}, I::Tuple) where {T,N}
    markers = imarkers(img)
    child = _chooseimage(img, I, markers...)
    return child, _arr_idx(markers, I)
end

@inline _chooseimage(img, I, ::Ino, rest...) = _chooseimage(img, Base.tail(I), rest...)
@inline _chooseimage(img, I, ::Iyes, rest...) = return isodd(first(I)) ? oddchild(img) : evenchild(img)
@inline _chooseimage(img, I) = error("no yes markers found")

_arr_idx(::Tuple{}, ::Tuple{}) = ()
_arr_idx(markers, I) = (_arr_idx1(first(markers), first(I)), _arr_idx(Base.tail(markers), Base.tail(I))...)
_arr_idx1(::Iyes, i) = i>>1 + isodd(i)
_arr_idx1(::Ino, i)  = i

function getindex(img::InterleavedImage{T,N}, I::Vararg{Int, N}) where {T,N}
    chosenA, idx = arr_idx(img, (I...,))
    return chosenA[idx...]
end

function setindex!(img::InterleavedImage{T,N}, v, I::Vararg{Int, N}) where {T,N}
    chosenA, idx = arr_idx(img, (I...,))
    chosenA[idx...] = v
end

#utilities for ImageMeta and AxisArray types
#Note: this ditches img2's properites in favor of img1's. Will fix if it turns out to be a problem.
InterleavedImage(img1::ImageMeta{T,N}, img2::ImageMeta{T,N}, idim::Int=N) where {T,N} =
    ImageMeta(InterleavedImage(arraydata(img1), arraydata(img2), idim), properties(img1))
InterleavedImage(img1::AxisArray{T,N}, img2::AxisArray{T,N}, idim::Int=N) where {T,N} =
    match_axisspacing(InterleavedImage(arraydata(img1), arraydata(img2), idim), img1)
