<cfscript>
name="World"
writeoutput("Hello #name#! at #datetimeformat(now())#");
WriteDump(CacheGetEngineProperties()); // Returns the properties of the cache engine
WriteOutput("The caching engine currently used is: " & CacheGetEngineProperties().name); // Returns the name of the cache engine
</cfscript>