\\muebcyp02fvg02\\eProcessing1$\\ROBOTICS\\Sybrin Echannel\\

Dim SavePath
Dim FileExtension
Dim subji
Dim file_count
Dim subj_len
Dim body_bam_bam
Dim global_counter
Dim date_payment
Dim num_trans_payment
Dim amount_payment
Dim num_records_pos_start_payment
Dim num_records_pos_end_payment
Dim amount_pos_start_payment
Dim amount_pos_end_payment
Dim date_error
Dim date_no_error
Dim num_records_pos_start_error
Dim num_records_pos_end_error
Dim num_records_error
Dim amount_pos_start_error
Dim amount_pos_end_error
Dim amount_error
dim objMessage

'write to excel
Dim payment_path
Dim error_path
Dim LastRow
Dim currentRow

'SavePath = wscript.Arguments(0-1-2-3)
'call script in wf-->Runtime.getRunTime().exec("wscript " + \\vbs_path\\ + " " + argument1 + " " + argument2 );
SavePath = "C:\Users\Muthe Udaya Sankar\Desktop\CEB Bill Payment\" 'Change path

'excel paths
payment_path = "C:\Users\Muthe Udaya Sankar\Desktop\CEB Bill Payment\payment.xlsx"
error_path = "C:\Users\Muthe Udaya Sankar\Desktop\CEB Bill Payment\processed.xlsx"
no_error_path = "C:\Users\Muthe Udaya Sankar\Desktop\CEB Bill Payment\no_error.xlsx"
'create excel objects
set xlapp = CreateObject("Excel.Application")
set xlapp2 = CreateObject("Excel.Application")
set xlapp3 = CreateObject("Excel.Application")
'create workbooks
Set payment_wkbk = xlapp.Workbooks.Open(payment_path)
Set error_wkbk = xlapp2.Workbooks.Open(error_path)
Set no_error_wkbk = xlapp3.Workbooks.Open(no_error_path)
'create sheets
set payment_sht = xlapp.activesheet
set error_sht = xlapp2.activesheet
set no_error_sht = xlapp3.activesheet
'configure settings
xlapp.DisplayAlerts = False
xlapp2.DisplayAlerts = False
xlapp3.DisplayAlerts = False
payment_sht.UsedRange 'Refresh UsedRange
error_sht.UsedRange 'Refresh UsedRange
no_error_sht.UsedRange 'Refresh UsedRange
'find last row
payment_LastRow = payment_sht.UsedRange.Rows(payment_sht.UsedRange.Rows.Count).Row
error_LastRow = error_sht.UsedRange.Rows(error_sht.UsedRange.Rows.Count).Row
no_error_LastRow = no_error_sht.UsedRange.Rows(no_error_sht.UsedRange.Rows.Count).Row
payment_currentRow = payment_LastRow + 1
error_currentRow = error_LastRow + 1
no_error_currentRow = no_error_LastRow + 1


'function to find position in string
Function FindN(sFindWhat, sInputString, N ) 
Dim J 
FindN = 0
For J = 1 To N
FindN = InStr(FindN + 1, sInputString, sFindWhat)
If FindN = 0 Then Exit For
Next
End Function

'Regex for date format yyyy-MM-dd
Set myRegExp = New RegExp
myRegExp.IgnoreCase = True
myRegExp.Global = True
myRegExp.Pattern = "([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))"

'Regex
Set myRegExp2 = New RegExp
myRegExp2.IgnoreCase = True
myRegExp2.Global = True
myRegExp2.Pattern = "([12]\d{3}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01]))"


FileExtension = "ARmessage"

Set objOutlook = CreateObject("Outlook.Application")
Set objNamespace = objOutlook.GetNamespace("MAPI")
Set objFolder = objNamespace.GetDefaultFolder(6) 'Inbox

Set colItems = objFolder.Items
Set colFilteredItems = colItems.Restrict("[Unread]=true")
'Set colFilteredItems = colItems.Restrict("[ReceivedTime]='"+now.ToShortDateString+"'") 'added 31/08/20


'For Each objMessage in colFilteredItems
For i = colFilteredItems.Count To 1 Step -1
	set objMessage = colFilteredItems(i)
	
	subji = objMessage.subject
	'msgbox subji
	
	
	'PAYMENT FILE
	If subji = "CEB PAYMENT FILE:ABSA.new" Then
		
		body_bam_bam = objMessage.body
		date_payment_temp = ""
		date_payment = ""
		num_trans_payment = ""
		amount_payment = ""
		
		'get date from error file via regex in yyyy-MM-dd
		Set myMatches2 = myRegExp2.Execute(body_bam_bam)
		For Each myMatch in myMatches2
			date_payment = myMatch.Value
		Next
		date_payment = Left(date_payment,4) & "-" & Mid(date_payment,5,2) & "-" & Right(date_payment,2) 'get date in standard format yyyy-MM-dd
		'MsgBox date_payment
		
		'get number of records in error file
		num_records_pos_start_payment = FindN("File:", objMessage.body,1)
		num_records_pos_end_payment = FindN("Total", objMessage.body,1)
		num_trans_payment = Mid(objMessage.body,num_records_pos_start_payment+5,((num_records_pos_end_payment - 1) - (num_records_pos_start_payment + 5)))
		'MsgBox num_trans_payment
		
		'get amount in error file
		amount_pos_start_payment = FindN("File:", objMessage.body, 2)
		amount_pos_end_payment = Len(objMessage.body) - (amount_pos_start_payment + 4)
		amount_error = Right(objMessage.body, amount_pos_end_payment)
		'MsgBox amount_error
		
		
		'save mail message
		objMessage.SaveAs SavePath & "PAYMENT_MESSAGE" & date_payment & ".msg"
		
		'write to payment.xlsx
		payment_sht.Cells(payment_currentRow,1).Value = formatDateTime(objMessage.ReceivedTime,2)
		payment_sht.Cells(payment_currentRow,2).Value = date_payment
		payment_sht.Cells(payment_currentRow,3).Value = num_trans_payment
		payment_sht.Cells(payment_currentRow,4).Value = amount_payment
		
		payment_currentRow = payment_currentRow + 1
		
		objMessage.Unread = False
		
	End If
	
	'ERROR FILE[PROCESSED]
	If inStr(subji,"PROCESSED:ABSA_ERR") > 0 Then 'filter in processed
		'MsgBox subji
		If inStr(subji,"NOT PROCESSED:ABSA_ERR") = 0 Then 'filter out not processed
			
			date_error = ""
			num_records_error = ""
			amount_error = ""
			
			'get date from error file via regex
			Set myMatches = myRegExp.Execute(objMessage.body)
			For Each myMatch in myMatches
			  date_error = myMatch.Value
			Next
			
			'get number of records in error file
			num_records_pos_start_error = FindN("File:", objMessage.body,1)
			num_records_pos_end_error = FindN("Total", objMessage.body,1)
			num_records_error = Mid(objMessage.body,num_records_pos_start_error+5,((num_records_pos_end_error - 1) - (num_records_pos_start_error + 5)))
			'MsgBox num_records_error
			
			'get amount in error file
			amount_pos_start_error = FindN("File:", objMessage.body, 2)
			amount_pos_end_error = Len(objMessage.body) - (amount_pos_start_error + 4)
			amount_error = Right(objMessage.body, amount_pos_end_error)
			'MsgBox amount_error
			
			'save mail message
			objMessage.SaveAs SavePath & "PROCESSED_MESSAGE" & date_error & ".msg"
			
			'write to processed.xlsx
			error_sht.Cells(error_currentRow,1).Value = formatDateTime(objMessage.ReceivedTime,2)
			error_sht.Cells(error_currentRow,2).Value = date_error
			error_sht.Cells(error_currentRow,3).Value = num_records_error
			error_sht.Cells(error_currentRow,4).Value = amount_error
			
			error_currentRow = error_currentRow + 1
			
			'download error text file if there are records
			If num_records_error > 0 Then
				intCount = objMessage.Attachments.Count
				MsgBox intCount
				For j = 1 To intCount
					objMessage.Attachments.Item(j).SaveAsFile SavePath & "error_file_" & date_error & ".txt"
				Next	
			End If
				
			objMessage.Unread = False	
			
		End If
	
	End If
	
	'NO ERROR FILES 
	IF inStr(subji,"NO CEB ERROR FILES PROCESSED") > 0  Then	'filter in no error files
	
		'get date from error file via regex
		Set myMatches = myRegExp.Execute(objMessage.body)
		For Each myMatch in myMatches
		  date_no_error = myMatch.Value
		Next
		
		'write to no_error.xlsx
		no_error_sht.Cells(no_error_currentRow,1).Value = formatDateTime(objMessage.ReceivedTime,2)
		no_error_sht.Cells(no_error_currentRow,2).Value = date_no_error
		
		objMessage.Unread = False	
		
	End If
	

Next
	


payment_wkbk.Save
error_wkbk.Save
no_error_wkbk.Save
payment_wkbk.Close SaveChanges=True
error_wkbk.Close SaveChanges=True
no_error_wkbk.Close SaveChanges=True
xlapp.Quit
xlapp2.Quit
xlapp3.Quit
Set payment_sht = Nothing
Set error_sht = Nothing
Set no_error_sht = Nothing
Set payment_wkbk=Nothing 
Set error_wkbk=Nothing 
Set no_error_wkbk=Nothing 
Set xlapp=Nothing
Set xlapp2=Nothing
Set xlapp3=Nothing



