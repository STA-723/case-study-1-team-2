---
  title: "Case Study 1"
author: 
  - "Emily Gentles"
- "Phuc Nguyen"
- "Joseph Lawson"
date: "Jan 21, 2020"
output: beamer_presentation
---
  
  ```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE)
```

# Case Discussion

- Data obtained from a subset of women enrolled in the CPP during pregnancy
- Data issues: uncertainty, inflation, and missingness

**Goal**: Assess how exposure to DDE and PCBs relates to the risk of premature delivery

Graph?
  
  # Exploratory Data Analysis
  
  
  ```{r}

```

# Analysis

- Ordinal Logistic Regression with Term, Preterm, and Severely Preterm Gest. Categories
- Keep obs with Gest. Age 44 or less
- Impute score data with MICE to check usefulness
- Remove obs with missing PCE value
- Include blood cholesterol/triglyceride levels, as well as center and SES/Lifestyle metrics


```{r, echo=FALSE, eval = TRUE, warning = FALSE, message = FALSE}
library(tidyverse)
library(mice)
library(nnet)
library(corrplot)
library(quantreg)
library(MASS)
library(effects)
library(knitr)
library(tigerstats)
set.seed(43)

Long <- readRDS("Longnecker.rds")
Long <- Long %>% mutate(albuminTested = ifelse(is.na(albumin), 0, 1)) %>% filter(gestational_age <= 44) %>% 
  filter(!is.na(pcb_028)) %>% dplyr::select(-albumin)


Long = Long %>% mutate(termCat = cut(gestational_age, c(breaks = c(0, 32, 37 ,45))), center = as.character(center),
                       pcb = pcb_028 + pcb_052 + pcb_074 + pcb_105 + pcb_118 + pcb_153 + pcb_170 +
                         pcb_138 + pcb_180 + pcb_194 + pcb_203,
                       # ed_norm = qnorm(score_education / 100),
                       # inc_norm = qnorm(score_education / 100),
                       # occ_norm = qnorm(score_occupation / 100),
                       dde.cut = cut(dde, breaks = 5),
                       pcb.cut = cut(pcb, breaks = 5),
                       gestord = factor(termCat, ordered = TRUE)
) %>% filter(!is.na(pcb))


# ADD PRINCIPLE COMPONENTs
pcb_mat = as.matrix(Long %>% dplyr::select(contains("pcb_")))
min_pcb <- min(pcb_mat[pcb_mat > 0])
pcb_mat[pcb_mat == 0] <- min_pcb / 2
pcb_mat <- apply(pcb_mat, 2, log)
pcb.pr = prcomp(pcb_mat, center = T, scale = T)

Long = Long %>% mutate(logPCB1 = -pcb.pr$x[,1], logPCB2 = pcb.pr$x[,2], logPCB3 = pcb.pr$x[,3])

##

# Long_Score_NA_rm = Long %>% filter(!is.na(score_education + score_occupation + score_income))
# modordscore = polr(gestord ~ center + log(dde) + log(pcb) + score_education + score_occupation + score_education + log(triglycerides) + maternal_age + smoking_status + cholesterol + albuminTested, data = Long_Score_NA_rm)
# modordscorecomp = polr(gestord~ center+log(dde) + log(pcb)+log(triglycerides) + maternal_age + smoking_status + cholesterol + albuminTested, data = Long_Score_NA_rm)
# anova(modordscore, modordscorecomp)
# 
# modordcenter = polr(gestord~ center*log(dde) + center*log(pcb) + log(triglycerides) + maternal_age + smoking_status + cholesterol + albuminTested, data = Long)
# modord = polr(gestord~ center+log(dde) + log(pcb)+log(triglycerides)  + maternal_age + smoking_status + cholesterol + albuminTested, data = Long)
# summary(modord)
# anova(modord, modordcenter)


### BASE MODEL

Long.Base.Mod = polr(gestord~ center + log(dde) + logPCB1 + log(triglycerides)  + maternal_age + smoking_status + log(cholesterol) + albuminTested, data = Long,
                     Hess = T)
# summary(Long.Base.Mod)
Base.Confint = confint(Long.Base.Mod)
# Base.Confint
# knitr::kable(Base.Confint, "latex")

### PCA Analysis ###

Long.PCA.1.2.3 = polr(gestord~ center + log(dde) + logPCB1 + logPCB2 + logPCB3 + log(triglycerides)  + maternal_age + smoking_status + log(cholesterol) + albuminTested, data = Long)


# Long.PCA.logged = polr(gestord~ center + log(dde)*log(logPCB1) + log(triglycerides)  + maternal_age + smoking_status + cholesterol + albuminTested, data = Long)


PCA.anova = anova(Long.Base.Mod, Long.PCA.1.2.3)

## Second and third components add very little


#############################################
### MICE with ORDLOG - check score usefulness
#############################################

# impLong = mice(Long, printFlag = F)
impLong = mice(Long %>% mutate(ldde = log(dde), ltrig = log(triglycerides), lchol = log(cholesterol)) %>% 
                 dplyr::select(gestord,center, score_occupation, score_education, score_income, ldde, logPCB1,
                               ltrig, maternal_age, smoking_status, lchol,
                               albuminTested), printFlag = F)
imp.OL.Mod = with(impLong, polr(gestord ~ center + score_occupation +score_education +
                                  score_income + ldde + logPCB1 + 
                                  ltrig  + maternal_age + smoking_status + 
                                  lchol + albuminTested, Hess = T))

imp.OL.Mod.wo.score = with(impLong, polr(gestord ~ center  + ldde + logPCB1 + 
                                           ltrig  + maternal_age + smoking_status + 
                                           lchol + albuminTested, Hess = T))

score.p.value = pool.compare(imp.OL.Mod, imp.OL.Mod.wo.score)$pvalue

MICE.summary = summary(pool(imp.OL.Mod))

## Strong evidence that score does not add anything


##########################################
###### Check Center Interactions/inclusion
##########################################

center.inter.mod = polr(gestord~ center*(log(dde) + logPCB1 + log(triglycerides)  + maternal_age + smoking_status + log(cholesterol) + albuminTested), data = Long, Hess = T)

Center.Inter.Anova = anova(center.inter.mod, Long.Base.Mod)

## Note that center interaction not significant

no.center.mod = polr(gestord~ log(dde) + logPCB1 + log(triglycerides)  + 
                       maternal_age + smoking_status + log(cholesterol) + albuminTested, data = Long, Hess = T)

Center.Inclusion.Anova = anova(no.center.mod, Long.Base.Mod)

# Strong evidence that including center is useful

##########################################
#### Check Chemical interactions
##########################################


## DDE PCA Interaction
Long.PCA.DDE.Inter.Mod = polr(gestord~ center + log(dde) * logPCB1 + log(triglycerides)  + maternal_age + 
                                smoking_status + log(cholesterol) + albuminTested, data = Long, Hess = T)

DDE.PCA.Inter.Anova = anova(Long.Base.Mod, Long.PCA.DDE.Inter.Mod)

# Not evidence that dde-pcb interact

## DDE/PCA Triglyceride Interaction
# Justified because these chemicals are fat-soluble.
Long.Trig.Inter.Mod = polr(gestord~ center + log(dde)*log(triglycerides) + logPCB1*log(triglycerides)  + 
                             maternal_age + smoking_status + log(cholesterol) + albuminTested, data = Long, Hess = T)

Trig.Inter.Anova = anova(Long.Base.Mod, Long.Trig.Inter.Mod)


##########################################
#### check maternal age poly #############
##########################################

Long.Age.Poly.Mod = polr(gestord~ center + log(dde) + logPCB1 + log(triglycerides)  + poly(maternal_age,2) + smoking_status + log(cholesterol) + albuminTested, data = Long, Hess = T)


Age.Poly.Anova = anova(Long.Base.Mod, Long.Age.Poly.Mod)


Long$MatAgeCat = cut(Long$maternal_age, 4)

MatAgeGestTable = rowPerc(xtabs(formula = ~ MatAgeCat + gestord, data = Long))
plot(MatAgeGestTable[,1], type = "l")
barplot(height = MatAgeGestTable[,1] / 100, xlab = "Age Bucket", ylab = "Severely Preterm Percentage", 
        main = "Severely Preterm Probability vs Maternal Age")
## Conclude that the polynomial term is important.


##########################################
### FINAL MODEL ##########################
##########################################


Final.Mod = polr(gestord~ center + log(dde) + logPCB1 + log(triglycerides)  + poly(maternal_age,2) + smoking_status + log(cholesterol) + albuminTested, data = Long, Hess = T)

final.coef = coef(Final.Mod)
final.confint = confint(Final.Mod)

chem.effect.summary = cbind(final.coef[c("log(dde)","logPCB1")], final.confint[c("log(dde)", "logPCB1"),])
colnames(chem.effect.summary)[1] = "Coef Est"
```

# Results

- (log) DDE and PCB both significantly associated with preterm delivery likelihood even when adjusting for other factors
- Model Comparison indicated (p=`r round(PCA.anova[2,"Pr(Chi)"],2) `) that the first principle component of the pcb_* values is sufficient.

```{r, fig.margin = TRUE}
knitr::kable(chem.effect.summary)
```

# Discussion
