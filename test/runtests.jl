using ISOKANN
#using Flux
using Test

@testset "ISOKANN.jl" begin

    @testset "IsoRun CPU" begin
        iso = ISOKANN.IsoRun(loggers=[])
        ISOKANN.run!(iso)
    end

    @testset "IsoRun GPU" begin
        using Flux
        using CUDA
        CUDA.allowscalar(false)
        iso = ISOKANN.IsoRun()
        iso.loggers = []
        ISOKANN.gpu!(iso)
        ISOKANN.run!(iso)
    end

    @testset "IsoForce" begin
        ISOKANN.IsoForce.isokann(usecontrol=true)
    end
#=
    @testset "IsoForce (deprecated)" begin
        using ISOKANN.IsoForce: test_GirsanovSDE, test_optcontrol, isokann, Doublewell
        test_GirsanovSDE()
        test_optcontrol()

        @test_broken @time isokann()
        @test_broken @time isokann(dynamics = Doublewell(dim=2))
    end
=#
end
