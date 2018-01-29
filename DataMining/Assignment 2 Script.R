library(dplyr)
library(ggplot2)
library(plotly)
library(arules)
library(arulesViz)

food <- read.csv('food.csv', header = FALSE, col.names = c('FoodId', 'FoodName'), sep = ',')
num <- max(count.fields("75000-out1.csv", sep = ","))
bakery <- read.table("75000-out1.csv", header = FALSE, sep = ",", col.names = paste0("V",1:num), fill = TRUE)

#Check which receipt only has one item
removedReceipts <- is.na(bakery$V3)
bakery <- bakery[!removedReceipts, ]
bakery <- bakery[2:num]

#Change the food ID to the food name
newBakery <- data.frame(lapply(bakery, function(x) {x <-  food$FoodName[match(x, food$FoodId)]}))

write.table(newBakery, 'foodUpdated.csv', sep = ',', col.names = FALSE, row.names = FALSE, na = '')

#Read it as a transaction file
transactions <- read.transactions("foodUpdated.csv", sep=",")
inspect(transactions)

rules <- apriori(transactions, parameter = list(sup = 0.02, conf = 0.5, minlen = 2, target="rules"))

#Remove redundant rules (if any)
redundant <- is.redundant(rules, measure = "confidence")
rules <- rules[!redundant]
inspect(rules)
#No redundant rules. But there are many rules a -> b and b -> a. Let us keep in mind some rules first before we remove the rules based on their itemset

#Removing rules based on the itemset
new.rules <- rules[!duplicated(generatingItemsets(rules))]
rules.sorted.sup <- sort(new.rules, by = "support")
rules.sorted.conf <- sort(new.rules, by = "confidence")
rules.sorted.lift <- sort(new.rules, by = "lift")

#Reading in the binary vector receipt file
binaryVector = read.csv("75000-out2.csv", header = FALSE)

#Removing the column for receipt ID
binaryVector <- binaryVector[2:51]

#Changing the column names to their respective food names
colnames(binaryVector) <- food$FoodName

#Reading in the file which has data on the amount of items purchased for the item based on the receipt
purchases <- read.csv("75000i.csv", header = FALSE, col.names = c("ReceiptID", "Amount", "Food"))

#Removing the unnecessary receipts by their ReceiptID
removedReceipts.num <- which(removedReceipts == TRUE)
purchases <- purchases[!(purchases$ReceiptID %in% removedReceipts.num), ]
purchases$Food <- food$FoodName[match(purchases$Food, food$FoodId)]

#Seeing which receipts contains all the items we are interested in
toCheck <- which(binaryVector$`Lemon Lemonade` == 1 & binaryVector$`Raspberry Lemonade` == 1 & binaryVector$`Lemon Cookie` == 1 & binaryVector$`Raspberry Cookie` == 1 & binaryVector$`Green Tea` == 1)

#Filtering out the receipts based on the receipt ID and only for the food we want to check
receiptsToCheck <- purchases[(purchases$ReceiptID %in% toCheck), ]
receiptsToCheck <- receiptsToCheck[receiptsToCheck$Food %in% c("Lemon Lemonade", "Raspberry Lemonade", "Lemon Cookie", "Raspberry Cookie", "Green Tea"), ]
receiptsToCheck$Food <- as.factor(receiptsToCheck$Food)

#Data frame which has the amount of item purchased by item name
dfToCheck <- data.frame(receiptsToCheck %>% group_by(Food) %>%summarise(Frequency = sum(Amount)))

#Get the mean number of items purchased in a receipt
dfToCheck$Mean <- dfToCheck$Frequency / length(unique(receiptsToCheck$ReceiptID))

ggplotly(ggplot(dfToCheck, aes(x=Food, y=Mean, fill=Food)) + geom_bar(stat = "identity") + ggtitle("Average number of item purchase per receipt") + geom_text(aes(label=round(Mean,2))))
#Mean item for everything is 3. We can make a bundle of 3 items each.
