# The code examines the Iris Fisher dataset using various common machine learning techniques.
#This code was written as part of a challenge project in the
#Udacity Bertlesmann Data Science Scholarship course. Written by Shane Gore 2018

#Import Packages:
import pandas as pd
import numpy as np
import matplotlib.pyplot as mpt
import seaborn as sns
import statistics
from sklearn.linear_model import LogisticRegression
from sklearn import svm
from sklearn.cross_validation import train_test_split #to split the dataset for training and testing
from sklearn import preprocessing
from sklearn.metrics import accuracy_score
from sklearn.naive_bayes import GaussianNB


# Read Iris Fisher dataset
file = r'/Users/shanegore/Desktop/iris.data.csv'
names = ['sepal_length', 'sepal_width', 'petal_length', 'petal_width', 'class']
data = pd.read_csv(file,names=names)

# Print first 10 rows to understand data
print(data.head(10))


# Clean data by removing rows if any missing data
empty_idx = pd.isnull(data)
if np.sum(np.sum(empty_idx)) > 0:
    data =  data.dropna()

# Seperate data into subclasses
setosa = data.loc[data['class'] == 'iris-setosa']
versicolor = data.loc[data['class'] == 'iris-versicolor']
virginica = data.loc[data['class'] == 'iris-virginica']
classnames = ['iris-setosa','iris-versicolor','iris-virginica']


# Explore data using swarm plots from seaborn package overlaying boxplots.
sns.swarmplot(x="class", y="petal_length", data=data)
sns.boxplot(x="class", y="petal_length", data=data, whis=np.inf)
sns.swarmplot(x="class", y="petal_width", data=data)
sns.boxplot(x="class", y="petal_width", data=data, whis=np.inf)
sns.swarmplot(x="class", y="sepal_width", data=data)
sns.boxplot(x="class", y="sepal_width", data=data, whis=np.inf)
sns.swarmplot(x="class", y="sepal_length", data=data)
sns.boxplot(x="class", y="sepal_length", data=data, whis=np.inf)

# Generate discriptive statistics for each class
mean_values = data.groupby(['class']).mean()
print(mean_values)
std_values = data.groupby(['class']).std()
print(std_values)

# Generate correlation matrix
corr_matrix= data.corr()
print(corr_matrix)


# separate the feature and class
x = data.loc[:,['petal_width','sepal_length','petal_length','sepal_width']]
y = data.loc[:,['class']]

#standardize the data features
x_stand = preprocessing.scale(x)
data.loc[:,['petal_width','sepal_length','petal_length','sepal_width']] = x_stand
print(data.head(10))

# radomly split data 100 times to get robust indication of which model performs best.
svm_acc = []
log_acc = []
NB_acc = []
for i in range(0,100):
    #split data into test and train datasets (70-30 split)
    x_train, x_test, y_train, y_test = train_test_split(x_stand,y, test_size = 0.3)

    #print(y_train.shape)
    #print(y_train.head(2))
    #print(x_train.head(2))

    #Classify data using various approaches
    clf = svm.SVC(kernel='rbf')
    clf.fit(x_train,y_train.values.ravel())
    prediction = clf.predict(x_test)
    svm_acc.append(accuracy_score(prediction,y_test.values.ravel()))


    clf = LogisticRegression()
    clf.fit(x_train,y_train.values.ravel())
    prediction = clf.predict(x_test)
    log_acc.append(accuracy_score(prediction,y_test.values.ravel()))


    #Classify data using various approaches
    clf = GaussianNB()
    clf.fit(x_train,y_train.values.ravel())
    prediction = clf.predict(x_test)
    NB_acc.append(accuracy_score(prediction,y_test.values.ravel()))

mean_svm_acc = statistics.mean(svm_acc)
mean_log_acc = statistics.mean(log_acc)
mean_NB_acc = statistics.mean(NB_acc)

std_svm_acc = np.std(svm_acc)
std_log_acc = np.std(log_acc)
std_NB_acc = np.std(NB_acc)
