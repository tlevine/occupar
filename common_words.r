all <- read.csv('occuPARcleandata.csv')

words <- strsplit(paste(all$A4b_11.Explain, collapse = ' '), ' ')[[1]]
words <- words[words != '']
words <- ddply(data.frame(word = words), 'word', nrow)
words <- words[order(words$V1),]
