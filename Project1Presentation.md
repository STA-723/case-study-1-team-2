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



|               |      2.5 %|     97.5 %|
|:--------------|----------:|----------:|
|center15       | -2.3928007| -1.0027265|
|center31       | -1.3723401|  0.3501201|
|center37       | -2.2004056| -0.8891897|
|center45       | -1.6307711| -0.2173480|
|center5        | -1.1686918|  0.1024897|
|center50       | -1.5584708| -0.0776787|
|center55       | -1.9905098| -0.5531251|
|center60       | -1.8140746| -0.3106809|
|center66       | -1.6273146| -0.3483217|
|center71       | -1.3632321|  0.0923675|
|center82       | -2.2808274| -0.8909285|
|dde            | -0.0102660|  0.0001066|
|PCB1           | -0.1237045| -0.0290820|
|triglycerides  | -0.0034350| -0.0008514|
|maternal_age   | -0.0117745|  0.0219526|
|smoking_status | -0.3575937|  0.0526102|
|cholesterol    |  0.0007680|  0.0041433|
|albuminTested  |  0.3189531|  1.3224529|

Results
========================================================

Discussion
========================================================
