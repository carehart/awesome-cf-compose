<cfdump var="#getApplicationMetadata()#">
<cfset currdir=expandPath("/")>
<cfdump var="#currdir#">
<cfdirectory action="list" directory="#currdir#" name="dir">
<cfdump var="#dir#">