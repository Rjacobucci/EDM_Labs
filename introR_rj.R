######### Intro to learning R for the Psychometrics Class ########
## Ross Jacobucci --  Fall 2014

# for other great talks on an introduction to R, check out archived lectures:
# https://dornsife.usc.edu/psyc/GC3-lectures

### I strongly recommend the use of Rstudio as a GUI to R
###### makes R much easier to use and learn

##### install required packages for the labs
?install.packages

install.packages('lavaan')
install.packages('psych')
install.packages("mirt")

### there is a way to automatically load packages each time you open up R,
### however it is somewhat complicated -- ask me or email if you want instructions


# how to load packages that are already installed --won't work if not installed
library(psych) # generally preferable to
require(mirt)


##### more direct, is to download straight from Github when available #####
#if not installed already on your computer, install devtools
install.packages('devtools')

#load and install the package
library(devtools)
install_github('philchalmers/faoutlier')

#reload into you workspace
library(faoutlier)

#### Also,package has to be loaded to get help files for specific files

####################### Ways to get general help ###########################

help.search("histograms") # google type search through R documentation. 
??histogram # same thing as help.search().
help.start()   # general help.

# Looking for a specific function?

apropos("plot") # list all functions containing string plot

# Help with specific functions
help(plot)
# same thing
?plot
plot # or just type function


#The great thing about the plot function, is that it changes depending upon what object is called. 
# Example of a "Generic function"
# other generic functions: summary,anova, predict

# list arguments within a function
args(describe)  

methods(class = "lm")  # notice the summary.lm --  this is what summary(lmobject) pulls from

# Within packages or base R, this is how to get examples -- along with the code to produce them

demo(colors) # get demos of what you are looking for
example(lm)
example(mirt)


# for the purposes of this class, will demonstrate techniques with both dichotomous(binary) 
# and polytomous(likert) type responses

# two options to get data -- read in your own or use data included in packages

library(help = "datasets") # way to find built in datasets

#### dichotomous data
library(ltm) # general irt package that contains the LSAT dataset

LSAT # prints entire dataset in console
View(LSAT) # opens in new tab/window -- tempting for those coming from SPSS -- bad when big dataset
head(LSAT,n=10) # head only prints first 10 rows of dataset -- default is 6
colnames(LSAT) # get column names
colnames(LSAT) <- c("x1","x2","x3","x4","x5") # change column names -- multiple ways to do it


##### two good ways to describe the data you pull into r
summary(LSAT)
describe(LSAT)  ## from psych package
descript(LSAT)  ## from ltm package

dsc <- descript(LSAT)
dsc
plot(dsc)


### pull in data from external file ####

?read.table # best for .txt
?read.csv ### same as read.table, but makes defaults simpler such as sep = ","
?read.delim # .tsv

###### simulated dataset from Edwards 2009
# http://faculty.psy.ohio-state.edu/edwards/

# already downloaded on my computer

data = read.table(file.choose(),sep="",header=T,na.strings="NA") # pop up finder to click on specified dataset
#### important to know what the type of dataset is:
# .dat sep=""   -- just separated by space
# .csv sep=","  -- separated by comma
summary(data)
head(data)

# easiest to assign missing now with na.strings="0" or "-99"
# changes them to NA which is how R handles missing values

data2 = read.table("/Users/RJacobucci/Documents/NCSsim/NCSsim.dat",sep="")
### a lot of times important to specify header=T if your dataset has column names

#################### datasets from SPSS, SAS, or other software ########
# SPSS and Minitab, S, SAS, Stata, Systat, Weka, dBase
library(foreign) 
?read.spss

# SAS
library(sas7bdat)
?read.sas7bdat

# Matlab
library(R.matlab)
?readMat


##### more options: http://www.ats.ucla.edu/stat/r/faq/inputdata_R.htm
  


# by column


# dimensions
?dim
?length
nrow()
ncol()



########### find out more information about an object ########
##### especially useful when trying to find data type of each item
?str  
out = lm(O5 ~ education, data=bfi)
str(out)
out$coefficients
out$model$education
#### reference parts of an object with either $(more common) or @; depends whether S3 or S4: str() will tell you
head(bfi$O5)

out = lm(O5 ~ education, data=bfi)
head(out$residuals)



###### changing type of dataset
?matrix # has to be all of the same mode; e.g. all numeric
# convert to matrix
as.matrix()


?data.frame # can be different modes; easiest to just convert all read in data to data.frame
data.df = data.frame(read.table(...))

?mode # mode of object, not variable type
mode(bfi)

#### changing variable type
################## for items: almost always dealing with factor variables
str(bfi) # all integers: depending on application, may be important to change to factor
is.factor(bfi$O5)


bfi$O5fac = as.factor(bfi$O5)
str(bfi$O5fac)
?levels
levels(bfi$O5fac)

# change numeric to factor -- how you would artificially dichotomize an integer variable
library(Hmisc); cut2()
?cut

# factor variable to numeric
bfi$O5num = as.numeric(as.character(bfi$O5fac))
str(bfi$O5num)

# to integer -- notice as.character isn't needed -- one oddity about R
bfi$O5int = as.integer(bfi$O5fac)
str(bfi$O5int)
######
## subsetting dataset

# by row
?sample
?subset


str(O5)
attach(bfi) # so you don't have to always reference the dataset e.g. varname instead of data$varname
str(O5)


data[row,col]
#### if using non-continuous indices of variables, must use c() combine
head(bfi[,1:3,5:7]) # fail
head(bfi[,c(1:3,5:7)]) # succeed

# another way to pull only certain variables, using indices assigned to an object

index = sapply(bfi,is.numeric)  # usually just try all apply functions to see which one works
new.data = bfi[index] #got rid of factor variables


### good tutorial on apply functions ###
# http://nsaunders.wordpress.com/2010/08/20/a-brief-introduction-to-apply-in-r/

#####
myvars = c("O1","O2","O3","O4","O5")
openness = bfi[myvars]  # same as bfi[,21:25]
colnames(bfi)

#### rename only one variable in a dataset
names(bfi)[5] = "newVar"

?c # combine
?cat # concatenate

############## missing data #################
## !!!!!!!!!!! maybe the most important topic !!!!!!!!!!!!!!!!! ########
###### problem is a lot of example datasets removed the missing values ########
library(psych)

head(bfi)
cor(bfi$A1,bfi$A2)  # fails because of missing or NA values 
args(cor)  # -- default in cor is complete cases
cor(bfi$A1,bfi$A2,use="pairwise.complete.obs")



###### code -99's as NA  #######
data.df[data.df==-99] <-NA

# !!!!!
##### !!!!!!!! Different procedure for recoding NA's #####
# the previous procedure doesn't work
bfi$education[bfi$education==NA] = -100
str(bfi)

bfi$education[is.na(bfi$education)] = -99

str(bfi)

###### analyze missing data ###########
sum(is.na(bfi)) # Do this to count the NA in whole dataset
comp = sum(!complete.cases(bfi)) # Count of incomplete cases
comp/nrow(bfi) # number of people/cases with atleast 1 missing value

which(!complete.cases(bfi)) # Which cases (row numbers) are incomplete?
####### identify # misssing, select cases with less or equal to 6
M <- rowSums(is.na(bfi) ) # identify number of missing values per row
good.rows <- which( M <= 6 )
bfi.sub   <- bfi[ good.rows, ]

dim(bfi)
dim(bfi.sub)

########### have missing cases imputed with median (3)########################
data.sub[is.na(data.sub)] <- 3
str(data.sub)

# number of missing per item
colSums(is.na(bfi) ) 


# imputation
######### check each package's manual to see if there are built in options for imputation
imputeMissing(x, Theta) # mirt package
?imputeMissing
###### PreProcessing for imputation ######
# can use the center, scale, or BoxCox if dealing with scales for factor analysis--not for items
library(caret)
?preProcess  # method = meadianImpute, bagImpute,knnImpute


#### tons of packages: imputeR (I like), mice, mi, imputation, impute, amelia



######################################################################################
################## An important topic not covered is plotting ########################
############## check out a talk I gave last Spring in the GC3 ########################
###########  http://dornsife.usc.edu/psyc/20140326gc3 ################################
