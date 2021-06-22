
"""
    finetune!(learner, nepochs[, base_lr = 0.002; kwargs...])

Behaves as [`fastai.Learner.fine_tune`](https://github.com/fastai/fastai/blob/master/fastai/callback/schedule.py#L151)
"""
function finetune!(
        learner,
        nepochs,
        base_lr = 0.002;
        freezeepochs = 1,
        grouper = nothing,
        lr_mult = 10.,
        div = 5,
        pct_start = 0.3,
        kwargs...)

    # Parse arguments and throw helpful errors
    grouper = isnothing(grouper) ? _init_grouper(learner.model) : grouper

    FluxTraining.initlearner!(learner, [TrainingPhase()])

    # Freeze backbone and train head
    foptim = freezeoptimizer(learner.optimizer, grouper, learner.model)
    withfields(learner, optimizer = foptim) do
        fitonecycle!(learner, freezeepochs, base_lr, pct_start=0.99; kwargs...)
    end


    # Use discriminative learning rates on backbone and train some more
    doptim = discrlr_optimizer(learner.optimizer, grouper, learner.model, lr_mult)
    withfields(learner, optimizer = doptim) do
        base_lr /= 2
        fitonecycle!(
            learner, nepochs, base_lr;
            div = div, pct_start = pct_start, kwargs...)
    end

    return learner
end


function freezeoptimizer(optim, grouper, model)
    paramgroups = ParamGroups(grouper, model)
    return Optimiser(
        DiscriminativeLRs(paramgroups, Dict(1 => 0., 2 => 1.)),
        optim,
    )
end


function discrlr_optimizer(optim, grouper, model, factor)
    paramgroups = ParamGroups(grouper, model)
    return Optimiser(
        DiscriminativeLRs(paramgroups, Dict(1 => factor, 2 => 1.)),
        optim,
    )
end


function _init_grouper(model)
    if !(model isa Chain)
        error(
            "Cannot freeze `learner.model` automatically since it is not a `Chain`.
            Please provide a `ParamGrouper` with the `grouper` keyword argument.
            The `grouper` should assign groups `1` (backbone) and `2` (head).
            ")
    else
        return IndexGrouper([1:length(model)-1, length(model)])
    end
end