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
install them using “install.packages(”nameOfTheLibrary”)”

## Step 1- Rename the photos

### Option A: photo renamed based on EXIF data (photo date and time), if available

The first step is to create a table that will keep track of the raw
photo name and the new photo name, in case we ever need to go back to
the initial photos. *The files are not renamed at this step*

``` r
#**INPUT NEEDED** 
#set the folder containing the photos to import
pathToPhotos <- file.path(here(), "data")
# for this example, the path is set inside the package using here(). You may replace it with the full path to your photos, e.g.:
# pathToPhotos <- file.path("C:/Users/John/Downloads/BR_BR2_06112024")

#get the list of the photos in this folder.
(photoNames <- data.frame(rawPhotoNames = list.files(path = pathToPhotos, full.names = FALSE))); nb_photos = dim(photoNames)[1]; if (nb_photos == 0){ print("Error: no photos in this directory.")}
```

    ##   rawPhotoNames
    ## 1     test1.jpg
    ## 2     test2.jpg
    ## 3     test3.jpg

``` r
#**Check that these are the expected photos*

#extract the EXIF data and check that the photos contain the creation date
listEXIF <- read_exif(file.path(pathToPhotos, photoNames$rawPhotoNames)); if (!"CreateDate" %in% names(listEXIF)) { 
  print("Error: the photos do not have a CreateDate. You may rename the photos by alphabetical order using Option B below")
  } else if (any(is.na(listEXIF$CreateDate))){ 
    print("Error: some of the photos do not have a CreateDate. You may rename the photos by alphabetical order using Option B below") 
  } else { print("Photos are appropriate for automatic renaming based on CreateDate.")
    listEXIF %<>% select(FileName, CreateDate) %>% arrange(CreateDate) # sort the photos by CreateDate (chronological order)
      }
```

    ## [1] "Photos are appropriate for automatic renaming based on CreateDate."

``` r
#**INPUT NEEDED** 
#determine the base code that you want to rename these photos with. The function will then increment a 3-digit number to each photo 
Code = "BR_BR2_06_11_2024"

#create a table containing the raw and new photo names. 
(listEXIF %<>% mutate(newPhotoName = paste0(Code, "_", str_pad(row_number(), pad = 0,width = 3 , "left"),"_ind.jpg")) %>% 
  rename(rawPhotoName = FileName)) %>% select(CreateDate, rawPhotoName, newPhotoName)
```

    ## # A tibble: 3 × 3
    ##   CreateDate          rawPhotoName newPhotoName                 
    ##   <chr>               <chr>        <chr>                        
    ## 1 2024:11:05 22:03:53 test1.jpg    BR_BR2_06_11_2024_001_ind.jpg
    ## 2 2024:11:05 22:05:22 test3.jpg    BR_BR2_06_11_2024_002_ind.jpg
    ## 3 2024:11:05 22:07:37 test2.jpg    BR_BR2_06_11_2024_003_ind.jpg

``` r
#**Check that the new names are as expected.*
#*
#**INPUT NEEDED**
#if everything is okay, store this table in a file to keep track of old and new photo names
write.csv(listEXIF, file.path(here("exports", "photoNames_BR_BR2_06_11_2024.csv")))
```

The second step is to actually rename the photos based on the codes that
were defined. For security reasons, the files will be copied to another
folder before being renamed, so that the original photo still exists. *A
copy of the photos will be renamed now*

``` r
#**INPUT NEEDED* 
#set the path to the folder where your photos will be put
pathToFolder <- file.path(here(), "dataRenamed")
# for this example, the path is set inside the package using here(). You may replace it with the full path where your renamed photos will be, e.g.:
# pathToFolder <- file.path("C:/Users/John/Downloads/newFolder")

file.copy(file.path(pathToPhotos, listEXIF$rawPhotoName), pathToFolder)
```

    ## [1] TRUE TRUE TRUE

``` r
file.rename(from = file.path(pathToFolder, listEXIF$rawPhotoName),
              to = file.path(pathToFolder, listEXIF$newPhotoName))
```

    ## [1] TRUE TRUE TRUE

Done! Go ahead and generate the table for ARW (step 2)

## Option B: Photo renamed by alphabetical order

In case you don’t have the EXIF data or don’t want to use it, you may
want to rename the photos in their current alphabetical order. Again,
first keep track of the raw and corrected names. *The files are not
renamed at this step*

``` r
#**INPUT NEEDED*
#set the folder containing the photos to import
pathToPhotos <- file.path(here(), "data")
# for this example, the path is set inside the package using here(). You may replace it with the full path to your photos, e.g.:
# pathToPhotos <- file.path("C:/Users/John/Downloads/BR_BR2_06112024")

#get the list of the photos in this folder
(photoNames <- data.frame(rawPhotoNames = list.files(path = pathToPhotos, full.names = FALSE))) 
```

    ##   rawPhotoNames
    ## 1     test1.jpg
    ## 2     test2.jpg
    ## 3     test3.jpg

``` r
#**Check that these are the expected photos. The photos will be renamed in the order presented here.*

#**INPUT NEEDED* 
#determine the base code that you want to rename these photos with. The function will then increment a 3-digit number to each photo 
Code = "BR_BR2_06_11_2024"

#create a table containing the raw and new photo names. Check that everything is as expected.
(photoNames %<>% mutate(newPhotoName = paste0(Code, "_", str_pad(row_number(), pad = 0,width = 3 , "left"),"_ind.jpg")))
```

    ##   rawPhotoNames                  newPhotoName
    ## 1     test1.jpg BR_BR2_06_11_2024_001_ind.jpg
    ## 2     test2.jpg BR_BR2_06_11_2024_002_ind.jpg
    ## 3     test3.jpg BR_BR2_06_11_2024_003_ind.jpg

``` r
#**Check that everything is as expected.*
#*
#**INPUT NEEDED*
#if everything is okay, store this table in a file to keep track of old and new photo names
write.csv(photoNames, file.path(here("exports", "photoNames_BR_BR2_06_11_2024.csv")))
```

Now rename the photos based on the code defined. The files will be
copied to your folder of choice, so that the original photo still
exists. *A copy of the photos will be renamed now*

``` r
#**INPUT NEEDED*
#set the path to the folder where your photos will be put
pathToFolder <- file.path(here(), "dataRenamed")
# for this example, the path is set inside the package using here(). You may replace it with the full path where your renamed photos will be, e.g.:
# pathToFolder <- file.path("C:/Users/John/Downloads/newFolder")

# Photos are renamed during this step.
file.copy(file.path(pathToPhotos, photoNames$rawPhotoName),  pathToFolder)
```

    ## [1] TRUE TRUE TRUE

``` r
file.rename(from = file.path(pathToFolder, photoNames$rawPhotoName),
              to = file.path(pathToFolder, photoNames$newPhotoName))
```

    ## [1] TRUE TRUE TRUE

Done! Go ahead and generate the table for ARW (step 2)

## Step 2: prep the Bulk Import table

Now create the table that you will upload into ARW along with the photos

``` r
#**INPUT NEEDED* 
#set the path to the renamed photos if you did not already set it when renaming the photos
pathToFolder <- file.path(here(), "dataRenamed")

#set the list of the photo names
(photoNames <- list.files(path = pathToFolder, full.names = FALSE))
```

    ## [1] "BR_BR2_06_11_2024_001_ind.jpg" "BR_BR2_06_11_2024_002_ind.jpg"
    ## [3] "BR_BR2_06_11_2024_003_ind.jpg"

``` r
#Make sure that this is the list of photos that you want to import

#Create a table with the photo names
BatchImportdf <- data.frame(Encounter.mediaAsset0 = photoNames)


#**INPUT NEEDED**
# Extract details from the photo name
# Change the submitterID to your ARW login
# if this is the first time ever that this site is prospected, and you are confident that there are no duplicates in your photos, you can assign individual names without recognition (= each photo is set to a new individual name) by setting MarkedID = T.
(BatchImportdf_ready <- photo2batchimport(BatchImportdf,
                                         submitterID = "YourLoginARW",
                                         MarkedID = F))
```

    ##           Encounter.mediaAsset0 Encounter.day Encounter.month Encounter.year
    ## 1 BR_BR2_06_11_2024_001_ind.jpg            06              11           2024
    ## 2 BR_BR2_06_11_2024_002_ind.jpg            06              11           2024
    ## 3 BR_BR2_06_11_2024_003_ind.jpg            06              11           2024
    ##   Encounter.locationID Encounter.verbatimLocality Encounter.sightingID
    ## 1            Brequigny                     BR_BR2      BR_BR2_06112024
    ## 2            Brequigny                     BR_BR2      BR_BR2_06112024
    ## 3            Brequigny                     BR_BR2      BR_BR2_06112024
    ##   Encounter.alternateID Encounter.genus Encounter.specificEpithet
    ## 1      BR2_06112024_001      Salamandra                salamandra
    ## 2      BR2_06112024_002      Salamandra                salamandra
    ## 3      BR2_06112024_003      Salamandra                salamandra
    ##   Encounter.project0.researchProjectName Encounter.submitterID
    ## 1                        Salamandres BZH          YourLoginARW
    ## 2                        Salamandres BZH          YourLoginARW
    ## 3                        Salamandres BZH          YourLoginARW

``` r
# Make sure the final table is as expected

# Save the table for export - Change the file name to your needs. It will be exported in the same file as the photos.
write.csv(BatchImportdf_ready, file.path(pathToFolder, "BR_BR2_06112024.csv"), row.names = F)
```

Congratulations, this set of photos is ready for upload on ARW!
