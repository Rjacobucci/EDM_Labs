######### Intro to learning R for the Advanced Training Institute ########


### I strongly recommend the use of Rstudio as a GUI to R
###### makes R much easier to use and learn

##### install required packages for the labs
?install.packages

install.packages('lavaan')
install.packages('psych')
install.packages("mirt")

### there is a way to automatically load packages each time you open up R,

# how to load packages that are already installed --won't work if not installed
library(psych) # also can do
require(mirt)


##### more direct, is to download straight from Github when available #####
### This sometimes happens for developmenal packages, not quite ready for CRAN
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
formals(describe)
# when an argument does not have an "=" with it, it means it is mandatory to specify.
# When it has something like "= True", that is the default, can be overriden

methods(class = "lm")  # notice the summary.lm --  this is what summary(lmobject) pulls from

# Within packages or base R, this is how to get examples -- along with the code to produce them

#### If you look at the help files, for instance:
?lm
# the Arguments section is what you can specify
# the Value section is what shows up in the output

# example
### specify arguments
lm.out <- lm(mpg ~ hp,data=mtcars,method="qr",model=T,singular.ok=T)
str(lm.out)
## Now get values:
# str(lm.out) !!!! lists all
# to get specific ones, we can use $ on the assigned object
lm.out$coefficients
lm.out$effects
summary(lm.out)
# Notice how this corresponds perfectly to the help file

# a lot of more popular, general packages come with add on help files
demo(colors) # get demos of what you are looking for
example(lm)
example(mirt)




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

# want to conver dataset to Mplus format?
write.table(LSAT,file="location/you/want/file/saved.dat",sep=" ",# best to save as .dat
            row.names=F,col.names=F,na="-99") # note: missing can be anything but NA

# I used to always go into SPSS and create dataset in right format for Mplus,
# but this is easier



###### simulated dataset from Edwards 2009
# http://faculty.psy.ohio-state.edu/edwards/

# already downloaded on my computer

data = read.table(file.choose(),sep="",header=F,na.strings="NA") # pop up finder to click on specified dataset
#### important to know what the type of dataset is:
# .dat sep=" "   -- just separated by space
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
# !!! note: with read.spss, always get warning -- not a problem though
spss.dat <- read.spss("/Users/RJacobucci/Documents/NCSsim/NCSsim.sav",
                       use.value.labels=T, # pulls variable names
                       to.data.frame=T) #converts to useful format

# also -- in Rstudio, can use the "Import Dataset" button in top right corner
### I've never actually used it, since I find easier to use script


# SAS
library(sas7bdat)
?read.sas7bdat

# Matlab
library(R.matlab)
?readMat
##### more options: http://www.ats.ucla.edu/stat/r/faq/inputdata_R.htm


# dimensions
?dim
?length # best for vectors
nrow(data) # how many people; same as dim(LSAT)[1]
ncol(LSAT) # how many variables; same as dim(LSAT[2])
dim(data) # both
str(LSAT)

#### reference parts of an object with either $(more common) or @; depends whether S3 or S4: str() will tell you
# reference only the O5 variable -- using $ with dataset takes column
head(bfi$O5)
head(bfi[,"O5"]) # same thing

# also, if you use only one dataset over and over again in script
attach(bfi)
# now, don't have to reference data
head(O5)

# but this can mess things up if multiple datasets are loaded
detach(bfi) #remove

# see what objects and data are in workspace
ls()
# clear it out
# rm(list=ls())
# or just get rid of 1 object: rm(bfi)

# also, dont want to have to specify paths for writing and reading data?
# set the workspace





#out = glm(O5 ~ education, data=bfi)
#head(out$residuals)
# in my experience, $ is more common than @


###### changing type of dataset
?matrix # has to be all of the same mode; e.g. all numeric
# convert to matrix
bfi.mat <- as.matrix(bfi)
str(bfi.mat) # check to see if worked. Wont say matrix, but either "int" or "num"

?data.frame # can be different modes; easiest to just convert all read in data to data.frame
data.df = data.frame(read.table(...))


?mode # mode of object, not variable type
mode(bfi)
mode(lm.out)

#### changing variable type
################## for items: almost always dealing with factor variables
str(bfi) # all integers: depending on application, may be important to change to factor
is.factor(bfi$O5)

# change variable type -- very important for some models
bfi$O5fac = as.factor(bfi$O5)
str(bfi$O5fac)
class(bfi$O5fac)
#?levels
levels(bfi$O5fac)

# change numeric to factor -- how you would artificially dichotomize an integer variable
# library(Hmisc); cut2()
# ?cut

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

data[row,col]
# I want first 100 people and columns 4 to 8
dim(bfi[1:100,4:8])



# another way to pull only certain variables, using indices assigned to an object
#####
myvars = c("O1","O2","O3","O4","O5") # assign to object
openness = bfi[myvars]
# same as
head(bfi[,21:25]) # more tedious with large number of columns
colnames(openness)

# more advanced, subset just numeric variables
index = sapply(bfi,is.numeric)  # create a column index, TRUE = Numeric
new.data = bfi[index] #got rid of factor variables
#dim(new.data)

### good tutorial on apply functions ###
# http://nsaunders.wordpress.com/2010/08/20/a-brief-introduction-to-apply-in-r/


#### rename only one variable in a dataset
names(bfi)[5] = "newVar"
colnames(bfi)[5] = "newVar2" # same thing
# more than 1 variable, need to use c() like before


?c # combine
?cat # concatenate, helpful when combining strings with paste()
?paste


############## missing data #################
## !!!!!!!!!!! maybe the most important topic !!!!!!!!!!!!!!!!! ########
###### problem is a lot of example datasets removed the missing values ########
library(psych)

head(bfi)
cor(bfi$A1,bfi$A2)  # fails because of missing or NA values
args(cor)  # -- default in cor is complete cases
cor(bfi$A1,bfi$A2,use="pairwise.complete.obs")



###### code -99's as NA  #######
data.df <- data.frame(bfi)
data.df[data.df==-99] <-NA
# important to do when importing data from other programs
# !!!!!
##### !!!!!!!! Different procedure for recoding NA's #####
?subset
bfi$education[bfi$education==NA] = -100
str(bfi)
# the previous procedure doesn't work
bfi$education[is.na(bfi$education)] = -99

str(bfi)

# this isn't that useful for R, as best to have missing = NA
# but when exporting data, best not to leave missing as NA


###### analyze missing data ###########
sum(is.na(bfi)) # Do this to count the NA in whole dataset
comp = sum(!complete.cases(bfi)) # Count of incomplete cases
comp/nrow(bfi) # number of people/cases with atleast 1 missing value

which(!complete.cases(bfi)) # Which cases (row numbers) are incomplete?


# sometimes when analyzing data with missingness, instead of imputation
# it is necessary to just eliminate cases with more missing values than a cutoff


####### identify # misssing, select cases with less or equal to 6
M <- rowSums(is.na(bfi) ) # identify number of missing values per row
good.rows <- which( M <= 6 )
bfi.sub   <- bfi[ good.rows, ] # create dataset with people < 6 missing

dim(bfi)
dim(bfi.sub) # lose 6 people

########### have missing cases imputed with median (3)########################
data.sub <- bfi.sub
data.sub[is.na(data.sub)] <- 3
str(data.sub)

# if want just complete cases
comps <- complete.cases(bfi.sub) # logical, True = Complete
data.comp <- bfi.sub[comps,]


# number of missing per item
colSums(is.na(bfi) )
colSums(is.na(data.sub)) # got rid of all missing
colSums(is.na(data.comp))

# imputation
######### check each package's manual to see if there are built in options for imputation
imputeMissing(x, Theta) # mirt package

# also, check out imputeR package


###### PreProcessing for imputation ######
# can use the center, scale, or BoxCox if dealing with scales for factor analysis--not for items
library(caret)
?preProcess  # method = medianImpute, bagImpute,knnImpute

agree <- bfi[,1:5]
# mean of 0 and sd = 1
agree.scale <- scale(agree)
psych::describe(agree.scale)
# note: "::" has to be used when two packages that are loaded have the same function
# common one is sem() from both lavaan::sem and sem::sem

pred <- preProcess(agree,method=c("center","scale"))
agree.scale2 <- predict(pred,agree)
psych::describe(agree.scale2)

#### tons of packages: imputeR (I like), mice, mi, imputation, impute, amelia



######################################################################################
################## An important topic not covered is plotting ########################
############## not to plug myself, but check out a talk I gave at USC ################
###########  http://dornsife.usc.edu/psyc/20140326gc3 ################################
