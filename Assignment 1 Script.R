library(ggplot2)
library(plotly)
library(gridExtra)
library(reshape2)
library(plyr)
library(dplyr)

df <- read.csv("student-mat.csv", header = TRUE)

is.special <- function(x){
  if (is.numeric(x)) !is.finite(x) else is.na(x)
}

(data.frame(sapply(df, is.special)))

boxplot1 <- ggplot(df, aes(x=Dalc, y=G1, fill=Dalc))+
  geom_boxplot(aes(group = Dalc))+
  theme_bw()+
  xlab("Alcohol consumption")+
  ylab("First period grade")+
  ggtitle("First period grade") + theme(legend.position = "none")

boxplot2 <- ggplot(df, aes(x=Dalc, y=G2, fill=Dalc))+
  geom_boxplot(aes(group = Dalc))+
  theme_bw()+
  xlab("Alcohol consumption")+
  ylab("Second period grade")+
  ggtitle("Second period grade") + theme(legend.position = "none")

boxplot3 <- ggplot(df, aes(x=Dalc, y=G3, fill=Dalc))+
  geom_boxplot(aes(group = Dalc))+
  theme_bw()+
  xlab("Alcohol consumption")+
  ylab("Final period grade")+
  ggtitle("Final period grade") + theme(legend.position = "none")

grid.arrange(boxplot1, boxplot2, boxplot3, ncol = 3)

toPlot <- group_by(df, Dalc) %>% summarize(G1Mean = mean(G1), G2Mean = mean(G2), G3Mean = mean(G3))
toPlot.m <- melt(toPlot,id.var="Dalc")
colnames(toPlot.m)[3] <- "MeanGradeMarks"
ggplotly(ggplot(toPlot.m, aes(x=Dalc, y=MeanGradeMarks, fill=variable)) + geom_bar(position="dodge",stat="identity") + ggtitle("Workday Alcohol Consumption Levels (Dalc) against Mean Grade Marks"))

table(df$Dalc, df$G1)
ggplot(df, aes(x=Dalc, y=G3, color = Dalc))+ geom_jitter() + scale_colour_gradientn(colours=rainbow(4))

toPlot2 <- group_by(df, famrel) %>% summarize(WorkdayAlcoholConsumption = mean(Dalc), WeekendAlcoholConsumption = mean(Walc))
toPlot2.m <- melt(toPlot2, id.var = "famrel")
colnames(toPlot2.m)[3] <- "AlcoholMean"

ggplotly(ggplot(toPlot2.m, aes(x=famrel, y=AlcoholMean, color = variable)) + geom_line() + geom_point() + ggtitle("Family Relationship against Mean Alcohol Consumption"))

toPlot3 <- group_by(df, romantic) %>% summarize(WorkdayAlcocholConsumption = mean(Dalc), WeekendAlcoholConsumption = mean(Walc))
toPlot3.m <- melt(toPlot3, id.var = "romantic")
colnames(toPlot3.m)[1] <- "RelationshipStatus"
colnames(toPlot3.m)[3] <- "AlcoholMean"
toPlot3.m[1] <- apply(toPlot3.m[1], 1, function(x) {ifelse(x == 'yes', 'Couple', 'Single')})
ggplotly(ggplot(toPlot3.m, aes(x=variable, y=AlcoholMean, fill=RelationshipStatus)) + geom_bar(position="dodge",stat="identity") + ggtitle("Relationship Status against Mean Alcohol Consumption"))

toPlot4 <- group_by(df, health) %>% summarize(WorkdayAlcoholConsumption = mean(Dalc), WeekendAlcoholConsumption = mean(Walc))
toPlot4.m <- melt(toPlot4, id.var = "health")
colnames(toPlot4.m)[3] <- "AlcoholMean"

ggplotly(ggplot(toPlot4.m, aes(x=health, y=AlcoholMean, color = variable)) + geom_line() + geom_point() + ggtitle("Health against Mean Alcohol Consumption"))
