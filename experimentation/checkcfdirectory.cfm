<cfscript>
    cfmFiles = directoryList(
        path = "#getDirectoryFromPath(getCurrentTemplatePath())#",
        filter = "*.cfm",
        listInfo = "query"
    )
    writeDump(cfmFiles)
    stillNone = cfmFiles.filter((row) => true)
    writeDump(stillNone)
</cfscript>


<cfset cfmFiles2 = directoryList(
    path = "#getDirectoryFromPath(getCurrentTemplatePath())#",
    filter = "*.cfm",
    listInfo = "query"
)>
<cfdump var="#cfmFiles2#">
<cftry>
    <cfset stillNone2 = cfmFiles2.filter((row) => true)>
    <cfdump var="#stillNone2#">
    <cfcatch>
        <cfdump var="#cfcatch#">
    </cfcatch>
</cftry>
