using InterleavedImages, Images, AxisArrays, Test

A1 = rand(3,3,3,5)
A2 = rand(3,3,3,5)
ss = InterleavedImage(A1,A2,4)

#type inference bug?
##code_warntype shows that the below is inferrable...
#_A1 = rand(3,3,3)
#_A2 = rand(3,3,3)
#_ss = InterleavedImage(_A1,_A2,3)
#@code_warntype(_ss[1,3,2])
##yet the below is not inferrable...
#@code_warntype(ss[1,3,2,3])

@test all(ss[:,:,:,1].==A1[:,:,:,1])
@test all(ss[:,:,:,2].==A2[:,:,:,1])

@test all(ss[:,:,:,1:2].==cat(A1[:,:,:,1], A2[:,:,:,1], dims=4))

#setindex!
ss[:,:,:,3] = zeros(3,3,3)
@test all(A1[:,:,:,2].==zeros(3,3,3))

#ImageMeta
meta1 = ImageMeta(A1)
meta2 = ImageMeta(A2)
ssm = InterleavedImage(meta1,meta2,4)

@test isa(ssm, ImageMeta)
@test all(ssm[:,:,:,1].==A1[:,:,:,1])
@test all(ssm[:,:,:,2].==A2[:,:,:,1])

#AxisArray
aa1 = AxisArray(A1)
aa2 = AxisArray(A2)
ssaa = InterleavedImage(aa1,aa2,4)
@test isa(ssaa, AxisArray)
@test all(ssaa[:,:,:,1].==A1[:,:,:,1])
@test all(ssaa[:,:,:,2].==A2[:,:,:,1])
