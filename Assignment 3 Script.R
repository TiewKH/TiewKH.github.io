library(ggplot2)
library(gridExtra)
library(Hmisc)
library(corrplot)
library(arules)
library(caret)                    #Confusion Matrix
library(tree)                     #Decision Tree
library(e1071)                    #Naive Bayes
library(neuralnet)                #Neural Network

#Read in the all the data sets and check its variables
df <- read.csv('datatraining.txt', header = TRUE, sep = ',')
dfTest1 <- read.csv('datatest.txt', header = TRUE, sep = ',')
dfTest2 <- read.csv('datatest2.txt', header = TRUE, sep = ',')
str(df)

#Converting some of the variables to the form we want it to be in

#Pre-processing. Convert date to an hourly fashion for labels. Convert Occupancy into factors.
df$date <- as.POSIXct(strptime(df$date, "%Y-%m-%d %H:%M:%S"))
df$date <- cut(df$date, breaks = "hour")
df$Occupancy <- as.factor(df$Occupancy)

dfTest1$date <- as.POSIXct(strptime(dfTest1$date, "%Y-%m-%d %H:%M:%S"))
dfTest1$date <- cut(dfTest1$date, breaks = "hour")
dfTest1$Occupancy <- as.factor(dfTest1$Occupancy)

dfTest2$date <- as.POSIXct(strptime(dfTest2$date, "%Y-%m-%d %H:%M:%S"))
dfTest2$date <- cut(dfTest2$date, breaks = "hour")
dfTest2$Occupancy <- as.factor(dfTest2$Occupancy)

#Pre-processing. Split Date to date and time
datetimesplit <- data.frame(do.call(rbind, strsplit(as.vector(df$date), split = " ")))
df <- cbind(datetimesplit, df$Temperature, df$Humidity, df$Light, df$CO2, df$HumidityRatio, df$Occupancy)
names(df) <- c("Date", "Time", "Temperature", "Humidity", "Light", "CO2", "HumidityRatio", "Occupancy")

datetimesplit2 <- data.frame(do.call(rbind, strsplit(as.vector(dfTest1$date), split = " ")))
dfTest1 <- cbind(datetimesplit2, dfTest1$Temperature, dfTest1$Humidity, dfTest1$Light, dfTest1$CO2, dfTest1$HumidityRatio, dfTest1$Occupancy)
names(dfTest1) <- c("Date", "Time", "Temperature", "Humidity", "Light", "CO2", "HumidityRatio", "Occupancy")

datetimesplit3 <- data.frame(do.call(rbind, strsplit(as.vector(dfTest2$date), split = " ")))
dfTest2 <- cbind(datetimesplit3, dfTest2$Temperature, dfTest2$Humidity, dfTest2$Light, dfTest2$CO2, dfTest2$HumidityRatio, dfTest2$Occupancy)
names(dfTest2) <- c("Date", "Time", "Temperature", "Humidity", "Light", "CO2", "HumidityRatio", "Occupancy")

#Check for special values in training set
is.special <- function(x){
  if (is.numeric(x)) !is.finite(x) else is.na(x)
}
which((data.frame(sapply(df, is.special))) == TRUE)

#No special values found in training set

#Check how many with occupancy 0 and occupany 1 in the training set
ggplot(data=df, aes(x=Occupancy, fill=Occupancy)) + geom_bar(stat="count")

#Exact values
summary(df$Occupancy)
#   0    1 
#6414 1729 

#Outliers with Boxplots
boxplot1 <- ggplot(df, aes(x=Occupancy, y=Temperature, fill=Occupancy))+
  geom_boxplot(aes(group = Occupancy))+
  theme_bw()+
  xlab("Occupancy")+
  ylab("Temperature")+
  ggtitle("Temperature") + theme(legend.position = "none")

boxplot2 <- ggplot(df, aes(x=Occupancy, y=Humidity, fill=Occupancy))+
  geom_boxplot(aes(group = Occupancy))+
  theme_bw()+
  xlab("Occupancy")+
  ylab("Humidity")+
  ggtitle("Humidity") + theme(legend.position = "none")

boxplot3 <- ggplot(df, aes(x=Occupancy, y=Light, fill=Occupancy))+
  geom_boxplot(aes(group = Occupancy))+
  theme_bw()+
  xlab("Occupancy")+
  ylab("Light")+
  ggtitle("Light") + theme(legend.position = "none")

boxplot4 <- ggplot(df, aes(x=Occupancy, y=CO2, fill=Occupancy))+
  geom_boxplot(aes(group = Occupancy))+
  theme_bw()+
  xlab("Occupancy")+
  ylab("CO2")+
  ggtitle("CO2") + theme(legend.position = "none")

boxplot5 <- ggplot(df, aes(x=Occupancy, y=HumidityRatio, fill=Occupancy))+
  geom_boxplot(aes(group = Occupancy))+
  theme_bw()+
  xlab("Occupancy")+
  ylab("HumidityRatio")+
  ggtitle("HumidityRatio") + theme(legend.position = "none")

grid.arrange(boxplot1, boxplot2, boxplot3, boxplot4, boxplot5, ncol=2, nrow=3)

#Histogram
h1 <- ggplot(df, aes(x=Temperature)) + geom_histogram(aes(group=Occupancy, colour=Occupancy, fill=Occupancy), alpha=0.3, bins = 15)
h2 <- ggplot(df, aes(x=Humidity)) + geom_histogram(aes(group=Occupancy, colour=Occupancy, fill=Occupancy), alpha=0.3, bins = 15)
h3 <- ggplot(df, aes(x=Light)) + geom_histogram(aes(group=Occupancy, colour=Occupancy, fill=Occupancy), alpha=0.3, bins = 15)
h4 <- ggplot(df, aes(x=CO2)) + geom_histogram(aes(group=Occupancy, colour=Occupancy, fill=Occupancy), alpha=0.3, bins = 15)
h5 <- ggplot(df, aes(x=HumidityRatio)) + geom_histogram(aes(group=Occupancy, colour=Occupancy, fill=Occupancy), alpha=0.3, bins = 15)

grid.arrange(h1, h2, h3, h4, h5, ncol=1, nrow=5)

#Density Plot
p1 <- ggplot(df, aes(x=Temperature)) + geom_density(aes(group=Occupancy, colour=Occupancy, fill=Occupancy), alpha=0.3)
p2 <- ggplot(df, aes(x=Humidity)) + geom_density(aes(group=Occupancy, colour=Occupancy, fill=Occupancy), alpha=0.3)
p3 <- ggplot(df, aes(x=Light)) + geom_density(aes(group=Occupancy, colour=Occupancy, fill=Occupancy), alpha=0.3)
p4 <- ggplot(df, aes(x=CO2)) + geom_density(aes(group=Occupancy, colour=Occupancy, fill=Occupancy), alpha=0.3)
p5 <- ggplot(df, aes(x=HumidityRatio)) + geom_density(aes(group=Occupancy, colour=Occupancy, fill=Occupancy), alpha=0.3)

grid.arrange(p1, p2, p3, p4, p5, ncol=1, nrow=5)

#Correlation Plot
correlation_result<-rcorr(as.matrix(df[3:7]))
corrplot(correlation_result$r, type="lower", order="hclust", tl.col="black", tl.srt=30)

#Combine the data sets into one big data set
df <- rbind(df, dfTest1, dfTest2)

#Dicretize original data frame by equal interval for Naive Bayes
df$TemperatureGroup <- discretize(df$Temperature, categories = 6)
df$HumidityGroup <- discretize(df$Humidity, categories = 6)
df$LightGroup <- discretize(df$Light, categories = 6)
df$CO2Group <- discretize(df$CO2, categories = 6)
df$HumidityRatioGroup <- discretize(df$HumidityRatio, categories = 6)

df$Occupancy <- ifelse(df$Occupancy == 0, "Unoccupied", "Occupied")
df$Occupancy <- as.factor(df$Occupancy)

#Split the data into 70% training and 30% testing
set.seed(100)
train <- sample(1:nrow(df), 14392)
df.train <- df[train,]
df.test <- df[-train,]
Occupancy.test <- df$Occupancy[-train]

# Create Vector of Column Max and Min Values from training set
maxs <- apply(df.train[,3:7], 2, max)
mins <- apply(df.train[,3:7], 2, min)

#Different data frame for neural net. Perform min-max normalization on training data set
dfNN.train <- as.data.frame(scale(df.train[, 3:7], center = mins, scale = maxs - mins))
dfNN.train <- cbind(dfNN.train, df.train$Occupancy)
names(dfNN.train)[6] <- c('Occupancy')
dfNN.train$Unoccupied <- c(dfNN.train$Occupancy == 'Unoccupied')
dfNN.train$Occupied <- c(dfNN.train$Occupancy == 'Occupied')

#Scale the test set with respect to the max and min of the training set because we are trying to predict the values based on the data from the training set. From: http://stackoverflow.com/questions/35532249/mse-in-neuralnet-results-and-roc-curve-of-the-results
#1) You can scale your values (using minmax, for example). But only scale your training data set. Save the parameters used in the scaling process (in minmax they would be the min and max values by which the data is scaled). Only then, you can scale your test data set WITH the min and max values you got from the training data set. Remember, with the test data set you are trying to mimic the process of classifying unseen data. Unseen data is scaled with your scaling parameters from the testing data set. 
dfNN.test <- as.data.frame(scale(df.test[, 3:7], center = mins, scale = maxs - mins))
dfNN.test <- cbind(dfNN.test, df.test$Occupancy)
names(dfNN.test)[6] <- c('Occupancy')
dfNN.test$Unoccupied <- c(dfNN.test$Occupancy == 'Unoccupied')
dfNN.test$Occupied <- c(dfNN.test$Occupancy == 'Occupied')

#Building the Decision Tree Model using undiscretized values
tree_model <- tree(Occupancy~Time+Temperature+Humidity+Light+CO2+HumidityRatio, df.train)
plot(tree_model)
text(tree_model,pretty=0)

#Check how the model is doing using the test data
tree_pred <- predict(tree_model, df.test, type = "class")
confusionMatrix(tree_pred, Occupancy.test)
#Accuracy: 0.988
#Sensitivity (TPR/Recall) : 0.9922
#Specificity (FPR/TNR) : 0.9868

#Since the decision tree only uses Light, there is nothing to prune. Now let us buil the decision tree with discretized value
tree_model <- tree(Occupancy~Time+TemperatureGroup+LightGroup+HumidityGroup+CO2Group+HumidityRatioGroup, df.train)
plot(tree_model)
text(tree_model,pretty=0)

#Check how the new decision tree model is doing using the test data
tree_pred <- predict(tree_model, df.test, type = "class")
confusionMatrix(tree_pred, Occupancy.test)
#Accuracy : 0.9771
#Sensitivity (TPR/Recall) : 0.9546
#Specificity (FPR/TNR) : 0.9838

#Pruning the decision tree which uses discretized values
cv_tree <- cv.tree(tree_model, FUN = prune.misclass)
names(cv_tree)

plot(cv_tree$size,cv_tree$dev, type= "b")
plot(cv_tree$k,cv_tree$dev, type= "b")

pruned_model <- prune.misclass(tree_model,best=2)
plot(pruned_model)
text(pruned_model, pretty = 0)

tree_pred <- predict(pruned_model, df.test, type = "class")
confusionMatrix(tree_pred, Occupancy.test)
#Accuracy : 0.9731
#Sensitivity (TPR/Recall) : 0.9950
#Specificity (FPR/TNR) : 0.9666

#Building the Naive Bayes Model
NBmodel <- naiveBayes(Occupancy ~ Time+TemperatureGroup+HumidityGroup+LightGroup+CO2Group+HumidityRatioGroup, data = df.train, type = "raw")
predictions <- predict(NBmodel, df.test, type = "class")
confusionMatrix(predictions,Occupancy.test)
#Accuracy : 0.9627 
#Sensitivity (TPR/Recall) : 0.9383 
#Specificity (FPR/TNR) : 0.9699

#Building the neural net model. err.fct = "ce" means use cross-entropy for error function. Cross-entropy is better for classification while mean of sum of square errors is better for regression which is what was covered in class.
formula <- Unoccupied+Occupied~Temperature+Humidity+Light+CO2+HumidityRatio
NNmodel <- neuralnet(formula, dfNN.train, hidden=3, err.fct="ce",linear.output=FALSE, stepmax = 100000)
plot(NNmodel, class = "nn")
predict <- compute(NNmodel, dfNN.test[,1:5])
predspp <- factor(c("Unoccupied", "Occupied"))[apply(predict$net.result, MARGIN=1, FUN=which.max)]
confusionMatrix(predspp, dfNN.test$Occupancy)
#Accuracy : 0.9880026
#Sensitivity (TPR/Recall) : 0.9914954
#Specificity (FPR/TNR) : 0.9869666
