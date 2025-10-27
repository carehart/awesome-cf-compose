<cfhtmltopdf name="test">
<cfoutput>test at #datetimeformat(now())#</cfoutput>
</cfhtmltopdf>
<cfheader name="Content-Disposition" value="attachment; filename=cfhtmltopdf-test.pdf">
<cfcontent reset="yes" type="application/pdf" variable="#test#">