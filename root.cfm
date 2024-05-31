<cftry>
<cfinvoke component="#loc.component#" method="#loc.method#" returnVariable="#loc.returnVariable#" argumentCollection="#loc.argumentCollection#">
    <cfcatch>
        <cfrethrow>
        <cfdump var="#loc#">
        <cfdump var="#cfcatch#">
        <cfabort>
    </cfcatch>
</cftry>
