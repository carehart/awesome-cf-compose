<cfcomponent>
    <cfset this.mappings["/"]=getdirectoryfrompath(getCurrentTemplatePath())>
</cfcomponent>