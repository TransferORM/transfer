<!--- Document Information -----------------------------------------------------

Title:      EHCacheProvider.cfc

Author:     Mark Mandel
Email:      mark@compoundtheory.com

Website:    http://www.compoundtheory.com

Purpose:    EHCache Provider

Usage:

Modification Log:

Name			Date			Description
================================================================================
Mark Mandel		02/11/2009		Created

------------------------------------------------------------------------------->

<cfcomponent hint="EHCache Provider" extends="AbstractBaseAsyncDiscardProvider" output="false">

<cfscript>
	instance.static.SERVER_KEY = "ehCache.Provider.7D934950-C778-11DE-8A39-0800200C9A66";
</cfscript>

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="EHCacheProvider" output="false">
	<cfargument name="config" hint="the path to the config file" type="string" required="Yes">
	<cfscript>
		var jars = 0;
		var configuration = 0;
		var ConfigurationFactory = 0;
		var configHelper = 0;
		var interfaces = ["net.sf.ehcache.event.CacheEventListener"];
		var _Thread = createObject("java", "java.lang.Thread"); //using 'Thread' breaks CFB
		var currentClassloader = _Thread.currentThread().getContextClassLoader();

		setArrays(createObject("java", "java.util.Arrays"));

		super.init();

		setSystem(createObject("java", "java.lang.System"));
	</cfscript>

	<cfif NOT hasJavaLoader()>
		<cflock name="transfer.com.cache.provider.EHCacheProvider" throwontimeout="true" timeout="60">
			<cfscript>
				if(NOT hasJavaLoader())
				{
					jars = queryJars();

					//also add in jars for dynamic proxies
					ArrayAppend(jars, expandPath("/transfer/com/util/javaloader/support/cfcdynamicproxy/lib/cfcdynamicproxy.jar"));

					setJavaLoader(createObject("component", "transfer.com.util.javaloader.JavaLoader").init(loadPaths=jars, loadColdFusionClassPath=true));
				}
			</cfscript>
		</cflock>
	</cfif>

	<cftry>
		<cfscript>
			//move around the the context class loader so log4j doesn't do a wobbly.
			_Thread.currentThread().setContextClassLoader(getJavaLoader().getURLClassLoader());

			//Ignore the Thread Context ClassLoader when loading classes.
			getSystem().setProperty("log4j.ignoreTCL", true);

			//init log4j
			PropertyConfigurator = getJavaLoader().create("org.apache.log4j.PropertyConfigurator");
			PropertyConfigurator.configure(getDirectoryFromPath(getMetadata(this).path) & "/ehcache-lib/log4j.properties");

			ConfigurationFactory = getJavaLoader().create("net.sf.ehcache.config.ConfigurationFactory");

			configuration = ConfigurationFactory.parseConfiguration(getJavaLoader().create("java.io.File").init(expandPath(arguments.config)));

			setEHCacheManager(getJavaLoader().create("net.sf.ehcache.CacheManager").init(configuration));

			configHelper = getJavaLoader().create("net.sf.ehcache.config.ConfigurationHelper").init(getEHCacheManager(), configuration);

			_Thread.currentThread().setContextClassLoader(currentClassloader);

			setDefaultCache(configHelper.createDefaultCache());
			
			if (server.coldfusion.productname contains "Railo") {
				var proxy = createDynamicProxy(this, interfaces);
			} else {
				var proxy = getJavaLoader().create("com.compoundtheory.coldfusion.cfc.CFCDynamicProxy").createInstance(this, interfaces);
			}
			
			setProxy(proxy);

			return this;
		</cfscript>
		<cfcatch>
			<cfscript>
				//make sure no matter what happens, the TCL goes back the way it was.
				_Thread.currentThread().setContextClassLoader(currentClassloader);
            </cfscript>
			<cfrethrow>
		</cfcatch>
	</cftry>
</cffunction>

<cffunction name="add" hint="Adds an object to the cache. If there is no cache for this class, one is created based on the default cache configuration"
			access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="the class of the object" type="string" required="Yes">
	<cfargument name="key" hint="the primary key of the object" type="string" required="Yes">
	<cfargument name="object" hint="the object to add to the cache" type="any" required="Yes">
	<cfscript>
		var cache = 0;
		var element = getJavaLoader().create("net.sf.ehcache.Element").init(arguments.key, arguments.object);
    </cfscript>
	<cfif NOT getEHCacheManager().cacheExists(arguments.class)>
    	<cflock name="transfer.com.cache.provider.EHCacheProvider.#arguments.class#.#getSystem().identityHashCode(this)#" throwontimeout="true" timeout="60">
    	<cfscript>
    		if(NOT getEHCacheManager().cacheExists(arguments.class))
    		{
				cache = getDefaultCache().clone();

				cache.setName(arguments.class);

				cache.getCacheEventNotificationService().registerListener(getProxy());

				getEHCacheManager().addCache(cache);
			}
    	</cfscript>
    	</cflock>
    </cfif>
	<cfscript>
		cache = getEHCacheManager().getCache(arguments.class);

		cache.put(element);

		return true;
    </cfscript>
</cffunction>

<cffunction name="have" hint="Is the given class and key in the cache?" access="public" returntype="boolean" output="false">
	<cfargument name="class" hint="the class of the object" type="string" required="Yes">
	<cfargument name="key" hint="the primary key of the object" type="string" required="Yes">
	<cfscript>
		var cache = 0;
		var local = {};

		if(NOT getEHCacheManager().cacheExists(arguments.class))
		{
			return false;
		}

		cache = getEHCacheManager().getCache(arguments.class);

		local.element = cache.get(arguments.key);

		if(structKeyExists(local, "element"))
		{
			return (NOT cache.isExpired(local.element));
		}

		return false;
    </cfscript>
</cffunction>

<cffunction name="get" hint="virtual method: get the given class and key from the cache, if not there, return nothing" access="public" returntype="any" output="false">
	<cfargument name="class" hint="the class of the object" type="string" required="Yes">
	<cfargument name="key" hint="the primary key of the object" type="string" required="Yes">
	<cfscript>
		var cache = 0;
		var local = {};

		if(NOT getEHCacheManager().cacheExists(arguments.class))
		{
			return;
		}

		cache = getEHCacheManager().getCache(arguments.class);

		local.element = cache.get(arguments.key);

		if(structKeyExists(local, "element"))
		{
			return local.element.getObjectValue();
		}

		return;
    </cfscript>
</cffunction>

<cffunction name="discard" hint="Remove the given class and key from the cache, if it exists." access="public" returntype="void" output="false">
	<cfargument name="class" hint="the class of the object" type="string" required="Yes">
	<cfargument name="key" hint="the primary key of the object" type="string" required="Yes">
	<cfscript>
		var cache = 0;

		println("discard: #arguments.class# : #arguments.key#");

		if(NOT getEHCacheManager().cacheExists(arguments.class))
		{
			return;
		}

		cache = getEHCacheManager().getCache(arguments.class);

		cache.remove(arguments.key);
    </cfscript>
</cffunction>

<cffunction name="discardAll" hint="Remove all items from the cache" access="public" returntype="void" output="false">
	<cfset getEHCacheManager().clearAll()>
</cffunction>

<cffunction name="getCachedClasses" hint="return a list of all the cached classes" access="public" returntype="array" output="false">
	<cfreturn getArrays().asList(getEHCacheManager().getCacheNames()) />
</cffunction>

<cffunction name="getSize" hint="The number of items in the cache, for  given class" access="public" returntype="numeric" output="false">
	<cfargument name="className" hint="the name of the class" type="string" required="Yes">
	<cfscript>
		if(getEHCacheManager().cacheExists(arguments.className))
		{
			return getEHCacheManager().getCache(arguments.className).getLiveCacheStatistics().getSize();
		}

		return 0;
    </cfscript>
</cffunction>

<cffunction name="getHits" hint="returns the number of hits for that class" access="public" returntype="numeric" output="false">
	<cfargument name="className" hint="the class to retrive hits for" type="string" required="Yes">
	<cfscript>
		if(getEHCacheManager().cacheExists(arguments.className))
		{
			return getEHCacheManager().getCache(arguments.className).getStatistics().getCacheHits();
		}

		return 0;
    </cfscript>
</cffunction>

<cffunction name="getMisses" hint="returns the number of misses for that class" access="public" returntype="numeric" output="false">
	<cfargument name="className" hint="the class to retrive hits for" type="string" required="Yes">
	<cfscript>
		if(getEHCacheManager().cacheExists(arguments.className))
		{
			return getEHCacheManager().getCache(arguments.className).getStatistics().getCacheMisses();
		}

		return 0;
    </cfscript>
</cffunction>

<cffunction name="getEvictions" hint="get the total number of cache evictions for this class" access="public" returntype="numeric" output="false">
	<cfargument name="className" hint="the class to retrive hits for" type="string" required="Yes">
	<cfscript>
		if(getEHCacheManager().cacheExists(arguments.className))
		{
			return getEHCacheManager().getCache(arguments.className).getStatistics().getEvictionCount();
		}

		return 0;
    </cfscript>
</cffunction>

<cffunction name="resetStatistics" hint="resets the statistics" access="public" returntype="void" output="false">
	<cfscript>
		var classes = getCachedClasses();
		var class = 0;
    </cfscript>
	<cfloop array="#classes#" index="class">
		<cfscript>
			getEHCacheManager().getCache(class).clearStatistics();
        </cfscript>
	</cfloop>
</cffunction>

<cffunction name="clone" hint="throws CloneNotSupportedException" access="public" returntype="any" output="false">
	<cfscript>
		var exc = createObject("java", "java.lang.CloneNotSupportedException").init();
    </cfscript>
	<cfthrow object="#exc#">
</cffunction>

<cffunction name="dispose" hint="Give the listener a chance to cleanup and free resources when no longer needed" access="public" returntype="any" output="false">
</cffunction>

<cffunction name="notifyElementEvicted" hint="Called immediately after an element is evicted from the cache" access="public" returntype="void" output="false">
	<cfargument name="cache" hint="the cache in question" type="any" required="Yes">
	<cfargument name="element" hint="the element in question" type="any" required="Yes">
	<cfscript>
		discardElement(arguments.element);
    </cfscript>
</cffunction>

<cffunction name="notifyElementExpired" hint="Called immediately after an element is found to be expired." access="public" returntype="void" output="false">
	<cfargument name="cache" hint="the cache in question" type="any" required="Yes">
	<cfargument name="element" hint="the element in question" type="any" required="Yes">
	<cfscript>
		discardElement(arguments.element);
    </cfscript>
</cffunction>

<cffunction name="notifyElementPut" hint="Called immediately after an element has been put into the cache." access="public" returntype="void" output="false">
	<cfargument name="cache" hint="the cache in question" type="any" required="Yes">
	<cfargument name="element" hint="the element in question" type="any" required="Yes">
	<cfscript>
    </cfscript>
</cffunction>

<cffunction name="notifyElementRemoved" hint="Called immediately after an attempt to remove an element." access="public" returntype="void" output="false">
	<cfargument name="cache" hint="the cache in question" type="any" required="Yes">
	<cfargument name="element" hint="the element in question" type="any" required="Yes">
	<cfscript>
		discardElement(arguments.element);
    </cfscript>
</cffunction>

<cffunction name="notifyElementUpdated" hint="Called immediately after an element has been put into the cache and the element already existed in the cache." access="public" returntype="void" output="false">
	<cfargument name="cache" hint="the cache in question" type="any" required="Yes">
	<cfargument name="element" hint="the element in question" type="any" required="Yes">
</cffunction>

<cffunction name="notifyRemoveAll" hint=" Called during Ehcache.removeAll() to indicate that the all elements have been removed from the cache in a bulk operation." access="public" returntype="void" output="false">
	<cfargument name="cache" hint="the cache in question" type="any" required="Yes">
</cffunction>

<cffunction name="getCacheProvider" hint="Returns the EHCache CacheManager" access="public" returntype="any" output="false">
	<cfreturn getEHCacheManager() />
</cffunction>

<cffunction name="shutdown" hint="Some cache implementations may need to be shutdown for cleanup. Overwrite this method when needing this functionality."
			access="public" returntype="void" output="false">
	<cfscript>
		getEHCacheManager().shutdown();
    </cfscript>
</cffunction>

<cffunction name="println" hint="" access="private" returntype="void" output="false">
	<cfargument name="str" hint="" type="string" required="Yes">
	<cfscript>
		createObject("Java", "java.lang.System").out.println(arguments.str);
	</cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="discardElement" hint="Fires off the discard to all the Observers" access="private" returntype="void" output="false">
	<cfargument name="element" hint="the element being discarded" type="any" required="Yes">
	<cfscript>
		var local = {};

		local.object = arguments.element.getObjectValue();

		if(structKeyExists(local, "object"))
		{
			fireDiscardEvent(local.object);
		}
    </cfscript>
</cffunction>

<cffunction name="queryJars" hint="pulls a query of all the jars in the /resources/lib folder" access="private" returntype="array" output="false">
	<cfscript>
		var qJars = 0;
		//the path to my jar library
		var path = getDirectoryFromPath(getMetaData(this).path) & "/ehcache-lib";
		var jarList = "";
		var aJars = ArrayNew(1);
		var libName = 0;
	</cfscript>

	<cfdirectory action="list" name="qJars" directory="#path#" filter="*.jar" sort="name desc"/>

	<cfloop query="qJars">
		<cfset ArrayAppend(aJars, directory & "/" & name)>
	</cfloop>

	<cfreturn aJars>
</cffunction>

<cffunction name="getEHCacheManager" access="private" returntype="any" output="false">
	<cfreturn instance.eHCacheManager />
</cffunction>

<cffunction name="setEHCacheManager" access="private" returntype="void" output="false">
	<cfargument name="eHCacheManager" type="any" required="true">
	<cfset instance.eHCacheManager = arguments.eHCacheManager />
</cffunction>

<cffunction name="getJavaLoader" access="public" returntype="transfer.com.util.javaLoader.JavaLoader" output="false">
	<cfreturn StructFind(server, instance.static.SERVER_KEY) />
</cffunction>

<cffunction name="setJavaLoader" access="public" returntype="void" output="false">
	<cfargument name="javaLoader" type="transfer.com.util.javaLoader.JavaLoader" required="true">
	<cfset StructInsert(server, instance.static.SERVER_KEY, arguments.javaLoader) />
</cffunction>

<cffunction name="hasJavaLoader" hint="if the server scope has the JavaLoader in it" access="public" returntype="boolean" output="false">
	<cfreturn StructKeyExists(server, instance.static.SERVER_KEY)/>
</cffunction>

<cffunction name="getSystem" access="private" returntype="any" output="false">
	<cfreturn instance.System />
</cffunction>

<cffunction name="setSystem" access="private" returntype="void" output="false">
	<cfargument name="System" type="any" required="true">
	<cfset instance.System = arguments.System />
</cffunction>

<cffunction name="getDefaultCache" access="private" returntype="any" output="false">
	<cfreturn instance.defaultCache />
</cffunction>

<cffunction name="setDefaultCache" access="private" returntype="void" output="false">
	<cfargument name="defaultCache" type="any" required="true">
	<cfset instance.defaultCache = arguments.defaultCache />
</cffunction>

<cffunction name="getProxy" access="private" returntype="any" output="false">
	<cfreturn instance.proxy />
</cffunction>

<cffunction name="setProxy" access="private" returntype="void" output="false">
	<cfargument name="proxy" type="any" required="true">
	<cfset instance.proxy = arguments.proxy />
</cffunction>

<cffunction name="getArrays" access="private" returntype="any" output="false">
	<cfreturn instance.arrays />
</cffunction>

<cffunction name="setArrays" access="private" returntype="void" output="false">
	<cfargument name="arrays" type="any" required="true">
	<cfset instance.arrays = arguments.arrays />
</cffunction>

</cfcomponent>