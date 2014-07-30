<cfscript>
	tests = arrayNew(1);
	ArrayAppend(tests, "test.transfer.AllTests1");
	ArrayAppend(tests, "test.transfer.AllTests2");
	ArrayAppend(tests, "test.transfer.AllTests3");
	ArrayAppend(tests, "test.transfer.AllTests4");
	ArrayAppend(tests, "test.transfer.TransferSuite");
	ArrayAppend(tests, "test.transfer.GatewaySuite");
	ArrayAppend(tests, "test.transfer.CachingSuite");
	ArrayAppend(tests, "test.transfer.LazySuite");
	ArrayAppend(tests, "test.transfer.RefreshSuite");
	ArrayAppend(tests, "test.transfer.DecoratorSuite");
	ArrayAppend(tests, "test.transfer.TQLSuite");
	ArrayAppend(tests, "test.transfer.EventSuite");
	ArrayAppend(tests, "test.transfer.CompositeKeySuite");
	ArrayAppend(tests, "test.transfer.SQLSuite");
	ArrayAppend(tests, "test.transfer.TransactionSuite");
	ArrayAppend(tests, "test.transfer.ProxySuite");
	ArrayAppend(tests, "test.transfer.ObjectSuite");
</cfscript>

<cffunction name="_trace">
	<cfargument name="s">
	<cfset var g = "">
	<cfsetting showdebugoutput="true">
	<cfsavecontent variable="g">
		<cfdump var="#arguments.s#">
	</cfsavecontent>
	<cftrace text="#g#">
</cffunction>

<html>
	<head>
		<cfoutput>
		<title>cfunit <cfif structKeyExists(url, "testSuite")>- #url.testSuite#</cfif> - #Now()#</title>
		</cfoutput>
		<style type="text/css">
			body {
				font-family: Verdana;
				font-size: small;
			}
		</style>
	</head>
	<body>
		<ul>
		<cfoutput>
		<cfloop from="1" to="#arrayLen(tests)#" index="counter">
			<li>
				<a href="index.cfm?testSuite=#URLEncodedFormat(tests[counter])#">#tests[counter]#</a>
			</li>
		</cfloop>
		</cfoutput>
		</ul>

		<p>
			Test Cache Report:
			<a href="cachereport.cfm">cachereport.cfm</a>
		</p>

		<cfif structKeyExists(url, "testSuite")>
		<cfoutput>
		<strong>#url.testSuite#</strong>
		</cfoutput>
		<!--- cleanup the old .transfer files --->
		<cfset path = expandPath("/test/resources/defs")>

		<cfif true>
		<cfdirectory action="list" directory="#path#" name="qDefs" filter="*.transfer.cfm">

		<cfloop query="qDefs">
			<cffile action="delete" file="#path#/#name#">
		</cfloop>
		</cfif>

		<!--- pull in the db details from the xml --->
		<cffile action="read" variable="ds" file="#expandPath('/test/resources/datasource.xml')#">
		<cfset xDatasource = xmlSearch(xmlParse(ds), "/datasource/") />

		<cfscript>
			System = createObject("Java", "java.lang.System");

			request._trace = _trace;

			//cleanup at start
			StructClear(application);
			StructClear(session);
			//StructClear(Server);

			//see if we can cleanup a little
			System.gc();

			//create the transferFactor in the application scope
			application.transferFactory = createObject("component", "transfer.TransferFactory").init("/test/resources/datasource.xml",
																								  "/test/resources/transfera.xml",
																								  "/test/resources/defs");

			configuration = createObject("component", "transfer.com.config.Configuration").init("/test/resources/datasource.xml",
																								"/test/resources/transferb.xml",
																								"/test/resources/defs");

			configuration.addConfigImport("/test/resources/_transferb.xml");


			application.transferFactoryB = createObject("component", "transfer.TransferFactory").init(configuration=configuration);


			configuration = createObject("component", "transfer.com.config.Configuration").init();

			configuration.setDatasourceName(xDatasource[1].name.xmlText);
			configuration.setDefinitionPath("/test/resources/defs");
			configuration.setConfigPath("/test/resources/transferc.xml");

			application.transferFactoryC = createObject("component", "transfer.TransferFactory").init(configuration=configuration);

			application.transferFactoryD = createObject("component", "transfer.TransferFactory").init("/test/resources/datasource.xml",
																								  "/test/resources/transferd.xml",
																								  "/test/resources/defs");

			application.transferFactoryE = createObject("component", "transfer.TransferFactory").init("/test/resources/datasource.xml",
																								  "/test/resources/transfere.xml",
																								  "/test/resources/defs");


			testRunner = createObject("component", "net.sourceforge.cfunit.framework.TestRunner");

			testSuite = createObject("component", url.testSuite).suite();

			testrunner.run(testSuite, "All Tests");


			//shutdown
			application.transferFactory.shutdown();
			application.transferFactoryB.shutdown();
			application.transferFactoryC.shutdown();
			application.transferFactoryD.shutdown();
			application.transferFactoryE.shutdown();

			//see if we can cleanup a little
			System.gc();
		</cfscript>

		</cfif>
	</body>
</html>