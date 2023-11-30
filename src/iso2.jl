# test implementation of ISOKANN 2.0

import StatsBase
import Flux
import ISOKANN
using LinearAlgebra: pinv, eigen, norm, diag, I
using Plots
include("isosimple.jl")  # for the learnstep! function
include("forced/langevin.jl")  # for the simulators

""" iso2(; kwargs...)
ISOKANN 2.0 under construction. Uses the pseudoinverse, normalization, and permutation stabilization.
- `n`: number of steps
- `nx`: number of sampling points
- `ny`: number of koopman samples
- `nd`: number of dimensions of the chi function / number of metastabilities
- `sys`: system to simulate (needs to support randx0, dim, propagate)
"""
function iso2(; n=1, nx=10, ny=10, nd=2, sys=Doublewell(), lr=1e-3, decay=1e-5)
    global s, model, xs, ys, opt, loss
    s = sys
    xs = randx0(sys, nx)
    ys = propagate(sys, xs, ny)

    model = Flux.Chain(
        Flux.Dense(dim(sys),5, Flux.sigmoid),
        Flux.Dense(5,5,Flux.sigmoid),
        #Flux.Dense(30,10,Flux.sigmoid),
        Flux.Dense(5,nd))

    opt = Flux.setup(Flux.AdamW(lr, (0.9, 0.999), decay), model)
    loss = isostep(model, opt, (xs, ys), n)
end

""" isostep(model, opt, (xs, ys), nkoop=1, nupdate=1)
train the model on a given batch of trajectory data `(xs, ys)` with
- nkoop outer iterations, i.e. reevaluating Koopman
- nupdate inner iterations, i.e. updating the neural network on fixed data
"""
function isostep(model, opt, (xs, ys), nkoop=1, nupdate=1)
    losses = Float64[]
    global target
    for i in 1:nkoop
        target = isotarget(model, xs, ys)
        for j in 1:nupdate
            loss = learnstep!(model, xs, target, opt)  # Neural Network update
            push!(losses, loss)
        end
    end
    losses
end

""" isotarget(model, xs, ys)
compute the isokann target function for the given model and data
"""
function isotarget(model, xs, ys)
        chi = model(xs)

        cs = model(ys)::AbstractArray{<:Number,3}
        ks = StatsBase.mean(cs[:, :, :], dims=3)[:,:,1]

        target = Kinv(chi, ks)

        #target = K_isa(ks)
        #target = target .- mean(target, dims=1) .+ .1

        # normalize target
        target = target ./ norm.(eachrow(target), 1) .* size(target, 2)
        target = real.(target)

        # stabilization of permutationn
        crit = chi * target'
        display(crit)
        P  = stableperm(crit)
        display(chi * (P * target)')
        target = P * target

    debug = 0.1
        if rand() > (1 - debug)
            if size(xs, 1) == 1  # 1D state space
                scatter(vec(xs), target')  # scatter training points
                plot!(vec(xs), chi') |> display  # plot current network evaluations
            elseif size(xs, 1) == 2  # 2D state space
                vis2d(xs, target) |> display
            end
            #scatter(chi', target') |> display # the χ-χ' scatter plot
        end

    return target
end


# there are more stable versions using QR or SVD for the application of the pseudoinv
function Kinv(chi::Matrix, kchi::Matrix, direct=true, eigenvecs=true)
    if direct
        Kinv = chi * pinv(kchi)
        e = eigen(Kinv)
        #display(e)
        T = eigenvecs ? inv(e.vectors) : I
        return T * Kinv * kchi
    else
        K = kchi * pinv(chi)
        e = eigen(K)
        # display(e)
        T = eigenvecs ? inv(e.vectors) : I
        return T * inv(K) * kchi
    end
end

### Permutation - stabilization
using Combinatorics

function stableA(A)
    n = size(A,1)
    p = argmax(permutations(1:n, n)) do p
        sum(diag(A[p, :]))
    end
    A[p,:]
end

# adjust only for the sign
function stablesign(A)
    n = size(A, 1)
    P = collect(Int, I(n))
    for i in 1:n
        P[i, i] *= sign(A[i, i])
    end
    return P
end

function stableperm(A)
    n = size(A,1)
    p = argmax(permutations(1:n, n)) do p
        sum(abs.(diag(A[p, :])))
    end
    P = collect(Int, I(n)[p,:])
    for i in 1:n
        P[p[i], i] *= sign(A[i,p[i]])
    end
    P
end

### Inner simplex approch

function K_isa(ks)
    A = innersimplexalgorithm(ks')'
    #A = stableA(A)
    A * ks
end

innersimplexalgorithm(X) = inv(X[indexmap(X), :])

function indexmap(X)
    @assert size(X,1) > size(X,2)
    # get indices of rows of X to span the largest simplex
    rnorm(x) = sqrt.(sum(abs2.(x), dims=2)) |> vec
    ind = zeros(Int, size(X, 2))
    for j in 1:length(ind)
        rownorm = rnorm(X)
        # store largest row index
        ind[j] = argmax(rownorm)
        if j == 1
            # translate to origin
            X = X .- X[ind[1], :]'
        else
            # remove subspace
            X = X / rownorm[ind[j]]
            vt = X[ind[j], :]'
            X = X - X * vt' * vt
        end
    end
    return ind
end

### Examples

function doublewelldata(nx, ny)
    d = Doublewell()
    xs = randx0(d, nx)
    ys = propagate(d, xs, ny)
    return xs, ys
end

function test_dw(; kwargs...)
    iso2(nd=2, sys=Doublewell(); kwargs...)
end

function test_tw(; kwargs...)
    iso2(nd=3, sys=Triplewell(); kwargs...)
end

### Visualization

function vismodel(model, dim)
    if dim == 1
        plot(model(collect(-1.5:.1:1.5)')')
    elseif dim == 2
        plot()
        grd = -2:.1:2
        for i in 1:3
            #paks = ["IJulia", "Plots", "LaTeXStrings", "Cubature", "StatsBase", "Molly", "StaticArrays", "Unitful", "Bio3DView", "KernelDensity", "Measurements", "Zygote"]
            #Pkg.add(paks):3
            m = [model([x,y])[i] for x in grd, y in grd]
            m = m .- StatsBase.mean(m)
            m = m ./ StatsBase.std(m)
            contour!(grd, grd, m, color=i) |> display
        end

    end
end

function vis2d(xs, fxs)
    plot()
    for f in eachrow(fxs)
        scatter!(eachrow(xs)..., marker_z=f)  # probably should use contour here, see `vismodel`
    end
    plot!()
end

### Attempt to use Flux.jl data interface for data loading
struct IsoData{T}
    xs::Array{T,2}
    ys::Array{T,3}
end

numobs(d::IsoData) = size(d.xs, 2)
getobs(d::IsoData, idx) = (d.xs[:, idx], d.ys[:, idx, :])