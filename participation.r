library(plyr)
all <- read.csv('occuPARcleandata.csv')

# Only not participate
not.participate <- subset(all, A8.ATTEND_YN == 0)

# New variables
o <- data.frame(
  has.barrier = not.participate$A4c_PBCbarriers > 0,
  no.never     = not.participate$A8.attend == 3,
  has.negative.perception  = rowSums(not.participate[c('A7c_1.ineffective', 'A7c_2.noconcern', 'A7c_3.unfocused', 'A7c_4.disruptive', 'A7c_5.other')]) > 0
)

sample.probabilities <- ddply(o, c('has.barrier', 'has.negative.perception'),
                   function(df) {
                       c(p.no.never = paste(100 * round(mean(df$no.never), 3), '%', sep = ''))
                   })

# Logistic regression
logit.alternative <- glm(no.never ~ has.barrier * has.negative.perception,
                         family = 'binomial', data = o)
logit.null        <- glm(no.never ~ has.negative.perception,
                         family = 'binomial', data = o)

# Ordinary least square regression
ols.alternative <- lm(no.never ~ has.barrier * has.negative.perception, data = o)
ols.null        <- lm(no.never ~ has.negative.perception, data = o)

print(sample.probabilities)
#print(summary(logit.alternative))
#print(anova(logit.alternative, logit.null))
print(summary(ols.alternative))
print(anova(ols.alternative, ols.null))

