<cfset week = queryNew("id,en,mi", "integer,varchar,varchar", [
	[1,"Monday","Rāhina"],
	[2,"Tuesday","Rātū"],
	[3,"Wednesday","Rāapa"],
	[4,"Thursday","Rāpare"],
	[5,"Friday","Rāmere"],
	[6,"Saturday","Rāhoroi"],
	[7,"Sunday","Rātapu"]
])>
<cfset weekend = queryFilter(week, function (day) { return day.id GE 6})>
<cfdump var="#weekend#">
