<cfscript>
this.sessionmanagement="yes"
function onrequeststart () {
    cfparam (name="session.test", default="0"  )
}
</cfscript>
