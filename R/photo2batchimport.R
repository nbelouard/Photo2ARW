#'Create the "batch import" table for Amphibian and Reptile Wildbook
#'
#'@export
#'
#'@param BatchImportdf A dataset to be processed
#'@param submitterID Name of the person submitting the data
#'
#'@return The table to upload on ARW Batch Import
#'
#'@examples
#'\dontrun{
#' new_dataset <- photo2batchimport(dataset)
#'}


photo2batchimport <- function(BatchImportdf = BatchImportdf,
                      submitterID = "Votre Nom",
                      MarkedID = F) {
  # Parse the file name into distinct columns
  BatchImportdf %<>% separate(Encounter.mediaAsset0,
                              into = c("locationIDcode", "transect",
                                       "Encounter.day", "Encounter.month", "Encounter.year",
                                       "indnumber", "format"), sep = "_", remove = FALSE)

  # Create custom variables
  BatchImportdf %<>% mutate(Encounter.locationID = ifelse(locationIDcode == "POT", "Poterie",
                                                          ifelse(locationIDcode == "PVL",
                                                                 "Prevalaye", "Bois de Soeuvres")),
                            Encounter.verbatimLocality = paste0(locationIDcode, "_", transect),
                            fullDate = paste0(Encounter.day, Encounter.month, Encounter.year)) %>%
    mutate(Encounter.sightingID = paste0(Encounter.verbatimLocality, "_", fullDate),
           Encounter.alternateID = paste0(transect, "_", fullDate, "_", indnumber))

  # Add general parameters
  BatchImportdf %<>% mutate(Encounter.genus = "Salamandra",
                            Encounter.specificEpithet = "salamandra",
                            Encounter.project0.researchProjectName = "Salamandres BZH",
                            Encounter.submitterID = submitterID)

  # if these are the original session without possible recaptures, add names
  if (MarkedID == T){
    BatchImportdf %<>% mutate(MarkedIndividual.individualID = paste0(locationIDcode, "_", transect, "_", indnumber))
  }

  # Remove columns that are useless now
  BatchImportdf %<>% select(-locationIDcode, -transect, -indnumber, -format, -fullDate)

  return(BatchImportdf)
}
