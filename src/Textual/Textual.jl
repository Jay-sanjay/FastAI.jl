module Textual


using ..FastAI
using ..FastAI:
    # blocks
    Block, WrapperBlock, AbstractBlock, OneHotTensor, OneHotTensorMulti, Label,
    LabelMulti, wrapped, Continuous, getencodings, getblocks, encodetarget, encodeinput,
    # encodings
    Encoding, StatefulEncoding, OneHot,
    # visualization
    ShowText,
    # other
    Context, Training, Validation

import Requires: @require

using InlineTest
using Random

include("recipes.jl")
include("blocks/text.jl")
include("transform.jl")

function __init__()
    _registerrecipes()
end

export Paragraph
end