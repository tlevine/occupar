
# [27,] "A4c_PBCbarriers"    
# 
# [28,] "A4c_1.financial"    
# [29,] "A4c_2.jobsecurity"  
# [30,] "A4c_3.childcare"    
# [31,] "A4c_4.time"         
# [32,] "A4c_5.support"      
# [33,] "A4c_6.work"         
# [34,] "A4c_7.info"         
# [35,] "A4c_8.school"       
# [36,] "A4c_9.surveillance" 
# [37,] "A4c_10.police"      
# [38,] "A4c_11.arrest"      
# [39,] "A4c_12.other"       
# [40,] "A4c_12.explain"    
# 
# [59,] "A8.ATTEND_YN"       
# [60,] "A8.DESIRE"          
# [61,] "A8.attend"          
# [62,] "A8.explain"   


all <- read.csv('occuPARcleandata.csv')

# Only not participate
not.participate <- subset(all, A8.ATTEND_YN == 0)

# New variables
o <- data.frame(
  has.barrier = not.participate$A4c_PBCbarriers > 0,
  hell.no     = not.participate$A8.attend == 3,
  has.desire  = rowSums(not.participate[c('A7c_1.ineffective', 'A7c_2.noconcern', 'A7c_3.unfocused', 'A7c_4.disruptive', 'A7c_5.other')]) == 0
)

crosstabs <- ddply(o, names(o), nrow)
names(crosstabs)[4] <- 'count'

m <- glm(hell.no ~ has.barrier * has.desire, family = 'binomial', data = o)

print(summary(m))
