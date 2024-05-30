<cfcomponent>

<cfdirectory action="list" directory="#expandPath("includes/dynamic")#" name="includes">
<cfloop query="includes">
	<cfinclude template="includes/dynamic/#includes.name#">
</cfloop>

<cfinclude template="includes/static/c.cfm">
<cfinclude template="includes/static/d.cfm">

</cfcomponent>
