
# Neural Network model for mol


function featureinds(sim::IsoSimulation)
    if dim(sim) == 8751
        1:66
    else
        1:dim(sim)
    end
end

function selectrows(x, inds)
    d, s... = size(x)
    x = reshape(x, d, :)
    x = x[inds, :]
    x = reshape(x, :, s...)
end

function featurizer(sim)
    inds = featureinds(sim)
    function features(x)
        x = selectrows(x, inds)
        x = flatpairdists(x)
        return x
    end
end

" Neural Network model for molecules, using pairwise distances as first layer "
function pairnet(sim::IsoSimulation, layers=3)
    n = div(length(featureinds(sim)), 3)^2
    pairnet(n, layers, featurizer(sim))
end

function pairnet(n=22, layers=3, features=identity, lastactivation=identity)
    nn = Flux.Chain(
        x -> Float32.(x),
        features,
        [Flux.Dense(
            round(Int, n^(l / layers)),
            round(Int, n^((l - 1) / layers)),
            Flux.sigmoid)
         for l in layers:-1:2]...,
        Flux.Dense(round(Int, n^(1 / layers)), 1, lastactivation),
    )
    return nn
end

