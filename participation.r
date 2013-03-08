library(plyr)
library(ggplot2)
library(epicalc)
library(scales)
all <- read.csv('occuPARcleandata.csv')

# Only not participate
not.participate <- subset(all, A8.ATTEND_YN == 0)

# New variables
q.7c <- c('A7c_1.ineffective', 'A7c_2.noconcern', 'A7c_3.unfocused', 'A7c_4.disruptive', 'A7c_5.other')
o <- data.frame(
  has.external.stress      = as.numeric(not.participate$A4c_PBCbarriers > 0),
  no.never                 = as.numeric(not.participate$A8.attend == 3),
  has.negative.perception  = as.numeric(rowSums(not.participate[q.7c]) > 0)
)

# A summary
o.yesno <- as.data.frame(lapply(o, function(v) { w <- factor(v, levels = 1:0); levels(w) <- c('Yes', 'No'); w }))
sample.proportions <- ddply(
  o.yesno,
  c('has.external.stress', 'has.negative.perception'),
  function(df) { c(p.no.never = mean(df$no.never == 'Yes')) }
)
sample.proportions.pretty <- sample.proportions
sample.proportions.pretty$p.no.never <-
    paste(100 * round(sample.proportions.pretty$p.no.never, 3), '%', sep = '')
    
sample.proportions.plot <- ggplot(sample.proportions) +
    aes(x = has.negative.perception, group = has.external.stress, y = p.no.never, lty = has.external.stress) + geom_line() +
    scale_y_continuous('Proportion selecting "never" rather than a simple "no".', labels = percent, limits = 0:1) +
    theme_bw() +
    labs(x = 'Has negative perception\n(checked at least one box)',
         lty = 'Has external stress\n(checked at least\none box)',
         title = 'Negative perception of OccupyCUNY is\nmore strongly associated with participation\nwhen external.stress is greater.')

# Logistic regression
logit.alt  <- glm(no.never ~ has.external.stress * has.negative.perception,
                         family = 'binomial', data = o)
logit.null <- glm(no.never ~ has.negative.perception,
                         family = 'binomial', data = o)
logit.test <- lrtest(logit.null, logit.alt)

# Ordinary least square regression
ols.alt  <- lm(no.never ~ has.external.stress * has.negative.perception, data = o)
ols.null <- lm(no.never ~ has.negative.perception, data = o)
ols.test <- anova(ols.null, ols.alt)

# Print out results
library(knitr)
knit('participation.Rmd', output = 'readme.md')
