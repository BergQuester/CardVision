# CardVision

## Purpose

While the Wallet app provides exports for Apple Cards at the end of each month, many of us like to handle our budgets on a more frequent basis. However, the Wallet app provides no mechanism for this. This package uses Apple's Vision framework to read Wallet screenshots and export transactions to CVS files.

## Example

```
import CardVision

let filePath = "path_to_directory_of_images"

let csvData = FileManager()
    .images(inPath: filePath)
    .allTransactions()
    .filtered(isDeclined: false)
    .csvData
```

## Limitations



## Contributions

Contributions are welcome. Some areas that need some help:

* Real error handling
* API documentation
* Tests
* Address limitations

## Liscense
