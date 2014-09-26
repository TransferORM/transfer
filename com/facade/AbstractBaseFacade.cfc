<!--- Document Information -----------------------------------------------------

Title:      AbstractBaseFacade.cfc

Author:     Mark Mandel
Email:      mark@compoundtheory.com

Website:    http://www.compoundtheory.com

Purpose:    The abstract base for all facades

Usage:

Modification Log:

Name			Date			Description
================================================================================
Mark Mandel		16/05/2006		Created

------------------------------------------------------------------------------->
<cfcomponent name="AbstractBaseFacade" hint="The abstract base to all the scope facades">

<cfscript>
	instance = StructNew();
</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->
<cffunction name="init" hint="Constructor" access="public" returntype="AbstractBaseFacade" output="false">
	<cfargument name="javaLoader" hint="The JavaLoader for loading the caching objects" type="transfer.com.util.JavaLoader" required="Yes" _autocreate="false">
	<cfargument name="eventManager" type="transfer.com.events.EventManager" required="true" _autocreate="false">
	<cfargument name="cacheMonitor" hint="The cache monitor" type="transfer.com.cache.CacheMonitor" required="Yes"
				_factory="transfer.com.cache.CacheManager" _factorymethod="getCacheMonitor" _autocreate="false">
	<cfargument name="cacheManager" hint="The cache manager" type="transfer.com.cache.CacheManager" required="Yes" _autocreate="false">
	<cfscript>
		var functionMap = StructNew();

		setJavaLoader(arguments.javaLoader);
		setEventManager(arguments.eventManager);
		setCacheMonitor(arguments.cacheMonitor);
		setCacheManager(arguments.cacheManager);

		//build the function map, for lookup later
		functionMap.aftercreate = getAfterCreateObserverCollection;
		functionMap.afterdelete = getAfterDeleteObserverCollection;
		functionMap.afterupdate = getAfterUpdateObserverCollection;
		functionMap.beforecreate = getBeforeCreateObserverCollection;
		functionMap.beforedelete = getBeforeDeleteObserverCollection;
		functionMap.beforeupdate = getBeforeUpdateObserverCollection;
		functionMap.afterdiscard = getAfterDiscardObserverCollection;
		functionMap.afternew = getAfterNewObserverCollection;

		setObserverFunctionMap(functionMap);

		configure();

		return this;
	</cfscript>
</cffunction>

<cffunction name="configure" hint="Constructor" access="public" returntype="void" output="false">
</cffunction>

<!--- AfterCreateObserverCollection --->

<cffunction name="getAfterCreateObserverCollection" access="public" returntype="transfer.com.events.collections.AbstractBaseObserverCollection" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfif NOT hasAfterCreateObserverCollection(argumentCollection=arguments)>
		<cflock name="transfer.facade.getAfterCreateObserverCollection.#getScopeIdentityHashCode()#" timeout="60" throwontimeout="true">
			<cfif NOT hasAfterCreateObserverCollection(argumentCollection=arguments)>
				<cfset setAfterCreateObserverCollection(createObservable("AfterCreateObserverCollection"), arguments.class)>
				<!--- adding here because under load, we occasionally get errors between the time we release the lock and the time we run getScopePlace() at the end of the method --->
				<cfreturn getScopePlace(argumentCollection=arguments).AfterCreateObserverCollection />
			</cfif>
		</cflock>
	</cfif>
	<cfreturn getScopePlace(argumentCollection=arguments).AfterCreateObserverCollection />
</cffunction>

<cffunction name="hasAfterCreateObserverCollection" hint="Whether it exists in the scope or not" access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfreturn scopePlaceKeyExists("AfterCreateObserverCollection", arguments.class)>
</cffunction>

<!--- AfterDeleteObserverCollection --->

<cffunction name="getAfterDeleteObserverCollection" access="public" returntype="transfer.com.events.collections.AbstractBaseObserverCollection" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfif NOT hasAfterDeleteObserverCollection(argumentCollection=arguments)>
		<cflock name="transfer.facade.getAfterDeleteObserverCollection.#getScopeIdentityHashCode()#" timeout="60" throwontimeout="true">
			<cfif NOT hasAfterDeleteObserverCollection(argumentCollection=arguments)>
				<cfset setAfterDeleteObserverCollection(createObservable("AfterDeleteObserverCollection"), arguments.class)>
				<!--- adding here because under load, we occasionally get errors between the time we release the lock and the time we run getScopePlace() at the end of the method --->
				<cfreturn getScopePlace(argumentCollection=arguments).AfterDeleteObserverCollection />
			</cfif>
		</cflock>
	</cfif>
	<cfreturn getScopePlace(argumentCollection=arguments).AfterDeleteObserverCollection />
</cffunction>

<cffunction name="hasAfterDeleteObserverCollection" hint="Whether it exists in the scope or not" access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfreturn scopePlaceKeyExists("AfterDeleteObserverCollection", arguments.class)>
</cffunction>

 <!---AfterUpdateObserverCollection --->

<cffunction name="getAfterUpdateObserverCollection" access="public" returntype="transfer.com.events.collections.AbstractBaseObserverCollection" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfif NOT hasAfterUpdateObserverCollection(argumentCollection=arguments)>
		<cflock name="transfer.facade.getAfterUpdateObserverCollection.#getScopeIdentityHashCode()#" timeout="60" throwontimeout="true">
			<cfif NOT hasAfterUpdateObserverCollection(argumentCollection=arguments)>
				<cfset setAfterUpdateObserverCollection(createObservable("AfterUpdateObserverCollection"), arguments.class)>
				<!--- adding here because under load, we occasionally get errors between the time we release the lock and the time we run getScopePlace() at the end of the method --->
				<cfreturn getScopePlace(argumentCollection=arguments).AfterUpdateObserverCollection />
			</cfif>
		</cflock>
	</cfif>
	<cfreturn getScopePlace(argumentCollection=arguments).AfterUpdateObserverCollection />
</cffunction>

<cffunction name="hasAfterUpdateObserverCollection" hint="Whether it exists in the scope or not" access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfreturn scopePlaceKeyExists("AfterUpdateObserverCollection", arguments.class)>
</cffunction>

 <!--- BeforeCreateObserverCollection --->

<cffunction name="getBeforeCreateObserverCollection" access="public" returntype="transfer.com.events.collections.AbstractBaseObserverCollection" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfif NOT hasBeforeCreateObserverCollection(argumentCollection=arguments)>
		<cflock name="transfer.facade.getBeforeCreateObserverCollection.#getScopeIdentityHashCode()#" timeout="60" throwontimeout="true">
			<cfif NOT hasBeforeCreateObserverCollection(argumentCollection=arguments)>
				<cfset setBeforeCreateObserverCollection(createObservable("BeforeCreateObserverCollection"), arguments.class)>
				<!--- adding here because under load, we occasionally get errors between the time we release the lock and the time we run getScopePlace() at the end of the method --->
				<cfreturn getScopePlace(argumentCollection=arguments).BeforeCreateObserverCollection />
			</cfif>
		</cflock>
	</cfif>
	<cfreturn getScopePlace(argumentCollection=arguments).BeforeCreateObserverCollection />
</cffunction>

<cffunction name="hasBeforeCreateObserverCollection" hint="Whether it exists in the scope or not" access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfreturn scopePlaceKeyExists("BeforeCreateObserverCollection", arguments.class)>
</cffunction>

<!--- BeforeUpdateObserverCollection --->

<cffunction name="getBeforeUpdateObserverCollection" access="public" returntype="transfer.com.events.collections.AbstractBaseObserverCollection" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfif NOT hasBeforeUpdateObserverCollection(argumentCollection=arguments)>
		<cflock name="transfer.facade.getBeforeUpdateObserverCollection.#getScopeIdentityHashCode()#" timeout="60" throwontimeout="true">
			<cfif NOT hasBeforeUpdateObserverCollection(argumentCollection=arguments)>
				<cfset setBeforeUpdateObserverCollection(createObservable("BeforeUpdateObserverCollection"), arguments.class)>
				<!--- adding here because under load, we occasionally get errors between the time we release the lock and the time we run getScopePlace() at the end of the method --->
				<cfreturn getScopePlace(argumentCollection=arguments).BeforeUpdateObserverCollection />
			</cfif>
		</cflock>
	</cfif>
	<cfreturn getScopePlace(argumentCollection=arguments).BeforeUpdateObserverCollection />
</cffunction>

<cffunction name="hasBeforeUpdateObserverCollection" hint="Whether it exists in the scope or not" access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfreturn scopePlaceKeyExists("BeforeUpdateObserverCollection", arguments.class)>
</cffunction>

<!--- BeforeDeleteObserverCollection --->

<cffunction name="getBeforeDeleteObserverCollection" access="public" returntype="transfer.com.events.collections.AbstractBaseObserverCollection" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfif NOT hasBeforeDeleteObserverCollection(argumentCollection=arguments)>
		<cflock name="transfer.facade.getBeforeDeleteObserverCollection.#getScopeIdentityHashCode()#" timeout="60" throwontimeout="true">
			<cfif NOT hasBeforeDeleteObserverCollection(argumentCollection=arguments)>
				<cfset setBeforeDeleteObserverCollection(createObservable("BeforeDeleteObserverCollection"), arguments.class)>
				<!--- adding here because under load, we occasionally get errors between the time we release the lock and the time we run getScopePlace() at the end of the method --->
				<cfreturn getScopePlace(argumentCollection=arguments).BeforeDeleteObserverCollection />
			</cfif>
		</cflock>
	</cfif>
	<cfreturn getScopePlace(argumentCollection=arguments).BeforeDeleteObserverCollection />
</cffunction>

<cffunction name="hasBeforeDeleteObserverCollection" hint="Whether it exists in the scope or not" access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfreturn scopePlaceKeyExists("BeforeDeleteObserverCollection", arguments.class)>
</cffunction>

<!--- AfterDiscardObserverCollection --->

<cffunction name="getAfterDiscardObserverCollection" access="public" returntype="transfer.com.events.collections.AbstractBaseObserverCollection" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfif NOT hasAfterDiscardObserverCollection(argumentCollection=arguments)>
		<cflock name="transfer.facade.getAfterDiscardObserverCollection.#getScopeIdentityHashCode()#" timeout="60" throwontimeout="true">
			<cfif NOT hasAfterDiscardObserverCollection(argumentCollection=arguments)>
				<cfset setAfterDiscardObserverCollection(createObservable("AfterDiscardObserverCollection"), arguments.class)>
				<!--- adding here because under load, we occasionally get errors between the time we release the lock and the time we run getScopePlace() at the end of the method --->
				<cfreturn getScopePlace(argumentCollection=arguments).AfterDiscardObserverCollection />
			</cfif>
		</cflock>
	</cfif>
	<cfreturn getScopePlace(argumentCollection=arguments).AfterDiscardObserverCollection />
</cffunction>

<cffunction name="hasAfterDiscardObserverCollection" hint="Whether it exists in the scope or not" access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfreturn scopePlaceKeyExists("AfterDiscardObserverCollection", arguments.class)>
</cffunction>

<!--- AfterNewObserverCollection --->

<cffunction name="getAfterNewObserverCollection" access="public" returntype="transfer.com.events.collections.AbstractBaseObserverCollection" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfif NOT hasAfterNewObserverCollection(argumentCollection=arguments)>
		<cflock name="transfer.facade.getAfterNewObserverCollection.#getScopeIdentityHashCode()#" timeout="60" throwontimeout="true">
			<cfif NOT hasAfterNewObserverCollection(argumentCollection=arguments)>
				<cfset setAfterNewObserverCollection(createObservable("AfterNewObserverCollection"), arguments.class)>
				<!--- adding here because under load, we occasionally get errors between the time we release the lock and the time we run getScopePlace() at the end of the method --->
				<cfreturn getScopePlace(argumentCollection=arguments).AfterNewObserverCollection />
			</cfif>
		</cflock>
	</cfif>
	<cfreturn getScopePlace(argumentCollection=arguments).AfterNewObserverCollection />
</cffunction>

<cffunction name="hasAfterNewObserverCollection" hint="Whether it exists in the scope or not" access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfreturn scopePlaceKeyExists("AfterNewObserverCollection", arguments.class)>
</cffunction>

<!--- get observer by type --->

<cffunction name="getObserverCollectionByType" hint="returns a particular observer collection" access="public" returntype="transfer.com.events.collections.AbstractBaseObserverCollection" output="false">
	<cfargument name="type" hint="key for what type to get" type="string" required="Yes">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfscript>
		//give me the appropriate method to map to the type, and call it.
		var call = StructFind(getObserverFunctionMap(), arguments.type);

		return call(arguments.class);
	</cfscript>
</cffunction>

<cffunction name="clear" hint="Clears the observers for a given class" access="public" returntype="void" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfscript>
		var scope = getScope();
		var key = getCacheManager().getScopeKey(arguments.class);

		structDelete(scope, key);
	</cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="scopePlaceKeyExists" hint="Returns true if the scope place key exists" access="private" returntype="boolean" output="false">
	<cfargument name="key" hint="the key to look for" type="string" required="Yes">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfscript>
		if(NOT hasScopePlace(argumentCollection=arguments))
		{
			return false;
		}


		return StructKeyExists(getScopePlace(argumentCollection=arguments), key);
	</cfscript>
</cffunction>

<cffunction name="hasScopePlace" hint="checks to see if the scope has been accessed at all" access="private" returntype="boolean" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfscript>
		var key = getCacheManager().getScopeKey(arguments.class);

		return structKeyExists(getScope(), key);
	</cfscript>
</cffunction>

<cffunction name="getScopePlace" hint="Returns the place in which the Transfer parts are stored" access="private" returntype="struct" output="false">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfscript>
		var scope = getScope();
		var key = getCacheManager().getScopeKey(arguments.class);
	</cfscript>

	<cfif NOT hasScopePlace(argumentCollection=arguments)>
		<cflock name="transfer.ScopeFacade.#getIdentityHashCode(scope)#" timeout="60">
			<cfscript>
				if(NOT hasScopePlace(argumentCollection=arguments))
				{
					scope[key] = StructNew();
				}
			</cfscript>
		</cflock>
	</cfif>

	<cfreturn scope[key]>
</cffunction>

<cffunction name="createObservable" hint="Returns a Observable collection object" access="private" returntype="transfer.com.events.collections.AbstractBaseObserverCollection" output="false">
	<cfargument name="type" hint="key for what type to get" type="string" required="Yes">
	<cfscript>
		return createObject("component", "transfer.com.events.collections." & arguments.type).init();
	</cfscript>
</cffunction>

<cffunction name="getScope" hint="Overwrite to return the scope this facade refers to" access="private" returntype="struct" output="false">
	<cfset createObject("component", "transfer.com.exception.VirtualMethodException").init("getScope", this) />
</cffunction>

<cffunction name="getScopeIdentityHashCode" hint="gets the identity hash code of the scope" access="private" returntype="string" output="false">
	<cfreturn getIdentityHashCode(getScope()) />
</cffunction>

<cffunction name="getIdentityHashCode" hint="Gets the object hash code" access="private" returntype="string" output="false">
	<cfargument name="object" hint="The Object the query is associated with" type="any" required="Yes">
	<cfscript>
		var system = createObject("java", "java.lang.System");
		return system.identityHashCode(arguments.object);
	</cfscript>
</cffunction>

<cffunction name="setBeforeCreateObserverCollection" access="private" returntype="void" output="false">
	<cfargument name="BeforeCreateObserverCollection" type="transfer.com.events.collections.AbstractBaseObserverCollection" required="true">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfset getScopePlace(arguments.class).BeforeCreateObserverCollection = arguments.BeforeCreateObserverCollection />
</cffunction>

<cffunction name="setBeforeUpdateObserverCollection" access="private" returntype="void" output="false">
	<cfargument name="BeforeUpdateObserverCollection" type="transfer.com.events.collections.AbstractBaseObserverCollection" required="true">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfset getScopePlace(arguments.class).BeforeUpdateObserverCollection = arguments.BeforeUpdateObserverCollection />
</cffunction>

<cffunction name="setBeforeDeleteObserverCollection" access="private" returntype="void" output="false">
	<cfargument name="BeforeDeleteObserverCollection" type="transfer.com.events.collections.AbstractBaseObserverCollection" required="true">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfset getScopePlace(arguments.class).BeforeDeleteObserverCollection = arguments.BeforeDeleteObserverCollection />
</cffunction>

<cffunction name="setAfterCreateObserverCollection" access="private" returntype="void" output="false">
	<cfargument name="AfterCreateObserverCollection" type="transfer.com.events.collections.AbstractBaseObserverCollection" required="true">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfset getScopePlace(arguments.class).AfterCreateObserverCollection = arguments.AfterCreateObserverCollection />
</cffunction>

<cffunction name="setAfterUpdateObserverCollection" access="private" returntype="void" output="false">
	<cfargument name="AfterUpdateObserverCollection" type="transfer.com.events.collections.AbstractBaseObserverCollection" required="true">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfset getScopePlace(arguments.class).AfterUpdateObserverCollection = arguments.AfterUpdateObserverCollection />
</cffunction>

<cffunction name="setAfterDeleteObserverCollection" access="private" returntype="void" output="false">
	<cfargument name="AfterDeleteObserverCollection" type="transfer.com.events.collections.AbstractBaseObserverCollection" required="true">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfset getScopePlace(arguments.class).AfterDeleteObserverCollection = arguments.AfterDeleteObserverCollection />
</cffunction>

<cffunction name="setAfterNewObserverCollection" access="private" returntype="void" output="false">
	<cfargument name="AfterNewObserverCollection" type="transfer.com.events.collections.AbstractBaseObserverCollection" required="true">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfset getScopePlace(arguments.class).AfterNewObserverCollection = arguments.AfterNewObserverCollection />
</cffunction>

<cffunction name="setAfterDiscardObserverCollection" access="private" returntype="void" output="false">
	<cfargument name="AfterDiscardObserverCollection" type="transfer.com.events.collections.AbstractBaseObserverCollection" required="true">
	<cfargument name="class" hint="the class in question" type="string" required="Yes">
	<cfset getScopePlace(arguments.class).AfterDiscardObserverCollection = arguments.AfterDiscardObserverCollection />
</cffunction>

<cffunction name="getJavaLoader" access="private" returntype="transfer.com.util.JavaLoader" output="false">
	<cfreturn instance.JavaLoader />
</cffunction>

<cffunction name="setJavaLoader" access="private" returntype="void" output="false">
	<cfargument name="JavaLoader" type="transfer.com.util.JavaLoader" required="true">
	<cfset instance.JavaLoader = arguments.JavaLoader />
</cffunction>

<cffunction name="setFacadeMap" access="private" returntype="void" output="false">
	<cfargument name="facadeMap" type="struct" required="true">
	<cfset instance.facadeMap = arguments.facadeMap />
</cffunction>

<cffunction name="getObserverFunctionMap" access="private" returntype="struct" output="false">
	<cfreturn instance.observerFunctionMap />
</cffunction>

<cffunction name="setObserverFunctionMap" access="private" returntype="void" output="false">
	<cfargument name="observerFunctionMap" type="struct" required="true">
	<cfset instance.observerFunctionMap = arguments.observerFunctionMap />
</cffunction>

<cffunction name="getEventManager" access="private" returntype="transfer.com.events.EventManager" output="false">
	<cfreturn instance.EventManager />
</cffunction>

<cffunction name="setEventManager" access="private" returntype="void" output="false">
	<cfargument name="EventManager" type="transfer.com.events.EventManager" required="true">
	<cfset instance.EventManager = arguments.EventManager />
</cffunction>

<cffunction name="getCacheMonitor" access="private" returntype="transfer.com.cache.CacheMonitor" output="false">
	<cfreturn instance.cacheMonitor />
</cffunction>

<cffunction name="setCacheMonitor" access="private" returntype="void" output="false">
	<cfargument name="cacheMonitor" type="transfer.com.cache.CacheMonitor" required="true">
	<cfset instance.cacheMonitor = arguments.cacheMonitor />
</cffunction>

<cffunction name="getCacheManager" access="private" returntype="transfer.com.cache.CacheManager" output="false">
	<cfreturn instance.cacheManager />
</cffunction>

<cffunction name="setCacheManager" access="private" returntype="void" output="false">
	<cfargument name="cacheManager" type="transfer.com.cache.CacheManager" required="true">
	<cfset instance.cacheManager = arguments.cacheManager />
</cffunction>

</cfcomponent>