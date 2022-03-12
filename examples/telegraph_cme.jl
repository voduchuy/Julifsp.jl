using NumCME
using BenchmarkTools
using Sundials: CVODE_BDF

## Bursting gene model 
𝕊 = [[-1, 1, 0] [1, -1, 0] [0, 0, 1] [0, 0, -1]]
x₀ = [1, 0, 0]
k₀₁ = 0.05
k₁₀ = 0.1
λ = 5.0
γ = 0.5

a1 = propensity() do x, p
    p[1] * x[1]
end
a2 = propensity() do x, p
    p[2] * x[2]
end
a3 = propensity() do x, p
    p[3] * x[2]
end
a4 = propensity() do x, p
    p[4] * x[3]
end

θ = [k₀₁, k₁₀, λ, γ]
model = CmeModel(𝕊, [a1,a2,a3,a4], θ)
𝔛₀ = StateSpaceSparse(model.stoich_matrix, x₀)
expand!(𝔛₀, 10)
p0 = FspVectorSparse(𝔛₀, [x₀=>1.0])
tspan = (0.0, 300.0)

fullrstepfsp = AdaptiveFspSparse(
    ode_method = CVODE_BDF(linear_solver=:GMRES),
    space_adapter = RStepAdapter(5, 10, true)
)
selectiverstepfsp = AdaptiveFspSparse(
    ode_method = CVODE_BDF(linear_solver=:GMRES),
    space_adapter = SelectiveRStepAdapter(5, 10, true)
)
@btime fspsol1 = solve(model, p0, tspan, fullrstepfsp, saveat=0.0:20.0:300.0);
@btime fspsol2 = solve(model, p0, tspan, selectiverstepfsp, saveat=0.0:20.0:300.0);




