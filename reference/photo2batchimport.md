# Create the "batch import" table for Amphibian and Reptile Wildbook

Create the "batch import" table for Amphibian and Reptile Wildbook

## Usage

``` r
photo2batchimport(
  BatchImportdf = BatchImportdf,
  submitterID = "Votre Nom",
  MarkedID = F
)
```

## Arguments

- BatchImportdf:

  A dataset to be processed

- submitterID:

  Name of the person submitting the data

## Value

The table to upload on ARW Batch Import

## Examples

``` r
if (FALSE) { # \dontrun{
new_dataset <- photo2batchimport(dataset)
} # }
```
