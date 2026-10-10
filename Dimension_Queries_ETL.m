/* ==========================================
   DIM PRODUCT ETL TRANSFORMATIONS
   ================ ========================== */

let
    Source = Fact_Consumption,
    #"Removed Other Columns" = Table.SelectColumns(Source,{"Product Name", "Company", "Organization", "Category", "Revised Catoegry", "Price"}),
    #"Trimmed Text" = Table.TransformColumns(#"Removed Other Columns",{{"Product Name", Text.Trim, type text}}),
    #"Cleaned Text" = Table.TransformColumns(#"Trimmed Text",{{"Product Name", Text.Clean, type text}}),
    #"Removed Blank Rows" = Table.SelectRows(#"Cleaned Text", each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
    #"Removed Duplicates" = Table.Distinct(#"Removed Blank Rows", {"Product Name"}),
    #"Removed Columns" = Table.RemoveColumns(#"Removed Duplicates",{"Organization"}),
    #"Removed Duplicates1" = Table.Distinct(#"Removed Columns", {"Product Name"}),
    #"Removed Columns1" = Table.RemoveColumns(#"Removed Duplicates1",{"Company", "Price"}),
    #"Removed Duplicates2" = Table.Distinct(#"Removed Columns1", {"Product Name"}),
    #"Trimmed Text1" = Table.TransformColumns(#"Removed Duplicates2",{{"Product Name", Text.Trim, type text}}),
    #"Cleaned Text1" = Table.TransformColumns(#"Trimmed Text1",{{"Product Name", Text.Clean, type text}}),
    #"Lowercased Text" = Table.TransformColumns(#"Cleaned Text1",{{"Product Name", Text.Lower, type text}}),
    #"Removed Duplicates3" = Table.Distinct(#"Lowercased Text", {"Product Name"})
in
    #"Removed Duplicates3"


/* ==========================================
   DIM CENTER ETL TRANSFORMATIONS
   ================ ========================== */

let
    Source = Fact_Consumption,
    #"Removed Other Columns" = Table.SelectColumns(Source,{"Company", "Organization", "Centre Name"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns",{{"Centre Name", "Organisation_Code"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"Company"}),
    #"Removed Duplicates" = Table.Distinct(#"Removed Columns", {"Organization"})
in
    #"Removed Duplicates"


/* ==========================================
   DIM DATE ETL TRANSFORMATIONS
   ================ ========================== */

let
    Source = Fact_Purchases,
    #"Removed Other Columns" = Table.SelectColumns(Source,{"Purchase_Date", "Month_End_Date"}),
    #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns"),
    #"Inserted Year" = Table.AddColumn(#"Removed Duplicates", "Year", each Date.Year([Purchase_Date]), Int64.Type),
    #"Inserted Month" = Table.AddColumn(#"Inserted Year", "Month", each Date.Month([Purchase_Date]), Int64.Type),
    #"Inserted Month Name" = Table.AddColumn(#"Inserted Month", "Month Name", each Date.MonthName([Purchase_Date]), type text),
    #"Added Custom" = Table.AddColumn(#"Inserted Month Name", "Month_Year", each Text.From([Year]) &"-"& Text.PadStart(Text.From([Month]),2,"0")),
    #"Removed Duplicates1" = Table.Distinct(#"Added Custom", {"Purchase_Date"})
in
    #"Removed Duplicates1"