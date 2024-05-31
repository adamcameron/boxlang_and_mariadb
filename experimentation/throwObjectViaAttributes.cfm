<!--- control: throwing an object directly --->
<cftry>
    <cfthrow type="custom" message="my message" detail="my detail">
    <cfcatch>
        <cfset myException = cfcatch>
    </cfcatch>
</cftry>

<cftry>
    <cfthrow object="#myException#">
    <cfcatch>
        <cfdump var="#cfcatch#">
    </cfcatch>
</cftry>


<!--- test: throwing an object via attributecollection --->
<cftry>
    <cfthrow type="custom" message="my message" detail="my detail">
    <cfcatch>
        <cfset myException = cfcatch>
    </cfcatch>
</cftry>

<cftry>
    <cfset attrs = {object = myException}>
    <cfthrow attributecollection="#attrs#">
    <cfcatch>
        <cfdump var="#cfcatch#">
    </cfcatch>
</cftry>
