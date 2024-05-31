<cftry>
    <cfthrow type="custom" message="my message" detail="my detail">
    <cfcatch>
        <cfdump var="#[
            type = cfcatch.type,
            message = cfcatch.message,
            detail = cfcatch.detail
        ]#">
    </cfcatch>
</cftry>

<cfscript>
    try {
        throw(type="MyException", message="my message", detail="my detail", extendedInfo="my extended info");
    } catch (any e) {
        writeDump([
            type = e.type,
            message = e.message,
            detail = e.detail,
            extendedInfo = e.extendedInfo
        ])
    }
</cfscript>
