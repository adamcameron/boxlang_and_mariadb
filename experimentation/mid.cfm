<cffunction name="capitalize" returntype="string" access="public" output="false">
	<cfargument name="text" type="string" required="true">
    <cfreturn text.left(1).ucase() & text.substring(1)>
	<!--- <cfscript>
		var loc = {};
		loc.rv = arguments.text;
		if (Len(loc.rv))
		{
			loc.rv = UCase(Left(loc.rv, 1)) & Mid(loc.rv, 2, Len(loc.rv)-1);
		}
	</cfscript>
	<cfreturn loc.rv> --->
</cffunction>
<cfoutput>
    capitalize("controller"): #capitalize("controller")#<br>

    regex: #"controller".reReplace("^(.)(.+)$", "\u\1\2")#<br>
</cfoutput>



<cfscript>
 s = "1234567890"

 for (i=1; i<=10; i++) {
    writeDump([
        i = i,
        mid = mid(s, 2, i),
        len = mid(s, 2, i).len(),
        substring = s.substring(int(i-1))
    ])
 }
</cfscript>
