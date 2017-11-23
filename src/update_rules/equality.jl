function matchPermutedCanonical(input_types::Vector{DataType}, outbound_type::DataType)
    # TODO: this implementation only works when the inbound types match the outbound type
    void_inputs = 0
    message_inputs = 0
    for input_type in input_types
        if input_type == Void
            void_inputs += 1
        elseif matches(input_type, outbound_type)
            message_inputs += 1
        end
    end
    
    return (void_inputs == 1) && (message_inputs == 2)
end

type SPEqualityGaussian <: SumProductRule{Equality} end
outboundType(::Type{SPEqualityGaussian}) = Message{Gaussian}
isApplicable(::Type{SPEqualityGaussian}, input_types::Vector{DataType}) = matchPermutedCanonical(input_types, Message{Gaussian})

type SPEqualityGammaWishart <: SumProductRule{Equality} end
outboundType(::Type{SPEqualityGammaWishart}) = Message{Union{Gamma, Wishart}}
isApplicable(::Type{SPEqualityGammaWishart}, input_types::Vector{DataType}) = matchPermutedCanonical(input_types, Message{Union{Gamma, Wishart}})

type SPEqualityBernoulli <: SumProductRule{Equality} end
outboundType(::Type{SPEqualityBernoulli}) = Message{Bernoulli}
isApplicable(::Type{SPEqualityBernoulli}, input_types::Vector{DataType}) = matchPermutedCanonical(input_types, Message{Bernoulli})

type SPEqualityBeta <: SumProductRule{Equality} end
outboundType(::Type{SPEqualityBeta}) = Message{Beta}
isApplicable(::Type{SPEqualityBeta}, input_types::Vector{DataType}) = matchPermutedCanonical(input_types, Message{Beta})

type SPEqualityCategorical <: SumProductRule{Equality} end
outboundType(::Type{SPEqualityCategorical}) = Message{Categorical}
isApplicable(::Type{SPEqualityCategorical}, input_types::Vector{DataType}) = matchPermutedCanonical(input_types, Message{Categorical})

type SPEqualityDirichlet <: SumProductRule{Equality} end
outboundType(::Type{SPEqualityDirichlet}) = Message{Dirichlet}
isApplicable(::Type{SPEqualityDirichlet}, input_types::Vector{DataType}) = matchPermutedCanonical(input_types, Message{Dirichlet})

type SPEqualityPointMass <: SumProductRule{Equality} end
outboundType(::Type{SPEqualityPointMass}) = Message{PointMass}
function isApplicable(::Type{SPEqualityPointMass}, input_types::Vector{DataType})
    void_inputs = 0
    soft_inputs = 0
    point_mass_inputs = 0
    for input_type in input_types
        if input_type == Void
            void_inputs += 1
        elseif matches(input_type, Message{SoftFactor})
            soft_inputs += 1
        elseif matches(input_type, Message{PointMass})
            point_mass_inputs += 1
        end
    end
    
    return (void_inputs == 1) && (soft_inputs == 1) && (point_mass_inputs == 1)
end
