<!--- this is a rather silly example, in that it indexes the standard linix /var/log folder.
I'm using that as something simply to rely upon to confirm that indexing any folder (and dumping  
the contents of a search of that index) can be demonstrated to have worked.
--->
<cfindex action="update" collection="test" type="path" key="/var/log/" extensions=".log">

<cfsearch collection="test" name="get"> 
<cfdump var="#get#"> 
