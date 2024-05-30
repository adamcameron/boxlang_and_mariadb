<cfscript>
	param URL.testBundles="";
	if (URL.testBundles.len()) {
		param URL.directories = ""
	}else{
		param URL.directories="test.integration,test.unit"
	}

	testBox = new testbox.system.TestBox(
		bundles = URL.testBundles,
		directories = URL.directories
	)

	result = testBox.run(reporter="test.system.reports.SimpleReporter")
	writeOutput(result.trim())
</cfscript>
