spreadsheet = {
  properties: {
    title: 'Sales Report'
  }
}
spreadsheet = service.create_spreadsheet(spreadsheet,
                                         fields: 'spreadsheetId')
puts "Spreadsheet ID: #{spreadsheet.spreadsheet_id}"