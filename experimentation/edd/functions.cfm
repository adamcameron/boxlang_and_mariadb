<!--- Place functions here that should be globally available in your application. --->

<!--- load udfs includes --->
<cfdirectory action="list" directory="udfs" name="includes" />
<cfloop query="includes">
	<cfinclude template="udfs/#includes.name#">
</cfloop>


<cffunction name="isDebugIP" returntype="boolean">
	<cfreturn request.remote_addr eq "185.59.60.152">
</cffunction>


<cffunction name="getLuceeUptimeAsDuration" returntype="string" access="public" output="false">
	<cfset local.lucee_start_time_in_ticks = CreateObject(
		"java",
		"lucee.loader.engine.CFMLEngineFactory"
	).getInstance().uptime()>
	<cfset local.lucee_up_time_as_ticks = GetTickCount() - local.lucee_start_time_in_ticks>
	<cfset local.lucee_up_time_as_seconds = local.lucee_up_time_as_ticks / 1000>

	<cfreturn $convertSecondsToDuration(local.lucee_up_time_as_seconds)>
</cffunction>


<cffunction name="getServerUptimeAsDuration" returntype="string" access="public" output="false">
	<cfset local.server_up_time = ParseDateTime(get("serverUpTime"), "yyyy-mm-dd HH:nn:ss", "Europe/London")>
	<cfset local.server_up_time_as_seconds = local.server_up_time.diff("s", Now())>

	<cfreturn $convertSecondsToDuration(local.server_up_time_as_seconds)>
</cffunction>


<cffunction name="getApplicationUptimeAsDuration" returntype="string" access="public" output="false">
	<cfset local.application_up_time = ParseDateTime(application.start_time, "yyyy-mm-dd HH:nn:ss", "Europe/London")>
	<cfset local.application_up_time_as_seconds = local.application_up_time.diff("s", Now())>
	<cfif local.application_up_time_as_seconds LT 0>
		<cfset local.application_up_time_as_seconds = 0>
	</cfif>
	<cfreturn $convertSecondsToDuration(local.application_up_time_as_seconds)>
</cffunction>

<cffunction name="getContainerUptimeAsDuration" returntype="string" access="public" output="false">
	<cfset local.container_up_time = ParseDateTime(get("containerUpTime"), "yyyy-mm-dd HH:nn:ss", "Europe/London")>
	<cfset local.container_up_time_as_seconds = local.container_up_time.diff("s", Now())>

	<cfreturn $convertSecondsToDuration(local.container_up_time_as_seconds)>
</cffunction>


<cffunction name="$convertSecondsToDuration" returntype="string" access="public" output="false">
	<cfargument name="seconds" type="numeric" required="true">
	<cfset local.minutes = int(arguments.seconds / 60)>
	<cfset local.hours = int(local.minutes / 60)>
	<cfset local.days = int(local.hours / 24)>
	<cfset local.duration = "#numberFormat(local.days, "00")#"
		& ":#numberFormat(local.hours % 24, "00")#"
		& ":#numberFormat(local.minutes % 60, "00")#"
		& ":#numberFormat(arguments.seconds % 60, "00")#">

	<cfreturn local.duration>
</cffunction>


<cffunction name="julianDate" returntype="string" output="false">
	<cfargument name="input" type="date" required="true">
	<cfset local.first_jan = CreateDate(Year(arguments.input), 1, 1)>
	<cfreturn DateFormat(arguments.input, "YY") & NumberFormat(DateDiff("d", local.first_jan, arguments.input) + 1, "000")>
</cffunction>


<cffunction name="epochToDate" returnformat="date" output="false">
	<cfargument name="epoch" type="numeric" required="true">
	<cfreturn DateAdd("s", arguments.epoch, "1970-01-01")>
</cffunction>


<cffunction name="isAfterBacsSubmissionHour" returntype="boolean" output="false" hint="Returns if the passed-in date is after the BACS submission time (currently 17:00 each day)">
	<cfargument name="date_time" type="date" required="true" hint="DateTime to check">
	<cfset local.london_time = getLondonTime(arguments.date_time)>
	<cfset local.bacs_submission_hour = get("bacsSubmissionHour")>
	<cfset local.submission_time = arguments.date_time.duplicate().setHour(local.bacs_submission_hour).setMinute(0).setSecond(0)>
	<cfset local.is_after_submission_time = london_time.compare(local.submission_time) gte 0>
	<cfreturn local.is_after_submission_time>
</cffunction>


<cffunction name="getLondonTime">
	<cfargument name="dt" type="date" default="#Now()#">

	<cfset local.london_time = arguments.dt.duplicate()>
	<cfset local.london_offset = $getOffsetFromUtcInMinutesForTimeZone(arguments.dt, "Europe/London")>
	<cfif local.london_offset neq 0>
		<cfreturn local.london_time.add("n", local.london_offset)>
	</cfif>
	<cfreturn local.london_time>
</cffunction>


<cffunction name="$getOffsetFromUtcInMinutesForTimeZone" access="private" returntype="numeric" output="false">
	<cfargument name="utc_date_time" type="date" required="true" hint="A datetime object (which are UTC by default).">
	<cfargument name="zone_id" type="string" required="true" hint="String identifier for time zone as per java.time.ZoneId.">

	<cfset local.time_zone = createObject("java", "java.util.TimeZone").getTimeZone(arguments.zone_id)>
	<cfset local.offset_in_milliseconds = time_zone.getOffset(arguments.utc_date_time.getTime())>
	<cfset local.offset_in_minutes = local.offset_in_milliseconds / 1000 / 60>

	<cfreturn local.offset_in_minutes>
</cffunction>


<cffunction name="getNextWorkingDay" returntype="date" output="false">
	<cfargument name="start_date" type="date" required="true">
	<cfargument name="country_code" type="string" required="true">
	<cfargument name="gateway_type" type="string" default="">
	<cfloop condition="true">
		<cfif not isWorkingDay(arguments.start_date, arguments.country_code, arguments.gateway_type)>
			<cfset arguments.start_date = DateAdd("d", 1, arguments.start_date)>
		<cfelse>
			<cfbreak>
		</cfif>
	</cfloop>
	<cfreturn arguments.start_date>
</cffunction>


<cffunction name="workingDaysAdd" returntype="date" output="false">
	<cfargument name="start" type="date" required="true">
	<cfargument name="days" type="numeric" required="true">
	<cfargument name="country_code" type="string" required="true">
	<cfargument name="gateway_type" type="string" default="">
	<cfset local.day_counter = 0>
	<cfset local.reverse = false>
	<cfif arguments.days lt 0>
		<cfset local.reverse = true>
		<cfset arguments.days = Abs(arguments.days)>
	</cfif>
	<cfset arguments.start = getNextWorkingDay(arguments.start, arguments.country_code, arguments.gateway_type)>
	<cfloop condition="true">
		<cfif local.reverse>
			<cfset arguments.start = DateAdd("d", -1, arguments.start)>
		<cfelse>
			<cfset arguments.start = DateAdd("d", 1, arguments.start)>
		</cfif>
		<cfif isWorkingDay(arguments.start, arguments.country_code, arguments.gateway_type)>
			<cfset local.day_counter++>
		</cfif>
		<cfif local.day_counter eq arguments.days>
			<cfbreak>
		</cfif>
	</cfloop>
	<cfreturn arguments.start>
</cffunction>


<cffunction name="isBankHoliday" returntype="boolean" output="false">
	<cfargument name="test_date" type="date" required="true">
	<cfargument name="country_code" type="string" required="true">

	<cfset local.bank_holidays = getBankHolidays(arguments.country_code)>

	<cfreturn local.bank_holidays.find(DateFormat(arguments.test_date, "yyyy-mm-dd")) neq 0>
</cffunction>


<cffunction name="getBankHolidays" returntype="array" output="false">
	<cfargument name="country_code" type="string" required="true">

	<cfif arguments.country_code EQ "GB">
		<cfreturn [
			"2020-01-01", "2020-04-10", "2020-04-13", "2020-05-08", "2020-05-25", "2020-08-31", "2020-12-25", "2020-12-28",
			"2021-01-01", "2021-04-02", "2021-04-05", "2021-05-03", "2021-05-31", "2021-08-30", "2021-12-27", "2021-12-28",
			"2022-01-03", "2022-04-15", "2022-04-18", "2022-05-02", "2022-06-02", "2022-06-03", "2022-08-29", "2022-09-19", "2022-12-26", "2022-12-27",
			"2023-01-02", "2023-04-07", "2023-04-10", "2023-05-01", "2023-05-08", "2023-05-29", "2023-08-28", "2023-12-25", "2023-12-26",
			"2024-01-01", "2024-03-29", "2024-04-01", "2024-05-06", "2024-05-27", "2024-08-26", "2024-12-25", "2024-12-26",
			"2025-01-01", "2025-04-18", "2025-04-21", "2025-05-05", "2025-05-26", "2025-08-25", "2025-12-25", "2025-12-26"
		]>
	</cfif>

	<cfif arguments.country_code EQ "IE">
		<cfreturn [
			"2020-01-01", "2020-03-17", "2020-04-13", "2020-05-04", "2020-06-01", "2020-08-03", "2020-10-26", "2020-12-25",
			"2021-01-01", "2021-03-17", "2021-04-05", "2021-05-03", "2021-06-07", "2021-08-02", "2021-10-25",
			"2022-01-03", "2022-03-17", "2022-04-18", "2022-05-02", "2022-06-06", "2022-08-01", "2022-10-31", "2022-12-26",
			"2023-01-01", "2023-02-06", "2023-03-17", "2023-04-10", "2023-05-01", "2023-06-05", "2023-08-07", "2023-10-30", "2023-12-25", "2023-12-26",
			"2024-01-01", "2024-02-05", "2024-03-18", "2024-04-01", "2024-05-06", "2024-06-03", "2024-08-05", "2024-10-28", "2024-12-25", "2024-12-26",
			"2025-01-01", "2025-02-03", "2025-03-17", "2025-04-21", "2025-05-05", "2025-06-02", "2025-08-04", "2025-10-27", "2025-12-25", "2025-12-26"
		]>
	</cfif>

	<cfthrow message="Invalid country code" detail="Country code '#arguments.country_code#' is not recognised">
</cffunction>


<cffunction name="isWorkingDay" returntype="boolean" output="false">
	<cfargument name="test_date" type="date" required="true">
	<cfargument name="country_code" type="string" required="true">
	<cfargument name="gateway_type" type="string" default="">

	<cfif ListFind("2,3,4,5,6", DayOfWeek(arguments.test_date)) eq 0>
		<cfreturn false>
	</cfif>

	<cfreturn isProcessingDay(
		test_date = arguments.test_date,
		country_code = arguments.country_code,
		gateway_type = arguments.gateway_type
	)>
</cffunction>


<cffunction name="getFirstWorkingDayOfWeek" output="false" returntype="string">
	<cfargument type="date" name="start_date" default="#Now()#">

	<cfset local.start_date = CreateDateTime(Year(arguments.start_date), Month(arguments.start_date), Day(arguments.start_date), 0, 0, 0)>
	<cfset local.days_in_a_week = 7>
	<cfset local.monday_as_day_of_week = 2>
	<cfset local.days_after_monday = (DayOfWeek(local.start_date) - local.monday_as_day_of_week + local.days_in_a_week) MOD local.days_in_a_week>
	<cfset local.previous_monday = DateAdd("d", -local.days_after_monday, local.start_date)>

	<cfreturn getNextWorkingDay(local.previous_monday, "GB")>
</cffunction>


<cffunction name="isProcessingDay" returntype="boolean" output="false">
	<cfargument name="test_date" type="date" required="true">
	<cfargument name="country_code" type="string" required="true">
	<cfargument name="gateway_type" type="string" default="">

	<cfif arguments.gateway_type eq "sepa">
		<cfset local.sepa_days = getSEPANonProcessingDays()>
		<cfreturn local.sepa_days.find(DateFormat(arguments.test_date, "yyyy-mm-dd")) eq 0>
	</cfif>

	<cfreturn not isBankHoliday(test_date = arguments.test_date, country_code = arguments.country_code)>
</cffunction>


<cffunction name="getSEPANonProcessingDays" returntype="array" output="false">

	<!---
	taken from the asterisked dates at
	https://www.ecb.europa.eu/services/contacts/working-hours/html/index.en.html
	--->
	<cfreturn [
		"2023-01-01", "2023-04-07", "2023-04-10", "2023-05-01", "2023-12-25", "2023-12-26",
		"2024-01-01", "2024-03-29", "2024-04-01", "2024-05-01", "2024-12-25", "2024-12-26",
		"2025-01-01", "2025-04-18", "2025-04-21", "2025-05-01", "2025-12-25", "2025-12-26"
	]>
</cffunction>


<cfscript>
/**
 * Makes a row of a query into a structure.
 *
 * @param query 	 The query to work with.
 * @param row 	 Row number to check. Defaults to row 1.
 * @return Returns a structure.
 * @author Nathan Dintenfass (&#110;&#97;&#116;&#104;&#97;&#110;&#64;&#99;&#104;&#97;&#110;&#103;&#101;&#109;&#101;&#100;&#105;&#97;&#46;&#99;&#111;&#109;)
 * @version 1, December 11, 2001
 */
function queryRowToStruct(query){
	//by default, do this to the first row of the query
	var row = 1;
	//a var for looping
	var ii = 1;
	//the cols to loop over
	var cols = arguments.query.getColumns();
	//the struct to return
	var stReturn = structnew();
	//if there is a second argument, use that for the row number
	if(arrayLen(arguments) GT 1)
		row = arguments[2];
	//loop over the cols and build the struct from the query row
	for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
		stReturn[cols[ii]] = query[cols[ii]][row];
	}
	//return the struct
	return stReturn;
}
</cfscript>


<cffunction name="futurePayments" returntype="array" output="false">
	<cfargument name="start_date" type="date" required="true">
	<cfargument name="end_date" type="date" required="true">
	<cfargument name="interval_unit" type="string" required="true">
	<cfargument name="payment_day" type="numeric" required="true">
	<cfset local.result = ArrayNew()>
	<cfif arguments.interval_unit eq "weekly">
		<cfset arguments.start_date = createPaymentDateWeekly(argumentCollection=arguments)>
		<cfset ArrayAppend(local.result, DateFormat(arguments.start_date, "yyyy-mm-dd"))>
		<cfloop condition="true">
			<cfset arguments.start_date = DateAdd("ww", 1, arguments.start_date)>
			<cfif DateDiff("d", arguments.start_date, arguments.end_date) gt 0>
				<cfset ArrayAppend(local.result, DateFormat(arguments.start_date, "yyyy-mm-dd"))>
			<cfelse>
				<cfbreak>
			</cfif>
		</cfloop>
	<cfelse>
		<cfset arguments.start_date = createPaymentDate(argumentCollection=arguments)>
		<cfset ArrayAppend(local.result, DateFormat(arguments.start_date, "yyyy-mm-dd"))>
		<cfloop condition="true">
			<cfset arguments.start_date = createPaymentDate(payment_day=arguments.payment_day, start_date=DateAdd("d", 1, arguments.start_date))>
			<cfif DateDiff("d", arguments.start_date, arguments.end_date) gt 0>
				<cfset ArrayAppend(local.result, DateFormat(arguments.start_date, "yyyy-mm-dd"))>
			<cfelse>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
	<cfreturn local.result>
</cffunction>


<cffunction name="futurePaymentsCount" returntype="numeric" output="false">
	<cfreturn ArrayLen(futurePayments(argumentCollection=arguments))>
</cffunction>


<cffunction name="splitPayments" returntype="struct" output="false">
	<cfargument name="amount" type="numeric" required="true">
	<cfargument name="payments" type="numeric" required="true">
	<cfset local.amount = Int(arguments.amount / arguments.payments)>
	<cfset local.amount_first = Round(arguments.amount mod arguments.payments) + local.amount>
	<cfreturn local>
</cffunction>


<cffunction name="createPaymentDate" returntype="date" output="false">
	<cfargument name="payment_day" type="numeric" required="true">
	<cfargument name="start_date" type="date" required="true">
	<cfargument name="start_from_first" type="boolean" default="false" hint="Set to true to start from 1st of month">
	<cfargument name="lead_days" type="numeric" default="0" hint="I am the number of days in the future the payment date must be">
	<cfif arguments.start_from_first>
		<cfset local.start_date = CreateDate(Year(arguments.start_date), Month(arguments.start_date), 1)>
	<cfelse>
		<cfset local.start_date = CreateDate(Year(arguments.start_date), Month(arguments.start_date), Day(arguments.start_date))>
	</cfif>
	<cfif arguments.payment_day eq -1 or arguments.payment_day gt 28>
		<cfset local.payment_date = CreateDate(Year(local.start_date), Month(local.start_date), 1)>
		<cfset local.payment_date = DateAdd("m", 1, local.payment_date)>
		<cfset local.payment_date = DateAdd("d", -1, local.payment_date)>
	<cfelse>
		<cfset local.payment_date = CreateDate(Year(local.start_date), Month(local.start_date), arguments.payment_day)>
	</cfif>
	<cfloop condition="true">
		<cfif DateDiff("d", local.start_date, local.payment_date) lt arguments.lead_days>
			<cfset local.payment_date = DateAdd("m", 1, local.payment_date)>
		<cfelse>
			<cfreturn local.payment_date>
		</cfif>
	</cfloop>
</cffunction>


<cffunction name="createPaymentDateWeekly" returntype="date" output="false">
	<cfargument name="payment_day" type="numeric" required="true">
	<cfargument name="start_date" type="date" required="true">
	<cfset local.payment_date = arguments.start_date>
	<cfloop condition="true">
		<cfif DayOfWeek(local.payment_date) eq arguments.payment_day>
			<cfreturn local.payment_date>
		<cfelse>
			<cfset local.payment_date = DateAdd("d", 1, local.payment_date)>
		</cfif>
	</cfloop>
</cffunction>


<cffunction name="currencyFormat" returntype="string" output="false">
	<cfargument name="amount" type="string" required="true">
	<cfargument name="currency" type="string" required="true">
	<cfargument name="html" type="boolean" default="true">
	<cfargument name="decimal" type="boolean" default="true">
	<cfif not IsNumeric(arguments.amount)>
		<cfreturn "n/a">
	</cfif>
	<cfswitch expression="#arguments.currency#">
		<cfcase value="GBP">
			<cfset local.symbol = (arguments.html ? "&pound;" : Chr(163))>
		</cfcase>
		<cfcase value="EUR">
			<cfset local.symbol = (arguments.html ? "&euro;" : Chr(8364))>
		</cfcase>
		<cfdefaultcase>
			<cfthrow message="Invalid currency code" detail="Currency code '#arguments.currency#' is not supported">
		</cfdefaultcase>
	</cfswitch>
	<cfif arguments.decimal>
		<cfif arguments.html and arguments.amount lt 0>
			<cfreturn '<span style="color:red;">' & local.symbol & DecimalFormat(arguments.amount / 100) & '</span>'>
		<cfelse>
			<cfreturn local.symbol & DecimalFormat(arguments.amount / 100)>
		</cfif>
	<cfelse>
		<cfif arguments.html and arguments.amount lt 0>
			<cfreturn '<span style="color:red;">' & local.symbol & NumberFormat(arguments.amount / 100, ",9") & '</span>'>
		<cfelse>
			<cfreturn local.symbol & NumberFormat(arguments.amount / 100, ",9")>
		</cfif>
	</cfif>
</cffunction>


<cffunction name="periodFormat" returntype="string" output="false">
	<cfargument name="period" type="any" required="true" />
	<cfreturn Left(MonthAsString(Right(arguments.period, 2)), 3) & " " & Left(arguments.period, 4)>
</cffunction>


<cffunction name="mobileFormat" returntype="string" output="false">
	<cfargument name="number" type="string" required="true">
	<cfargument name="cc" type="numeric" required="true">
	<!--- remove any invalid chars --->
	<cfset local.result = ReReplace(arguments.number, "[^0-9]", "", "all")>
	<!--- trip leading zero --->
	<cfif Left(local.result, 1) eq 0>
		<cfset local.result = Right(local.result, Len(local.result)-1)>
	</cfif>
	<!--- append country code --->
	<cfset local.result = "+" & arguments.cc & local.result>
	<cfreturn local.result>
</cffunction>


<cffunction name="stripNonNumeric" returntype="string" output="false">
	<cfargument name="number" type="string" required="true">
	<cfset local.result = ReReplace(arguments.number, "[^0-9]", "", "all")>
	<cfreturn local.result>
</cffunction>


<cffunction name="stripHtml" returntype="string" output="false">
	<cfargument name="str" type="string" required="true">
	<cfscript>
		// remove the whole tag and its content
		var list = "style,script,noscript";
		for (var tag in list){
			str = ReReplaceNoCase(str, "<s*(#tag#)[^>]*?>(.*?)","","all");
		}
		str = ReReplaceNoCase(str, "<.*?>","","all");
		//get partial html in front
		str = ReReplaceNoCase(str, "^.*?>","");
		//get partial html at end
		str = ReReplaceNoCase(str, "<.*$","");
	</cfscript>
	<cfreturn Trim(str)>
</cffunction>


<cffunction name="appendToWhereClause" returntype="string" output="false">
	<cfargument name="where" type="string" required="true">
	<cfargument name="append" type="string" required="true">
	<cfargument name="operator" type="string" default="AND">
	<cfif Len(arguments.append)>
		<cfif Len(arguments.where)>
			<cfset arguments.where = arguments.where & " #UCase(arguments.operator)# ">
		</cfif>
		<cfset arguments.where = arguments.where & "(" & arguments.append & ")">
	</cfif>
	<cfreturn arguments.where>
</cffunction>


<cffunction name="getFeature" returntype="string" output="false">
	<cfargument name="name" type="string" required="true">

	<cfset local.result = model("feature").findOne(arguments.name)>
	<cfif IsStruct(local.result)>
		<cfreturn local.result.value>
	</cfif>

	<cfreturn "">
</cffunction>


<cfscript>
public boolean function areTasksEnabled() {
	return
		isTaskRunnerInstance()
		&& getFeature("systemTasksEnabled") != "0"
}

public boolean function isTaskRunnerInstance() {
	return get("tasksUrl").len() > 0
}

public void function installSystemTaskRunner() {
	if (!isTaskRunnerInstance()) {
		return
	}

	schedule
		action = "update"
		task = "Run tasks"
		url = get("tasksUrl")
		startdate = Now()
		starttime = "00:00:05"
		interval = 10
		requesttimeout = 300
	;
}

public boolean function isAdminIP(required string ip_address) {
	return (
		(get("adminIPs").find(arguments.ip_address) > 0)
		||
		($getSubnets().some((subnet) => arguments.subnet.isInRange(ip_address)))
		||
		($getServerIpAddresses().find(arguments.ip_address) > 0)
	)
}

public array function $getSubnets() {
	return  ["192.168.0.0/16", "172.16.0.0/12"].map((ip_range) => {
		return createObject("java", "org.apache.commons.net.util.SubnetUtils").init(arguments.ip_range).getInfo()
	})
}

public array function $getServerIpAddresses() {
	local.interfaces = CreateObject("java", "java.net.NetworkInterface").getNetworkInterfaces()
	local.interfaces_array = CreateObject("java", "java.util.Collections").list(local.interfaces)

	local.server_addresses = local.interfaces_array.reduce((server_addresses=[], interface) => {
		local.inet_addresses = CreateObject("java", "java.util.Collections").list(arguments.interface.getInetAddresses())

		local.ipv4_addresses = local.inet_addresses
			.filter((address) => arguments.address.getClass().getName() == "java.net.Inet4Address")
			.map((address) => arguments.address.getHostAddress())

		return arguments.server_addresses.append(local.ipv4_addresses, true)
	})

	return local.server_addresses
}

public date function getFirstWorkingDayOfNextMonth(required string country_code) {
	local.first_of_next_month = now().add("m", 1)
	local.first_of_next_month.setDate(1)

	return getNextWorkingDay(local.first_of_next_month, arguments.country_code)
}

public void function loadSettingsFromEnvironment() {
	server.system.environment
		.filter(
			(env_var) => env_var.reFind("^DASHBOARD_SETTING_") == 1
		).each((env_var) => {
			local.setting_name = env_var.reReplace("^DASHBOARD_SETTING_", "")
			set("#local.setting_name#"=server.system.environment[env_var])
		})
	set(serverUpTime = server.system.environment.SERVER_UPTIME)
	set(containerUpTime = StructKeyExists(server.system.environment, "CONTAINER_UPTIME")
		? server.system.environment.CONTAINER_UPTIME
		: DateFormat(now(), "yyyy-mm-dd") & " 00:00:00"
	)
	set(containerId = StructKeyExists(server.system.environment, "CONTAINER_ID")
		? server.system.environment.CONTAINER_ID
		: "?"
	)
}

</cfscript>


<cffunction name="getSessionIdValue" returntype="string" output="false" hint="Safely returns the value of session.sessionId if available; otherwise an empty string">
	<cfif not application.getApplicationSettings().sessionManagement>
		<cfreturn "">
	</cfif>
	<cfif isNull(session?.sessionId)>
		<cfreturn "">
	</cfif>
	<cfreturn session.sessionId>
</cffunction>


<cffunction name="logRequest" returntype="void" output="false">
	<cfargument name="application" type="struct" default="true">
	<cfargument name="request" type="struct" required="true">
	<cfargument name="cgi" type="struct" required="true">

	<cfif (request.do_request_logging ?: true) EQ false>
		<cfreturn>
	</cfif>

	<cfif (arguments.request.wheels.params.controller ?: "wheels") EQ "wheels">
		<cfreturn>
	</cfif>

	<cfset $initialiseOptionalValues(argumentCollection=arguments)>
	<cfset $writeRequestMetrics(argumentCollection=arguments)>
	<cfset $logFusionReactorProperties(argumentCollection=arguments)>
</cffunction>


<cffunction name="$logFusionReactorProperties" returntype="void" output="false">
	<cfargument name="request" type="struct" required="true">

	<cfif NOT IsObject(request.frapi)>
		<cfreturn>
	</cfif>

	<cfset request.frapi.setTransactionName(LCase("#request.wheels.params.controller#/#request.wheels.params.action#"))>
	<cfif StructKeyExists(request, "creditor") and IsObject(request.creditor)>
		<cfset request.frapi.getActiveMasterTransaction().setProperty("creditor_id", request.creditor.id)>
		<cfset request.frapi.getActiveMasterTransaction().setProperty("creditor_name", request.creditor.creditor_name)>
	</cfif>
	<cfif StructKeyExists(request, "user") and IsObject(request.user)>
		<cfset request.frapi.getActiveMasterTransaction().setProperty("user_id", request.user.id)>
		<cfset request.frapi.getActiveMasterTransaction().setProperty("user_name", request.user.full_name)>
	</cfif>
</cffunction>


<cffunction name="$initialiseOptionalValues" returntype="void" output="false">
	<cfargument name="application" type="struct" required="true">
	<cfargument name="request" type="struct" required="true">

	<cfparam name="application.requests" default="#ArrayNew(1)#">
	<cfparam name="application.active_task" default="">
	<cfparam name="request.exception" default="false">
	<cfparam name="request.user_id" default="">
	<cfparam name="request.creditor_id" default="">

	<cfset request.db_time = $getTotalDatabaseUsageTimeForThisRequest()>
	<cfset request.session_id_value = getSessionIdValue()>
</cffunction>


<cffunction name="$getTotalDatabaseUsageTimeForThisRequest" returntype="numeric" output="false">
	<cfset local.db_time = 0>

	<cfadmin action="getDebugData" returnvariable="local.debug_data">
	<cfif StructKeyExists(variables, "local.debug_data")> <!--- this stops the site crashing if debugging has been turned off --->
		<cfloop query="local.debug_data.queries">
			<cfset local.db_time = local.db_time + local.debug_data.queries.time>
		</cfloop>
		<cfset local.db_time = Ceiling(local.db_time / 1000000)> <!--- convert ns to ms --->
	</cfif>

	<cfreturn local.db_time>
</cffunction>


<cffunction name="$writeRequestMetrics" returntype="void" output="false">
	<cfargument name="application" type="struct" required="true">
	<cfargument name="request" type="struct" required="true">
	<cfargument name="cgi" type="struct" required="true">

	<cfquery>
		INSERT INTO requests (
			created_at,
			local_addr,
			remote_addr,
			server_name,
			path_info,
			user_agent,
			query_string,
			request_method,
			request_time,
			db_time,
			api_time,
			content_length,
			environment,
			controller,
			action,
			status,
			error_message,
			error_detail,
			user_id,
			creditor_id,
			active_task,
			session_id
			)
		VALUES (
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.request.datetime#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cgi.local_addr#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.request.remote_addr#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cgi.server_name#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cgi.path_info#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cgi.user_agent#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cgi.query_string#" null="#!Len(arguments.cgi.query_string)#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cgi.request_method#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#(GetTickCount() - arguments.request.starttick)#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.request.db_time#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.request.api_time#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.request.content_length#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.application.wheels.environment#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.request.wheels.params.controller#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#(StructKeyExists(arguments.request.wheels.params, "endpoint") ? arguments.request.wheels.params.endpoint : arguments.request.wheels.params.action)#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#(IsStruct(arguments.request.exception) ? "Error" : "OK")#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#(IsStruct(arguments.request.exception) ? Left(arguments.request.exception.message, 500) : "")#" null="#!IsStruct(arguments.request.exception)#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#(IsStruct(arguments.request.exception) ? arguments.request.exception.detail : "")#" null="#!IsStruct(arguments.request.exception)#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.request.user_id#" null="#!IsNumeric(arguments.request.user_id)#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.request.creditor_id#" null="#!Len(arguments.request.creditor_id)#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.application.active_task#" null="#!Len(arguments.application.active_task)#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.request.session_id_value#" null="#!Len(arguments.request.session_id_value)#">
			)
	</cfquery>
</cffunction>

<cffunction name="$getReloadModeFromUrl" access="private" returntype="string">
	<cfif request.cgi.path_info NEQ "/system/reload-mode">
		<cfreturn "">
	</cfif>
	<cfif NOT URL.keyExists("mode")>
		<cfreturn "">
	</cfif>
	<cfif NOT ["design","development","maintenance","production","testing"].find(URL.mode)>
		<cfreturn "">
	</cfif>
	<cfreturn URL.mode>
</cffunction>
