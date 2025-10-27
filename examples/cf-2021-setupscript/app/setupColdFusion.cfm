<cfscript>
    // Login is always required. This example uses two lines of code.
    adminObj = createObject("component","CFIDE.adminapi.administrator");
    adminObj.login("123"); //CF Admin password
    // Create a MySQL datasource
    ext = createObject("component", "CFIDE.adminapi.extensions");
    ext.setMapping("/tmp", "/tmp2");
</cfscript>