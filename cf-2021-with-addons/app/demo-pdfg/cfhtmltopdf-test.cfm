<cfhtmltopdf name="test">
test
</cfhtmltopdf>
<cfheader name="Content-Disposition" value="attachment; filename=cfhtmltopdf-test.pdf">
<cfcontent reset="yes" type="application/pdf" variable="#test#">