var documenterSearchIndex = {"docs":
[{"location":"development/#Development","page":"Development","title":"Development","text":"","category":"section"},{"location":"development/","page":"Development","title":"Development","text":"clone the repository with","category":"page"},{"location":"development/","page":"Development","title":"Development","text":"git clone git@github.com:axsk/ISOKANN.jl.git","category":"page"},{"location":"development/","page":"Development","title":"Development","text":"and create your own branch with","category":"page"},{"location":"development/","page":"Development","title":"Development","text":"git checkout -b mynewcoolbranch.","category":"page"},{"location":"development/","page":"Development","title":"Development","text":"Install julia, preferrably with juliaup (at least version 1.9). We recommend using Revise for a smoother dev experience.","category":"page"},{"location":"development/","page":"Development","title":"Development","text":"Dont forget to activate the project with ]activate . and instantiate the dependencies with ]instantiate. You should then be able to run the tests with ]test or start using ISOKANN.","category":"page"},{"location":"#ISOKANN.jl","page":"ISOKANN.jl","title":"ISOKANN.jl","text":"","category":"section"},{"location":"","page":"ISOKANN.jl","title":"ISOKANN.jl","text":"Documentation for ISOKANN.jl","category":"page"},{"location":"","page":"ISOKANN.jl","title":"ISOKANN.jl","text":"CurrentModule = ISOKANN","category":"page"},{"location":"","page":"ISOKANN.jl","title":"ISOKANN.jl","text":"IsoRun\nISOKANN.run!\nMollyLangevin\npropagate","category":"page"},{"location":"#ISOKANN.IsoRun","page":"ISOKANN.jl","title":"ISOKANN.IsoRun","text":"struct IsoRun{T}\n\nThe IsoRun struct represents a configuration for running the Isomolly algorithm.\n\nFields\n\nnd::Integer: Number of outer data subsampling steps.\nnx::Integer: Size of subdata set.\nnp::Integer: Number of power iterations with the same subdata.\nnl::Integer: Number of weight updates with the same power iteration step.\nnres::Integer: Resample new data every n outer steps.\nny::Integer: Number of new points to sample.\nnk::Integer: Number of Koopman points to sample.\nnxmax::Integer: Maximal number of x data points.\nsim: Simulation object.\nmodel: Model object.\nopt: Optimization algorithm.\ndata::T: Data object.\nlosses: Vector to store loss values.\nloggers::Vector: Vector of loggers.\n\n\n\n\n\n","category":"type"},{"location":"#ISOKANN.run!","page":"ISOKANN.jl","title":"ISOKANN.run!","text":"run the given IsoRun object \n\n\n\n\n\n","category":"function"},{"location":"#ISOKANN.MollyLangevin","page":"ISOKANN.jl","title":"ISOKANN.MollyLangevin","text":"struct MollyLangevin{S<:Molly.System} <: IsoSimulation\n\nThe MollyLangevin struct represents a Langevin dynamics simulation for the Molly package.     It contains the system as well as the integration parameters.\n\nFields\n\nsys::S: The system to be simulated.\ntemp::Float64: The temperature of the simulation in Kelvin. Default is 298.0 K.\ngamma::Float64: The friction coefficient for the Langevin dynamics. Default is 1.0.\ndt::Float64: The time step size in picoseconds. Default is 2e-3 ps.\nT::Float64: The total simulation time in picoseconds. Default is 2e-1 ps.\nn_threads::Int: The number of threads for force computations. Default is 1.\n\n\n\n\n\n","category":"type"},{"location":"#ISOKANN.propagate","page":"ISOKANN.jl","title":"ISOKANN.propagate","text":"propagate(ms::MollyLangevin, x0::AbstractMatrix, ny)\n\nBurst simulation of the MollyLangeving system ms. Propagates ny samples for each initial position provided in the columns of x0.\n\nArguments\n\nms::MollyLangevin: The MollyLangevin solver object.\nx0::AbstractMatrix: The initial positions matrix.\nny: The number of trajectories per initial condition.\n\nReturns\n\nys: A 3-dimensional array of size (dim(ms), nx, ny) containing the propagated solutions.\n\n\n\n\n\n","category":"function"},{"location":"","page":"ISOKANN.jl","title":"ISOKANN.jl","text":"Modules = [ISOKANN]\nPrivate = false\nOrder = [:function]","category":"page"},{"location":"#ISOKANN.PDB_1UAO-Tuple{}","page":"ISOKANN.jl","title":"ISOKANN.PDB_1UAO","text":"Create a Molly system for the small Chignolin protein \n\n\n\n\n\n","category":"method"},{"location":"#ISOKANN.PDB_ACEMD-Tuple{}","page":"ISOKANN.jl","title":"ISOKANN.PDB_ACEMD","text":"Create a Molly system for the alanine dipeptide without solvent \n\n\n\n\n\n","category":"method"},{"location":"#ISOKANN.PDB_diala_water-Tuple{}","page":"ISOKANN.jl","title":"ISOKANN.PDB_diala_water","text":"Create a Molly system for the alanine dipeptide with water \n\n\n\n\n\n","category":"method"},{"location":"#ISOKANN.pairnet","page":"ISOKANN.jl","title":"ISOKANN.pairnet","text":"Flux neural network model with layers fully connected layers using the  corresponding simulations features as first layers \n\n\n\n\n\n","category":"function"},{"location":"#ISOKANN.pairnet-2","page":"ISOKANN.jl","title":"ISOKANN.pairnet","text":"Fully connected neural network with layers layers from n to nout dimensions. features allows to pass a featurizer as preprocessor,  activation determines the activation function for each but the last layer lastactivation can be used to modify the last layers activation function \n\n\n\n\n\n","category":"function"},{"location":"#ISOKANN.propagate-Tuple{MollyLangevin, AbstractMatrix, Any}","page":"ISOKANN.jl","title":"ISOKANN.propagate","text":"propagate(ms::MollyLangevin, x0::AbstractMatrix, ny)\n\nBurst simulation of the MollyLangeving system ms. Propagates ny samples for each initial position provided in the columns of x0.\n\nArguments\n\nms::MollyLangevin: The MollyLangevin solver object.\nx0::AbstractMatrix: The initial positions matrix.\nny: The number of trajectories per initial condition.\n\nReturns\n\nys: A 3-dimensional array of size (dim(ms), nx, ny) containing the propagated solutions.\n\n\n\n\n\n","category":"method"},{"location":"#ISOKANN.reactionpath-Tuple{Any, Any, Any}","page":"ISOKANN.jl","title":"ISOKANN.reactionpath","text":"compute the reactionpath for the simulation sim starting in x0 along the gradient of the function provided by chi\n\nOptional arguments: extrapolate: walk beyond the interval limits orth: factor for the force orthogonal to the chi gradient solver: the ODE solver to use dt: the timestep size kwargs...: Keyword arguments passed to the solve method\n\n\n\n\n\n","category":"method"},{"location":"#ISOKANN.run!-Tuple{IsoRun}","page":"ISOKANN.jl","title":"ISOKANN.run!","text":"run the given IsoRun object \n\n\n\n\n\n","category":"method"},{"location":"#ISOKANN.solve-Tuple{Any}","page":"ISOKANN.jl","title":"ISOKANN.solve","text":"sample a single trajectory for the given system \n\n\n\n\n\n","category":"method"}]
}
