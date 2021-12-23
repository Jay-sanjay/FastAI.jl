
"""
    Continuous(size) <: Block

`Block` for collections of numbers. `obs` is a valid observation
if it's length is `size` and contains `Number`s.
"""
struct Continuous <: Block
    size::Int
end

function checkblock(block::Continuous, x)
    block.size == length(x) && eltype(x) <: Number
end

mockblock(block::Continuous) = rand(block.size)


function blocklossfn(outblock::Continuous, yblock::Continuous)
    outblock.size == yblock.size || error("Sizes of $outblock and $yblock differ!")
    return Flux.Losses.mse
end


function invariant_checkblock(block::Continuous; blockname = "block", obsname = "obs")
    return SequenceInvariant(
        [
            BooleanInvariant(
                obs -> obs isa AbstractVector,
                name = "`$obsname` should be an `AbstractVector`",
                messagefn = obs -> """`$obsname` should be an `AbstractVector`, instead
                got type `$(typeof(obs))`.
                """
            ),
            BooleanInvariant(
                obs -> length(obs) == block.size,
                name = "length(`$obsname`) should be $(block.size)",
                messagefn = obs -> """`$obsname` should have $(block.size) features, instead
                found a vector with $(length(obs)) features.
                """
            ),
            BooleanInvariant(
                obs -> eltype(obs) <: Number,
                name = "`eltype($obsname)` should be a subtype of `Number`",
                messagefn = obs -> """Found a non-numerical element type $(eltype(obs))"""
            ),
        ],
        "`$obsname` should be a valid `$(summary(block))`",
        "",
    )
end


@testset "Continuous [block]" begin
    inv = invariant_checkblock(Continuous(5))

    @test check(inv, zeros(5))
    @test !(check(inv, "hi"))
    @test !(check(inv, ["hi"]))
    @test !(check(inv, [5]))
end