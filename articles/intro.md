# Prepare file for batch import into ARW

This vignette shows how to create the database for uploading photos in
Batch Import mode into ARW. This vignette requires that you have a
folder that contains all the photos from a transect (or person) at a
date, and *only these photos, no other photos, no subfolders.*

There are two main steps: - Renaming the photos according to a code
(optional) - Create a data frame that will be imported into ARW Steps
where your input is needed are indicated.

## Setup

First setup the librairies. If you don’t have these libraries, you can
install them using “install.packages(nameOfTheLibrary)”

## Photo renaming

Now, let’s rename the photos. The first step is to create a table that
will keep a memory of the raw photo name and the new photo name, in case
we ever need to go back to the initial photos.

``` r
#1 **INPUT NEEDED** 
#set the folder containing the photos to import  
pathToPhotos <- file.path(here("data"))

#2 get the list of the photos in this folder. Sends an error if no photos are found.
(photoNames <- data.frame(rawPhotoNames = list.files(path = pathToPhotos, full.names = FALSE))) # check that these are the expected photos
```

    ##   rawPhotoNames
    ## 1     test1.jpg
    ## 2     test2.jpg
    ## 3     test3.jpg

``` r
nb_photos <- dim(photoNames)[1]
if (nb_photos == 0){ print("Error: no photos in this directory.")}


#3 extract the EXIF data and check that the photos contain the creation date
listEXIF <- read_exif(file.path(pathToPhotos, photoNames$rawPhotoNames))
if (!"CreateDate" %in% names(listEXIF)) { 
  print("Error: the photos do not have a CreateDate. Rename the photos manually, then use photo2batchimport to create the ARW table")
  } else if (any(is.na(listEXIF$CreateDate))){ 
    print("Error: some of the photos do not have a CreateDate. Rename the photos manually, then use photo2batchimport to create the ARW table") 
  } else { print("Photos are appropriate for automatic renaming based on CreateDate.")
    listEXIF %<>% select(FileName, CreateDate) %>% arrange(CreateDate) # sort the photos by CreateDate (chronological order)
      }
```

    ## [1] "Photos are appropriate for automatic renaming based on CreateDate."

``` r
#4 **INPUT NEEDED** 
#determine the base code that you want to rename these photos with. The function will then increment a 3-digit number to each photo 
Code = "PVL_M_05_11_2024"

#5 create a table containing the raw and new photo names. Check that everything is as expected.
(listEXIF %<>% mutate(newPhotoName = paste0(Code, "_", str_pad(row_number(), pad = 0,width = 3 , "left"),"_ind.jpg")) %>% 
  rename(rawPhotoName = FileName)) %>% select(CreateDate, rawPhotoName, newPhotoName)
```

    ## # A tibble: 3 × 3
    ##   CreateDate          rawPhotoName newPhotoName                
    ##   <chr>               <chr>        <chr>                       
    ## 1 2024:11:05 22:03:53 test1.jpg    PVL_M_05_11_2024_001_ind.jpg
    ## 2 2024:11:05 22:05:22 test3.jpg    PVL_M_05_11_2024_002_ind.jpg
    ## 3 2024:11:05 22:07:37 test2.jpg    PVL_M_05_11_2024_003_ind.jpg

``` r
#6 **INPUT NEEDED**
#if everything is okay, store this table in a file
write.csv(listEXIF, file.path(here("exports", "photoNames_PVL_M_05_11_2024.csv")))
```

The second step is to actually rename the photos based on the codes that
were defined. For security reasons, the files will be copied to another
folder before being renamed, so that the original photo still exists.

``` r
for (i in 1:length(listEXIF$rawPhotoName)){
  file.copy(file.path(pathToPhotos, listEXIF$rawPhotoName[i]), 
            file.path(here("dataRenamed")))
  file.rename(from = file.path(here("dataRenamed", listEXIF$rawPhotoName[i])), 
              to = file.path(here("dataRenamed", listEXIF$newPhotoName[i])))
}
```

## Batch Import prep

``` r
#0 set the path to the renamed photos
pathToPhotos <- file.path(here("dataRenamed"))

#1 Create a table with the photo names
photoNames <- list.files(path = pathToPhotos, full.names = FALSE)
BatchImportdf <- data.frame(Encounter.mediaAsset0 = photoNames)
print(BatchImportdf) #make sure these are the expected photos
```

    ##          Encounter.mediaAsset0
    ## 1 PVL_M_05_11_2024_001_ind.jpg
    ## 2 PVL_M_05_11_2024_002_ind.jpg
    ## 3 PVL_M_05_11_2024_003_ind.jpg

``` r
#2 **INPUT NEEDED**
# Extract details from the photo name
# Change the submitterID to your ARW login
# if this is the first time ever that this site is prospected, and you are confident that there are no duplicates in your photos, you can assign individual names without recognition (= each photo is set to a new individual name) by setting MarkedID = T.
BatchImportdf_ready <- photo2batchimport(BatchImportdf,
                                         submitterID = "JSmith",
                                         MarkedID = F)

# Take a look at the final table
head(BatchImportdf_ready)
```

    ##          Encounter.mediaAsset0 Encounter.day Encounter.month Encounter.year
    ## 1 PVL_M_05_11_2024_001_ind.jpg            05              11           2024
    ## 2 PVL_M_05_11_2024_002_ind.jpg            05              11           2024
    ## 3 PVL_M_05_11_2024_003_ind.jpg            05              11           2024
    ##   Encounter.locationID Encounter.verbatimLocality Encounter.sightingID
    ## 1            Prevalaye                      PVL_M       PVL_M_05112024
    ## 2            Prevalaye                      PVL_M       PVL_M_05112024
    ## 3            Prevalaye                      PVL_M       PVL_M_05112024
    ##   Encounter.alternateID Encounter.genus Encounter.specificEpithet
    ## 1        M_05112024_001      Salamandra                salamandra
    ## 2        M_05112024_002      Salamandra                salamandra
    ## 3        M_05112024_003      Salamandra                salamandra
    ##   Encounter.project0.researchProjectName Encounter.submitterID
    ## 1                        Salamandres BZH                JSmith
    ## 2                        Salamandres BZH                JSmith
    ## 3                        Salamandres BZH                JSmith

``` r
# Save the table for export - Change the file name to your needs
write.csv(BatchImportdf_ready, file.path(here("exports", "PVL_M_05112024.csv")), row.names = F)
```

Congratulations, this set of photos is ready for upload on ARW!
