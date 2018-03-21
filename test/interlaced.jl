using InterlacedStacks, Base.Test

A1 = rand(3,3,3,5)
A2 = rand(3,3,3,5)

ss = InterlacedStackSeries(A1,A2)

@test all(ss[:,:,:,1].==A1[:,:,:,1])
@test all(ss[:,:,:,2].==A2[:,:,:,1])

@test all(ss[:,:,:,1:2].==cat(4, A1[:,:,:,1], A2[:,:,:,1]))

#setindex!
ss[:,:,:,3] = zeros(3,3,3)
@test all(A1[:,:,:,2].==zeros(3,3,3))
