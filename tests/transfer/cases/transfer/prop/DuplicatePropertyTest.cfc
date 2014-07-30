<cfcomponent name="duplicatePropertyTest" extends="test.transfer.cases.BaseCase">

<cffunction name="testCreateChildren" hint="" access="public" returntype="void" output="false">
	<cfscript>
		var simple = getTransfer().new("prop.PropParent");
		var count = 0;
		
		var qAmount = 0;
		var child = 0;
		var counter = 1;
		
		simple.setThing(RandRange(1, 99999999));

		getTransfer().save(simple);
	
		</cfscript>
		
		<!--- see if the amount is more --->
		<cfquery name="qAmount" datasource="#getDataSource().getName()#" username="#getDataSource().getUsername()#" password="#getDataSource().getUsername()#">
			select count(*) as amount
			from
			tbl_propchild
		</cfquery>

		<cfscript>
		count = qAmount.amount;
		
		//add five children
		for(; counter lte 5; counter = counter + 1)
		{
			child = getTransfer().new("prop.PropChild");
			child.setThing(RandRange(1, 999999999));
			
			child.setParentPropParent(simple);
			
			getTransfer().save(child);
		}
	</cfscript>

	<cfquery name="qAmount" datasource="#getDataSource().getName()#" username="#getDataSource().getUsername()#" password="#getDataSource().getUsername()#">
		select count(*) as amount
		from
		tbl_propchild
	</cfquery>	
	<cfscript>
		assertEqualsBasic(count + 5, qAmount.amount);
	</cfscript>
</cffunction>

<cffunction name="testGetPropParent" hint="" access="public" returntype="void" output="false">
	<cfscript>
		var qID = 0;
		var obj = 0;
	</cfscript>

	<cfquery name="qID" datasource="#getDataSource().getName()#" username="#getDataSource().getUsername()#" password="#getDataSource().getUsername()#">
		select max(idpropparent) as id
		from
		tbl_propparent
	</cfquery>
	
	<cfscript>
		obj = getTransfer().get("prop.PropParent", qID.id[1]);
		assertEqualsBasic(obj.getIDPropParent(), qID.id[1]);
	</cfscript>
</cffunction>

</cfcomponent>