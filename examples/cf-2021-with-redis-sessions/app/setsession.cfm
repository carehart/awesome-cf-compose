<cfscript>
session.test++
writeoutput("Session.test=#session.test#! at #datetimeformat(now())#");
</cfscript>