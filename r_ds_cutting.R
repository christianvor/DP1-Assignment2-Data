

# reading in the data and filtering for the year of 2018, since that is the only year both of the datasets include

cars <- read.csv("vie-bez-tec-sex-veh-brd-2011f.csv",sep = ";", skip = 1)
# only the cars for 2018
cars2 <- cars[cars$REF_YEAR==2018,]
# writing it to a new csv
write.csv(cars2,file="cars_2018_subset.csv")


library(jsonlite)
library(rjson)

# loading the JSON file containing the anrainerparkplätze
park2 <- fromJSON(file ="PARKENANRAINEROGD.json")
#park <- read.csv("PARKENANRAINEROGD.csv")

#extracting only the features, since we don't need the geolocation parameters
# or general metadata of the file. This also makes it suitable size-wise
park2 <- park2$features
park2 <- lapply(park2,function(x){ x$properties })
# excluding a parameter that is always null
park3 <- lapply(park2,function(x){  x[-6] })

#making a dataframe out of it and brushing it up a little
park4 <- lapply(park3,function(x){t(as.data.frame(unlist(x)))})
park4 <- park4[-1032]
park5 <- as.data.frame(do.call(rbind,park4))
park6 <- park5$ADRESSE#apply(park5$ADRESSE,1,FUN=function(x){substr(x,1,2)})
for(i in 1:nrow(park5)){
  park6[i] <- substr(park5$ADRESSE[i],1,2)
}
park6 <- gsub(",","",park6)
park6 <- as.integer(park6)
park7 <- as.data.frame(cbind("OBJECTID"=park5$OBJECTID,"BEZIRK" =park6,"AUSNAHME-TXT"=park5$AUSNAHME_TXT,"STELLPL-ANZ"=park5$STELLPL_ANZ,"WEITERE_INF"=park5$WEITERE_INF))

# convert back to json and read to a new file
json_data <- toJSON(park7)
write(json_data,"PARKANR_MOD.json")




