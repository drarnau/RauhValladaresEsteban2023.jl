# RauhValladaresEsteban2023.jl
[This package](https://github.com/drarnau/RauhValladaresEsteban2023) provides all codes to replicate the main exhibits of [_On the Black-White Gaps in Labor Supply and Earnings over the Lifecycle in the US_](https://arnau.eu/RaceGap.pdf) by [Christopher Rauh](https://sites.google.com/site/econrauh/) and [Arnau Valladares-Esteban](https://arnau.eu/).

The user needs to download the raw data from the [National Longitudinal Survey of the Youth 1979](https://www.nlsinfo.org/content/cohorts/nlsy79) and store it in the folder `stata/` following the naming details in `stata/main.do`.

## `produce_exhibits.jl`
Execute this file to produce all the figures and tables displayed below and reported in the paper.

As a reference, using the following CPU:
```shell
Architecture:                       x86_64
CPU op-mode(s):                     32-bit, 64-bit
Byte Order:                         Little Endian
Address sizes:                      39 bits physical, 48 bits virtual
CPU(s):                             8
On-line CPU(s) list:                0-7
Thread(s) per core:                 2
Core(s) per socket:                 4
Socket(s):                          1
NUMA node(s):                       1
Vendor ID:                          GenuineIntel
CPU family:                         6
Model:                              158
Model name:                         Intel(R) Core(TM) i7-7700 CPU @ 3.60GHz
Stepping:                           9
CPU MHz:                            800.036
CPU max MHz:                        4200.0000
CPU min MHz:                        800.0000
BogoMIPS:                           7200.00
Virtualisation:                     VT-x
L1d cache:                          128 KiB
L1i cache:                          128 KiB
L2 cache:                           1 MiB
L3 cache:                           8 MiB
NUMA node0 CPU(s):                  0-7
```
Running the following OS:
```shell
Operating System: Ubuntu 20.04.2 LTS
Kernel: Linux 5.4.0-167-generic
Architecture: x86-64
```

The total execution time for `produce_exhibits.jl` is of around 4 hours.

## Model Documentation
[![Docs][docs-img]][docs-url]

[docs-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-url]: https://drarnau.github.io/RauhValladaresEsteban2023.jl/

#### Figure 1: Employment, hours worked, cumulative experience, and annual earnings over the lifecycle by Black and White men
![](figures/d_employed_hours_exp_earnings.png)

#### Table 1: Test of parallelism in earnings experience profiles between Black and White men
See `stata/main.do`.

#### Figure 2: Mean annual earnings over the lifecycle for Black and White men that do not experience any non-employment spell
![](figures/d_earnings_byage_byhours.png)

#### Figure 3: Distribution of AFQT deciles by race
![](figures/d_afqt_distribution.png)

#### Figure 4: Hourly earnings conditional on working by race for AFQT deciles over the lifecycle
![](figures/d_hearnings_byagroups.png)

#### [Table 2: Regressing hourly earnings conditional on working on race and cumulative labor market experience for AFQT deciles 1-5](tables/hearnings_1.pdf)
<object data="tables/hearnings_1.pdf" type="application/pdf" width="100%">
    <embed src="tables/hearnings_1.pdf">
        <p>The PDF cannot be displayed in the GitHub README file. Please click here to view it: <a href="tables/hearnings_1.pdf">View PDF</a>.</p>
    </embed>
</object>

#### Figure 5: Employment rates over the lifecycle by race and AFQT deciles
![](figures/d_employed_byagroups.png)

#### Figure 6: Mean hourly wages over the lifecycle conditional on working by AFQT/ability decile (data vs. model)
![](figures/mvsd_wage_dataLS.png)

#### Figure 7: Hours worked over the lifecycle conditional on employment for AFQT/ability groupings by race (data vs. model)
![](figures/mvsd_hours_Black_1.png)
![](figures/mvsd_hours_White_1.png)

#### Figure 8: Employment rates over the lifecycle by AFQT/ability decile (data vs. model)
![](figures/mvsd_employed_Black_1.png)
![](figures/mvsd_employed_White_1.png)

#### [Table 5: How racial gaps respond to assigning characteristics of White men to Black men](tables/counterfactuals.pdf)
<object data="tables/counterfactuals.pdf" type="application/pdf" width="100%">
    <embed src="tables/counterfactuals.pdf">
        <p>The PDF cannot be displayed in the GitHub README file. Please click here to view it: <a href="tables/counterfactuals.pdf">View PDF</a>.</p>
    </embed>
</object>

#### Figure 9: Racial gaps over the lifecycle in the data: benchmark and counterfactual of equal initial conditions
| Hourly Wage                   | Employment                        |
|:-----------------------------:|:---------------------------------:|
| ![](figures/mvsdcf_wage.png)  | ![](figures/mvsdcf_employed.png)  |

#### Figure B.1: Annual (left) and hourly (right) log labor income over the lifecycle
![](figures/d_logearnings.png)

#### [Table B.1: Regressing hourly earnings conditional on working on race and cumulative labor market experience by AFQT deciles](tables/hearnings_2.pdf)
<object data="tables/hearnings_2.pdf" type="application/pdf" width="100%">
    <embed src="tables/hearnings_2.pdf">
        <p>The PDF cannot be displayed in the GitHub README file. Please click here to view it: <a href="tables/hearnings_2.pdf">View PDF</a>.</p>
    </embed>
</object>

#### Figure B.2: Hours worked conditional on working by race for AFQT deciles over the lifecycle
![](figures/d_hours_byagroups.png)

#### Figure B.3: Mean annual earnings over the lifecycle conditional on working for Black and White men that experience no non-employment spells, by education groups
![](figures/d_earnings_byedu.png)

#### Figure B.4: Mean annual earnings by cumulative hours worked conditional on working for Black and White men that experience no non-employment spells, by education groups
![](figures/d_earnings_byedu_byhours.png)

#### Figure B.5: AFQT score distributions by race and education (absolute)
![](figures/d_afqt_distribution_byedu_abs.png)

#### Figure B.6: AFQT score distributions by race and education (relative)
![](figures/d_afqt_distribution_byedu_rel.png)

#### Figure B.7: Hourly wages conditional on working for AFQT score groupings by race over the lifecycle for men without non-employment spells
![](figures/d_hearnings_byagroups_alwaysE.png)

#### Figure B.8: Mean individual fixed effect (left) and experience effect (right) for hourly wage by race and AFQT decile
![](figures/d_hearnings_FE.png)

#### Figure B.9: Distribution of individual fixed effects (left) and experience effects (right) for hourly wage by race and AFQT decile
![](figures/d_hearnings_FE_distribution.png)

#### Figure B.10: Mean hourly wages at age 23
![](figures/d_hearnings0_bydeciles.png)

#### Figure B.11: Mean hourly wages at age 23 for Blacks and Whites
![](figures/d_hearnings0_bydeciles_byrace.png)

#### Figure B.12: Yearly earnings for AFQT/ability groupings by race over the lifecycle (data vs. model
![](figures/mvsd_wage_Black_1.png)
![](figures/mvsd_wage_White_1.png)

#### Figure B.13: Employment rates for AFQT/ability deciles 5-10 by race over the lifecycle (data vs. model
![](figures/mvsd_employed_Black_2.png)
![](figures/mvsd_employed_White_2.png)

#### Figure B.14: Hours worked conditional on working for AFQT/ability deciles 5-10 by race over the lifecycle (data vs. model)
![](figures/mvsd_hours_Black_2.png)
![](figures/mvsd_hours_White_2.png)
