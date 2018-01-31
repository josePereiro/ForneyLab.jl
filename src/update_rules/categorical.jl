@sumProductRule(:node_type     => Categorical,
                :outbound_type => Message{Categorical},
                :inbound_types => (Void, Message{PointMass}),
                :name          => SPCategoricalOutVP)

@variationalRule(:node_type     => Categorical,
                 :outbound_type => Message{Categorical},
                 :inbound_types => (Void, ProbabilityDistribution),
                 :name          => VBCategoricalOut)

@variationalRule(:node_type     => Categorical,
                 :outbound_type => Message{Dirichlet},
                 :inbound_types => (ProbabilityDistribution, Void),
                 :name          => VBCategoricalIn1)