# Model
Utility-maximizing agents live for $j=1,\dots,J$ discrete periods.
The value of being alive in period $J+1$ is normalized to zero.
Generally speaking, parameters associated with human capital accumulation are universal, while preference parameters are race specific and indexed by $r \in \{ \text{Black, White} \}$.

Upon entering the model, each agent draws a realization of their initial level of human capital ($h_1$) and permanent ability level ($a$).
Ability plays a crucial role in determining an agent's proficiency in accumulating human capital ($h$): low-ability agents accumulate less human capital per hour worked.

Each period, agents are endowed with one unit of time, which they can distribute between staying at home or working.
The utility of working agents ($u^W$) is given by:
```math
  u^W(h,n) = \omega \cdot h \cdot n + \psi^r \cdot h \cdot \frac{(1-n)^{1-\gamma^r}}{1-\gamma^r}\text{,}
```
where $\omega$ is the exogenous wage rate, $h$ is the level of human capital, $n$ is the fraction of available hours that the agent works, $\psi^r$ is the weight of leisure in the utility function, and $\gamma^r$ determines the curvature of the utility of leisure.
We define the utility of staying at home ($u_j^H$) in terms of age $j$ as:
```math
\begin{aligned}
  u_j^H(h, \kappa) &=
  \frac{\psi^r}{1-\gamma^r} \cdot h^{\eta^r} \cdot e^{(\kappa_0^r + \kappa_1^r \cdot j + \kappa_2^r \cdot j^2 +  \kappa)}\text{,} \\
  \kappa &\sim N(0, 1)\text{.}
\end{aligned}
```
where $\eta^r$ determines the curvature, which could be interpreted as efficiency in the production of stay-at-home utility.
$\kappa_0^r$, $\kappa_1^r$, and $\kappa_2^r$ are the age-dependent deterministic components, and $\kappa$ is the realization of an i.i.d. shock with mean zero and a normalized standard deviation equal to 1 drawn every period.
We use a polynomial of degree two in age to replicate the shape of the employment rate we observe in the data.
The fact that the utility of staying at home depends on age can be interpreted as proxying factors that affect labor supply and change over the lifecycle, such as household composition, health, or networks.

We express the problem solved by the agents in recursive form and indicate any value associated with the subsequent period by marking it with a prime.
Let us denote the value of staying at home as $H_j(h,\kappa; a)$, the value of working as $W_j(h,\kappa; a)$, and the decision to work or stay at home as:
```math
  V_j(h,\kappa; a) = \max \{W_j(h,\kappa; a), H_j(h,\kappa; a)\}\text{.}
```
The value of staying at home is given by:
```math
\begin{aligned}
  H_j(h,\kappa; a) = \quad & u_j^H(h,\kappa) + \beta \mathbb{E}_{\kappa'} V_{j+1}(h',\kappa';a)\text{,} \\
  \text{s.t.} \quad & h' = (1-\delta)h \text{,}
\end{aligned}
```
where $\beta$ is the discount factor.
The value of working is given by:
```math
\begin{aligned}
  W_j(h,\kappa; a) = \max_{h,n} \quad & u^W(h,n) + \beta \mathbb{E}_{\kappa'} V_{j+1}(h',\kappa';a)\text{,} \\
  \text{s.t.} \quad & h' = (1-\delta)h + a n^\phi \text{,} \\
  \quad & 0 \leq n \leq 1\text{.}
\end{aligned}
```
The function $h'$ defines how human capital evolves over the lifecycle.
The parameter $\phi$ defines the curvature of human capital next period with respect to time spent working.
We assume that human capital depreciates at a constant rate $\delta$.
We model human capital accumulation as a learning-by-doing technology.
The labor supply decision trades off less leisure today versus more income today and higher human capital in the future.
