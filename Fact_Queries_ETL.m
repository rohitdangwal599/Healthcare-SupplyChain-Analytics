/* ==========================================
   FACT CONSUMPTION ETL TRANSFORMATIONS
   ================ ========================== */
let
    Source = Excel.Workbook(File.Contents(SourceFilePath & "\Report Nov25 to Jan26.xlsx"), null, true),
    DSR_Sheet = Source{[Item="DSR",Kind="Sheet"]}[Data],
    #"Removed Top Rows" = Table.Skip(DSR_Sheet,1),
    #"Promoted Headers" = Table.PromoteHeaders(#"Removed Top Rows", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"Perticulars", type text}, {"Opening Qty", Int64.Type}, {"Purchase Qty", Int64.Type}, {"Stock Transfer Sent", Int64.Type}, {"Stock Transfer Received", Int64.Type}, {"Retail Consumption Qty", Int64.Type}, {"Department Consumption Qty", Int64.Type}, {"Stock Adjustment Reduction Qty", Int64.Type}, {"Retail Return Qty", Int64.Type}, {"Stock Adjustment Increment Qty", Int64.Type}, {"Department Return Qty", Int64.Type}, {"Purchase Return Qty", Int64.Type}, {"Company", type text}, {"Closing Qty", Int64.Type}, {"Organization", type text}, {"Category", type text}, {"Revised Catoegry", type text}, {"Actual Consumption", Int64.Type}, {"Factor", Int64.Type}, {"Revised Consumption", Int64.Type}, {"Price", type number}, {"Consumption Value", Int64.Type}, {"Centre Name", type text}, {"Month", type date}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Perticulars", "Product Name"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns", "Expected Closing Stock", each [Opening Qty]+[Purchase Qty]+[Stock Transfer Received]+[Stock Adjustment Increment Qty]-[Stock Transfer Sent]-[Retail Consumption Qty]-[Department Consumption Qty]-[Stock Adjustment Reduction Qty]-[Retail Return Qty]-[Department Return Qty]-[Purchase Return Qty]),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "Stock Variance", each [Closing Qty]-[Expected Closing Stock]),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "Value of closing stock", each [Closing Qty]*[Price]),
    #"Added Custom3" = Table.AddColumn(#"Added Custom2", "Adjusted Increment Value", each [Stock Adjustment Increment Qty]*[Price]),
    #"Added Custom4" = Table.AddColumn(#"Added Custom3", "Adjusted Reduction Value", each [Stock Adjustment Reduction Qty]*[Price]),
    #"Renamed Columns1" = Table.RenameColumns(#"Added Custom4",{{"Month", "Month_Date"}}),
    #"Inserted Month Name" = Table.AddColumn(#"Renamed Columns1", "Month Name", each Date.MonthName([Month_Date]), type text),
    #"Inserted Year" = Table.AddColumn(#"Inserted Month Name", "Year", each Date.Year([Month_Date]), Int64.Type),
    #"Inserted Month" = Table.AddColumn(#"Inserted Year", "Month", each Date.Month([Month_Date]), Int64.Type),
    #"Renamed Columns2" = Table.RenameColumns(#"Inserted Month",{{"Month", "Month No"}, {"Month_Date", "Month_End_Date"}}),
    #"Trimmed Text" = Table.TransformColumns(#"Renamed Columns2",{{"Product Name", Text.Trim, type text}}),
    #"Cleaned Text" = Table.TransformColumns(#"Trimmed Text",{{"Product Name", Text.Clean, type text}}),
    #"Lowercased Text" = Table.TransformColumns(#"Cleaned Text",{{"Product Name", Text.Lower, type text}}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Lowercased Text",{{"Expected Closing Stock", type number}, {"Stock Variance", type number}, {"Value of closing stock", type number}, {"Adjusted Increment Value", type number}, {"Adjusted Reduction Value", type number}})
in
    #"Changed Type1"





/* ==========================================
   FACT PURCHASES ETL TRANSFORMATIONS
   ================ ========================== */
let
    Source = Excel.Workbook(File.Contents("C:\Users\DELL\Desktop\Report Nov25 to Jan26.xlsx"), null, true),
    Purchase_Sheet = Source{[Item="Purchase",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Purchase_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"S No.", Int64.Type}, {"Bill Date", type date}, {"Invoice No", type text}, {"Product Name", type text}, {"Organisation", type text}, {"Quantity", Int64.Type}, {"Rate", type number}, {"Final Amt", type number}, {"Month", type date}, {"Center Name", type text}}),
    #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Bill Date", "Purchase_Date"}, {"Month", "Month_End_Date"}}),
    #"Removed Columns" = Table.RemoveColumns(#"Renamed Columns",{"S No."}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns",{{"Center Name", "Organisation_Code"}}),
    #"Trimmed Text" = Table.TransformColumns(#"Renamed Columns1",{{"Product Name", Text.Trim, type text}}),
    #"Cleaned Text" = Table.TransformColumns(#"Trimmed Text",{{"Product Name", Text.Clean, type text}}),
    #"Lowercased Text" = Table.TransformColumns(#"Cleaned Text",{{"Product Name", Text.Lower, type text}}),
    #"Renamed Columns2" = Table.RenameColumns(#"Lowercased Text",{{"Final Amt", "Purchase Value"}})
in
    #"Renamed Columns2"