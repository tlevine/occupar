library(plyr)
library(epicalc)
all <- read.csv('occuPARcleandata.csv')

# Only not participate
not.participate <- subset(all, A8.ATTEND_YN == 0)

# New variables
o <- data.frame(
  has.life.stress          = not.participate$A4c_PBClife.stresss > 0,
  no.never                 = not.participate$A8.attend == 3,
  has.negative.perception  = rowSums(not.participate[c('A7c_1.ineffective', 'A7c_2.noconcern', 'A7c_3.unfocused', 'A7c_4.disruptive', 'A7c_5.other')]) > 0
)

# A summary
sample.probabilities <- ddply(
  o,
  c('has.life.stress', 'has.negative.perception'),
  function(df) { c(p.no.never = paste(100 * round(mean(df$no.never), 3), '%', sep = '')) }
)

# Logistic regression
logit.alt  <- glm(no.never ~ has.life.stress * has.negative.perception,
                         family = 'binomial', data = o)
logit.null <- glm(no.never ~ has.negative.perception,
                         family = 'binomial', data = o)
logit.test <- lrtest(logit.null, logit.alt)

# Ordinary least square regression
ols.alt  <- lm(no.never ~ has.life.stress * has.negative.perception, data = o)
ols.null <- lm(no.never ~ has.negative.perception, data = o)
ols.test <- anova(ols.null, ols.alt)

# Print out results
library(knitr)
knit('participation.Rmd')
