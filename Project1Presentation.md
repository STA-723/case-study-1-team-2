Case Study 1
========================================================
author: Emily Gentles,  Phuc Nguyen,  Joseph Lawson
date: 1/21/2020
autosize: true

Case Discussion
========================================================

- Data obtained from a subset of women enrolled in the CPP during pregnancy
- Data issues: uncertainty, inflation, and missingness

**Goal**: Assess how exposure to DDE and PCBs relates to the risk of premature delivery

Graph?

Exploratory Data Analysis
========================================================



Analysis
========================================================

- Keep obs with Gest. Age 44 or less
- Categorize Gest. Age to assess risks of pre-term births of varying severity
- Impute score data with MICE
- Remove obs with missing PCE, DDE

***



```
Likelihood ratio tests of ordinal regression models

Response: gestord
                                                                                              Model
1 center + dde + PCB1 + triglycerides + maternal_age + smoking_status + cholesterol + albuminTested
2 center + dde * PCB1 + triglycerides + maternal_age + smoking_status + cholesterol + albuminTested
  Resid. df Resid. Dev   Test    Df  LR stat.   Pr(Chi)
1      2291   2754.590                                 
2      2290   2754.307 1 vs 2     1 0.2833548 0.5945108
```

```
Likelihood ratio tests of ordinal regression models

Response: gestord
                                                                                                              Model
1                 center + dde + PCB1 + triglycerides + maternal_age + smoking_status + cholesterol + albuminTested
2 center + dde * triglycerides + PCB1 * triglycerides + maternal_age + smoking_status + cholesterol + albuminTested
  Resid. df Resid. Dev   Test    Df LR stat.   Pr(Chi)
1      2291   2754.590                                
2      2289   2752.329 1 vs 2     2 2.261289 0.3228252
```

Results
========================================================

Discussion
========================================================
