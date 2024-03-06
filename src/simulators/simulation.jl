## Interface for simulations

## This is supposed to contain the (Molecular) system + integrator

"""
    abstract type IsoSimulation

Abstract type representing an IsoSimulation.
Should implement the methods `getcoords`, `propagate`, `dim`

"""
abstract type IsoSimulation end

featurizer(::IsoSimulation) = identity

dim(sim::IsoSimulation) = dim(sim.sys)
getcoords(sim::IsoSimulation) = getcoords(sim.sys)
rotationhandles(sim::IsoSimulation) = rotationhandles(sim.sys)


# TODO: this should return a SimulationData
# function isodata(sim::IsoSimulation, nx, nk)
#     xs = randx0(sim, nx)
#     ys = propagate(sim, xs, nk)
#     return xs, ys
# end

@deprecate isodata SimulationData

#=
function featurizer(sim::IsoSimulation)
    if dim(sim) == 8751 # diala with water?
        return pairdistfeatures(1:66)
    else
        #n = div(dim(sim), 3)^2
        return flatpairdists
    end
end
=#

function Base.show(io::IO, mime::MIME"text/plain", sim::IsoSimulation)#
    println(io, "$(typeof(sim)) with $(dim(sim)) dimensions")
end

function savecoords(sim::IsoSimulation, data::AbstractArray, path; kwargs...)
    savecoords(sim.sys, data, path; kwargs...)
end

function randx0(sim::IsoSimulation, nx)
    x0 = reshape(getcoords(sim), :, 1)
    xs = reshape(propagate(sim, x0, nx), :, nx)
    return xs
end

###

"""
    struct SimulationData{S,D,C,F}

A struct combining a simulation with the simulated coordinates and corresponding ISOKANN trainingsdata

# Fields
- `sim::S`: The simulation object.
- `data::D`: The ISOKANN trainings data.
- `coords::C`: The orginal coordinates of the simulations.
- `featurizer::F`: A function mapping coordinates to ISOKANN features.

"""
struct SimulationData{S,D,C,F}
    sim::S
    data::D
    coords::C
    featurizer::F
end


""" 
    SimulationData(sim::IsoSimulation, nx::Int, nk::Int, featurizer=featurizer(sim))

Generates ISOKANN trainingsdata with `nx` initial points and `nk` Koopman samples each.
"""
function SimulationData(sim::IsoSimulation, nx::Int, nk::Int, featurizer=featurizer(sim))
    xs = randx0(sim, nx)
    ys = propagate(sim, xs, nk)
    coords = (xs, ys)
    data = featurizer.(coords)
    return SimulationData(sim, data, coords, featurizer)
end

gpu(d::SimulationData) = SimulationData(d.sim, gpu(d.data), gpu(d.coords), d.featurizer)
cpu(d::SimulationData) = SimulationData(d.sim, cpu(d.data), cpu(d.coords), d.featurizer)

dim(d::SimulationData) = size(d.data[1], 1)

Base.length(d::SimulationData) = size(d.data[1], 2)
Base.lastindex(d::SimulationData) = length(d)

Base.getindex(d::SimulationData, i) = SimulationData(d.sim, getobs(d.data, i), getobs(d.coords, i), d.featurizer)

MLUtils.getobs(d::SimulationData) = d.data

getcoords(d::SimulationData) = d.coords
flatend(x) = reshape(x, size(x, 1), :)

getxs(d::SimulationData) = getxs(d.data)
getys(d::SimulationData) = getys(d.data)


"""
    adddata(d::SimulationData, model, n)

χ-stratified subsampling. Select n samples amongst the provided ys/koopman points of `d` such that their χ-value according to `model` is approximately uniformly distributed and propagate them.
Returns a new `SimulationData` which has the new data appended."""
function adddata(d::SimulationData, model, n)
    y1 = d.data[2]
    c1 = d.coords[2]

    dim, nk, _ = size(y1)
    y1, c1 = flatend.((y1, c1))

    c1 = c1[:, subsample_inds(model, y1, n, keepedges=false)]
    c2 = propagate(d.sim, c1, nk)

    coords = (c1, c2)
    data = d.featurizer.(coords)

    data = lastcat.(d.data, data)
    coords = lastcat.(d.coords, coords)
    return SimulationData(d.sim, data, coords, d.featurizer)
end