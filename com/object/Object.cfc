<!--- Document Information -----------------------------------------------------

Title:      Object.cfc

Author:     Mark Mandel
Email:      mark@compoundtheory.com

Website:    http://www.compoundtheory.com

Purpose:    The object defintion BO

Usage:

Modification Log:

Name			Date			Description
================================================================================
Mark Mandel		11/07/2005		Created

------------------------------------------------------------------------------->
<cfcomponent name="Object" hint="The Object defintion BO" extends="AbstractBaseMeta">

<!------------------------------------------- PUBLIC ------------------------------------------->

<cffunction name="init" hint="Constructor" access="public" returntype="Object" output="false">
	<cfargument name="objectManager" hint="The object manager" type="transfer.com.object.ObjectManager" required="Yes">
	<cfscript>
		super.init();

		setObjectManager(arguments.objectManager);

		clearProperties();
		clearManyToMany();
		clearManyToOne();
		setParentOneToMany(ArrayNew(1));
		setParentManyToMany(ArrayNew(1));
		clearOneToMany();

		setFunction(ArrayNew(1));
		setHash("");
		setClassName("");
		setTable("");
		setObjectName("");

		setSequence("");
		setDecorator("");

		setIsComplete(false);

		return this;
	</cfscript>
</cffunction>

<cffunction name="setMemento" hint="Sets the state of the object" access="public" returntype="void" output="false">
	<cfargument name="memento" hint="The memento to set the state of the object" type="struct" required="Yes">

	<cfscript>
		//let's set state
		var len = ArrayLen(arguments.memento.properties);
		var counter = 1;
		var property = 0;
		var manyToMany = 0;
		var manyToOne = 0;
		var oneToMany = 0;
		var parentOneToMany = 0;
		var customFunction = 0;

		setClassName(arguments.memento.className);

		clearProperties();
		clearManyToMany();
		clearManyToOne();
		clearOneToMany();

		setTable(arguments.memento.table);
		setHash(arguments.memento.hash);
		setObjectName(arguments.memento.objectName);
		setSequence(arguments.memento.sequence);
		setDecorator(arguments.memento.decorator);

		//add in properties
		for(;counter lte len; counter = counter + 1)
		{
			property = createObject("component", "transfer.com.object.Property").init();
			property.setMemento(arguments.memento.properties[counter]);
			addProperty(property);
		}

		//add in one one to many
		len = ArrayLen(arguments.memento.oneToMany);
		for(counter = 1; counter lte len; counter = counter + 1)
		{
			oneToMany = createObject("component", "transfer.com.object.OneToMany").init(this, getObjectManager());
			oneToMany.setMemento(arguments.memento.oneToMany[counter]);
			addOneToMany(oneToMany);
		}

		//add in manyToOne
		len = ArrayLen(arguments.memento.manyToOne);
		for(counter = 1; counter lte len; counter = counter + 1)
		{
			manyToOne = createObject("component", "transfer.com.object.ManyToOne").init(this, getObjectManager());
			manyToOne.setMemento(arguments.memento.manyToOne[counter]);
			addManyToOne(ManyToOne);
		}

		//add in ManyToMany
		len = ArrayLen(arguments.memento.manyToMany);
		for(counter = 1; counter lte len; counter = counter + 1)
		{
			manyToMany = createObject("component", "transfer.com.object.ManyToMany").init(this, getObjectManager());
			manyToMany.setMemento(arguments.memento.manyToMany[counter]);
			addManyToMany(manyToMany);
		}

		//set primary key
		if(StructKeyExists(arguments.memento.id, "compositekey"))
		{
			setPrimaryKey(createObject("component", "transfer.com.object.CompositeKey").init(this));
		}
		else
		{
			setPrimaryKey(createObject("component", "transfer.com.object.PrimaryKey").init());
		}

		getPrimaryKey().setMemento(arguments.memento.id);

		//set the table alias, if ti exists
		if(StructKeyExists(arguments.memento, "tablealias"))
		{
			setTableAlias(arguments.memento.tableAlias);
		}

		//add in custom functions
		len = ArrayLen(arguments.memento.function);
		for(counter = 1; counter lte len; counter = counter + 1)
		{
			customFunction = createObject("component", "transfer.com.object.TFunction").init();
			customFunction.setMemento(arguments.memento.function[counter]);
			addFunction(customFunction);
		}
	</cfscript>
</cffunction>

<cffunction name="getClassName" access="public" returntype="string" output="false">
	<cfreturn instance.ClassName />
</cffunction>

<cffunction name="getHash" access="public" returntype="string" output="false">
	<cfreturn instance.Hash />
</cffunction>

<cffunction name="getTable" access="public" returntype="string" output="false">
	<cfreturn instance.Table />
</cffunction>

<cffunction name="getObjectName" access="public" returntype="string" output="false">
	<cfreturn instance.ObjectName />
</cffunction>

<cffunction name="getPropertyIterator" hint="Gets the java.util.Iterator for the list of properties" access="public" returntype="any" output="false">
	<cfreturn getProperties().iterator()>
</cffunction>

<cffunction name="clearManyToOne" hint="Removes all manytoone elements" access="public" returntype="void" output="false">
	<cfscript>
		setManyToOne(ArrayNew(1));
	</cfscript>
</cffunction>

<cffunction name="clearManyToMany" hint="Removes all manytoone elements" access="public" returntype="void" output="false">
	<cfscript>
		setManyToMany(ArrayNew(1));
	</cfscript>
</cffunction>

<cffunction name="clearOneToMany" hint="Removes all manytoone elements" access="public" returntype="void" output="false">
	<cfscript>
		setOneToMany(ArrayNew(1));
	</cfscript>
</cffunction>

<cffunction name="addManyToOne" hint="add a Many to Many" access="public" returntype="void" output="false">
	<cfargument name="manyToOne" hint="A Many to One BO" type="ManyToOne" required="Yes">
	<cfscript>
		ArrayAppend(getManyToOne(), arguments.manyToOne);
	</cfscript>
</cffunction>

<cffunction name="addManyToMany" hint="add a  Many to Many" access="public" returntype="void" output="false">
	<cfargument name="manyToMany" hint="A Many to Many BO" type="ManyToMany" required="Yes">
	<cfscript>
		ArrayAppend(getManyToMany(), arguments.manyToMany);
	</cfscript>
</cffunction>

<cffunction name="addParentManyToMany" hint="add a Parent Many to Many" access="public" returntype="void" output="false">
	<cfargument name="manyToMany" hint="A Many to Many BO" type="ManyToMany" required="Yes">
	<cfscript>
		ArrayAppend(getParentManyToMany(), arguments.manyToMany);
	</cfscript>
</cffunction>

<cffunction name="addParentOneToMany" hint="add a Parent One to Many" access="public" returntype="void" output="false">
	<cfargument name="parentOneToMany" hint="A Parent to Many BO" type="ParentOneToMany" required="Yes">
	<cfscript>
		ArrayAppend(getParentOneToMany(), arguments.parentOneToMany);
	</cfscript>
</cffunction>

<cffunction name="addOneToMany" hint="add a One to Many" access="public" returntype="void" output="false">
	<cfargument name="oneToMany" hint="A One to Many BO" type="OneToMany" required="Yes">
	<cfscript>
		ArrayAppend(getOneToMany(), arguments.oneToMany);
	</cfscript>
</cffunction>

<cffunction name="getPropertyByName" hint="Gets a property by name. Throws PropertyNotFoundException if the property doesn't exist" access="public" returntype="Property" output="false">
	<cfargument name="name" hint="The name of the property" type="string" required="Yes">
	<cfscript>
		var map = getPropertyMap();

		if(StructKeyExists(map, arguments.name))
		{
			return map[arguments.name];
		}

		if(getPrimaryKey().getName() eq arguments.name)
		{
			return getPrimaryKey();
		}
		
		createObject("component", "transfer.com.object.exception.PropertyNotFoundException").init(getClassName(), arguments.name);
	</cfscript>
</cffunction>

<cffunction name="hasProperty" hint="does the object have a property of a given name" access="public" returntype="boolean" output="false">
<cfargument name="name" hint="The name of the property" type="string" required="Yes">
	<cfscript>
		if(StructKeyExists(getPropertyMap(), arguments.name))
		{
			return true;
		}

		if(getPrimaryKey().getName() eq arguments.name)
		{
			return true;
		}

		return false;

	</cfscript>
</cffunction>

<cffunction name="getManyToOneByName" hint="Gets a manytoone by name. Throws ManyToOneNotFoundException if the manytoone doesn't exist" access="public" returntype="ManyToOne" output="false">
	<cfargument name="name" hint="The name of the manytoone" type="string" required="Yes">
	<cfscript>
		var iterator = getManyToOneIterator();
		var manytoone = 0;

		while(iterator.hasNext())
		{
			manytoone = iterator.next();
			if(manytoone.getName() eq arguments.name)
			{
				return manytoone;
			}
		}
		
		createObject("component", "transfer.com.object.exception.ManyToOneNotFoundException").init(getClassName(), arguments.name);
	</cfscript>
</cffunction>

<cffunction name="containsManyToOne" hint="returns if this object has this manytoone" access="public" returntype="boolean" output="false">
	<cfargument name="name" hint="The name of the manytoone" type="string" required="Yes">
	<cfscript>
		var iterator = getManyToOneIterator();
		var manytoone = 0;

		while(iterator.hasNext())
		{
			manytoone = iterator.next();
			if(manytoone.getName() eq arguments.name)
			{
				return true;
			}
		}

		return false;
	</cfscript>
</cffunction>

<cffunction name="containsParentManyToMany" hint="returns if this object has this parent manytomany" access="public" returntype="boolean" output="false">
	<cfargument name="name" hint="The name of the parent manytomany" type="string" required="Yes">
	<cfscript>
		var iterator = getParentManyToManyIterator();
		var parentManytoMany = 0;

		while(iterator.hasNext())
		{
			parentManytoMany = iterator.next();
			if(parentManytoMany.getName() eq arguments.name)
			{
				return true;
			}
		}

		return false;
	</cfscript>
</cffunction>


<cffunction name="getManyToOneArrayByLink" hint="returns an array of many to one properties that link to this class" access="public" returntype="array" output="false">
	<cfargument name="className" hint="the name of the class to search for" type="string" required="Yes">
	<cfargument name="filterName" hint="The many to many name to filter by" type="string" required="No">
	<cfscript>
		var relationships = ArrayNew(1);
		var manytoone = 0;

		var iterator = getManyToOneIterator();
		while(iterator.hasNext())
		{
			manytoone = iterator.next();
			if(manytoone.getLink().getTo() eq arguments.className)
			{
				if(NOT StructKeyExists(arguments, "filterName") OR manytoone.getName() eq arguments.filterName)
				{
					ArrayAppend(relationships, manytoone);
					//if we have a filter name, we can escape, as there will only ever be one
					if(StructKeyExists(arguments, "filterName"))
					{
						return relationships;
					}
				}
			}
		}

		return relationships;
	</cfscript>
</cffunction>

<cffunction name="getOneToManyByName" hint="Gets a OneToMany by name. Throws OneToManyNotFoundException if the OneToMany doesn't exist" access="public" returntype="OneToMany" output="false">
	<cfargument name="name" hint="The name of the property" type="string" required="Yes">
	<cfscript>
		var iterator = getOneToManyIterator();
		var onetomany = 0;

		while(iterator.hasNext())
		{
			onetomany = iterator.next();
			if(onetomany.getName() eq arguments.name)
			{
				return onetomany;
			}
		}

		createObject("component", "transfer.com.object.exception.OneToManyNotFoundException").init(getClassName(), arguments.name);
	</cfscript>
</cffunction>

<cffunction name="getOneToManyArrayByLink" hint="returns an array of one to many properties that link to this class" access="public" returntype="array" output="false">
	<cfargument name="className" hint="the name of the class to search for" type="string" required="Yes">
	<cfargument name="filterName" hint="The many to many name to filter by" type="string" required="No">
	<cfscript>
		var relationships = ArrayNew(1);
		var onetomany = 0;
		var iterator = getOneToManyIterator();

		while(iterator.hasNext())
		{
			onetomany = iterator.next();
			if(onetomany.getLink().getTo() eq arguments.className)
			{
				if(NOT StructKeyExists(arguments, "filterName") OR onetomany.getName() eq arguments.filterName)
				{
					ArrayAppend(relationships, onetomany);

					//if we have a filter name, we can escape, as there will only ever be one
					if(StructKeyExists(arguments, "filterName"))
					{
						return relationships;
					}
				}
			}
		}

		return relationships;
	</cfscript>
</cffunction>

<cffunction name="getParentOneToManyByName" hint="Gets a Parent OneToMany by name. Throws ParentOneToManyNotFoundException if the ParentOneToMany doesn't exist" access="public" returntype="ParentOneToMany" output="false">
	<cfargument name="name" hint="The name of the parent onetoomany" type="string" required="Yes">
	<cfscript>
		var iterator = getParentOneToManyIterator();
		var parentonetomany = 0;

		while(iterator.hasNext())
		{
			parentonetomany = iterator.next();
			if(parentonetomany.getName() eq arguments.name)
			{
				return parentonetomany;
			}
		}
		
		createObject("component", "transfer.com.object.exception.ParentOneToManyNotFoundException").init(getClassName(), arguments.name);
	</cfscript>
</cffunction>

<cffunction name="getParentOneToManyByClass" hint="Gets a Parent OneToMany by Class. Throws ParentOneToManyNotFoundException if the ParentOneToMany doesn't exist" access="public" returntype="ParentOneToMany" output="false">
	<cfargument name="className" hint="The class of the parent onetomany" type="string" required="Yes">
	<cfscript>
		var iterator = getParentOneToManyIterator();
		var parentonetomany = 0;

		while(iterator.hasNext())
		{
			parentonetomany = iterator.next();
			if(parentonetomany.getLink().getTo() eq arguments.className)
			{
				return parentonetomany;
			}
		}
		
		createObject("component", "transfer.com.object.exception.ParentOneToManyNotFoundException").init(className=getClassName(), parentClassName=arguments.className);
	</cfscript>
</cffunction>

<cffunction name="containsParentOneToMany" hint="Returns whether or not this object has this parent one to many" access="public" returntype="boolean" output="false">
	<cfargument name="className" hint="The class of the parent onetomany" type="string" required="Yes">
	<cfscript>
		var iterator = getParentOneToManyIterator();
		var parentonetomany = 0;

		while(iterator.hasNext())
		{
			parentonetomany = iterator.next();
			if(parentonetomany.getLink().getTo() eq arguments.className)
			{
				return true;
			}
		}

		return false;
	</cfscript>
</cffunction>

<cffunction name="containsManyToMany" hint="Whether or not this object has a given manytomany of a given name" access="public" returntype="boolean" output="false">
	<cfargument name="name" hint="The name of the manytomany" type="string" required="Yes">
	<cfscript>
		var iterator = getManyToManyIterator();
		var manytomany = 0;

		while(iterator.hasNext())
		{
			manytomany = iterator.next();
			if(manytomany.getName() eq arguments.name)
			{
				return true;
			}
		}

		return false;
	</cfscript>
</cffunction>

<cffunction name="getManyToManyByName" hint="Gets a ManyToMany by name. Throws ManyToManyNotFoundException if the ManyToMany doesn't exist" access="public" returntype="ManyToMany" output="false">
	<cfargument name="name" hint="The name of the manytomany" type="string" required="Yes">
	<cfscript>
		var iterator = getManyToManyIterator();
		var manytomany = 0;

		while(iterator.hasNext())
		{
			manytomany = iterator.next();
			if(manytomany.getName() eq arguments.name)
			{
				return manytomany;
			}
		}
		
		createObject("component", "transfer.com.object.exception.ManyToManyNotFoundException").init(getClassName(), arguments.name);
	</cfscript>
</cffunction>

<cffunction name="getManyToManyArrayByLink" hint="returns an array of many to many properties that link to this class" access="public" returntype="array" output="false">
	<cfargument name="className" hint="the name of the class to search for" type="string" required="Yes">
	<cfargument name="filterName" hint="The many to many name to filter by" type="string" required="No">
	<cfscript>
		var relationships = ArrayNew(1);
		var manytomany = 0;
		var iterator = getManyToManyIterator();

		while(iterator.hasNext())
		{
			manytomany = iterator.next();
			if(manytomany.getLinkTo().getTo() eq arguments.className)
			{
				if(NOT StructKeyExists(arguments, "filterName") OR manytomany.getName() eq arguments.filterName)
				{
					ArrayAppend(relationships, manytomany);
					//if we have a filter name, we can escape, as there will only ever be one
					if(StructKeyExists(arguments, "filterName"))
					{
						return relationships;
					}
				}
			}
		}

		return relationships;
	</cfscript>
</cffunction>

<cffunction name="getLinkingClassName" hint="returns the linking class name, throws an CompositionNotFoundException if nothing is found" access="public" returntype="string" output="false">
	<cfargument name="compositeName" hint="The name of the composition to search for" type="string" required="Yes">
	<cfscript>
		var onetomany = 0;
		var manytomany = 0;
		var manytoone = 0;
		var iterator = getOneToManyIterator();

		while(iterator.hasNext())
		{
			onetomany = iterator.next();
			if(onetomany.getName() eq arguments.compositeName)
			{
				return onetomany.getLink().getTo();
			}
		}

		iterator = getManyToManyIterator();

		while(iterator.hasNext())
		{
			manytomany = iterator.next();
			if(manytomany.getName() eq arguments.compositeName)
			{
				return manytomany.getLinkTo().getTo();
			}
		}

		iterator = getManyToOneIterator();

		while(iterator.hasNext())
		{
			manytoone = iterator.next();
			if(manytoone.getName() eq arguments.compositeName)
			{
				return manytoone.getLink().getTo();
			}
		}
		
		createObject("component", "transfer.com.object.exception.CompositionNotFoundException").init(getClassName(), arguments.compositeName);
	</cfscript>
</cffunction>

<cffunction name="getManyToManyIterator" hint="Gets the java.util.Iterator for the list of Many to Many" access="public" returntype="any" output="false">
	<cfreturn getManyToMany().iterator()>
</cffunction>

<cffunction name="hasManyToMany" hint="Whether or not the object has any manytomany collections" access="public" returntype="boolean" output="false">
	<cfreturn NOT ArrayIsEmpty(getManyToMany())/>
</cffunction>

<cffunction name="getManyToOneIterator" hint="Gets the java.util.Iterator for the list of Many to One" access="public" returntype="any" output="false">
	<cfreturn getManyToOne().iterator()>
</cffunction>

<cffunction name="hasManyToOne" hint="Whether or not the object has any manytoone collections" access="public" returntype="boolean" output="false">
	<cfreturn NOT ArrayIsEmpty(getManyToOne())/>
</cffunction>

<cffunction name="getOneToManyIterator" hint="Gets the java.util.Iterator for the list of One to Many" access="public" returntype="any" output="false">
	<cfreturn getOneToMany().iterator()>
</cffunction>

<cffunction name="hasOneToMany" hint="Whether or not the object has any onetomany collections" access="public" returntype="boolean" output="false">
	<cfreturn NOT ArrayIsEmpty(getOneToMany())/>
</cffunction>

<cffunction name="getParentOneToManyIterator" hint="Gets the java.util.Iterator for the list of Parent One to Many" access="public" returntype="any" output="false">
	<cfreturn getParentOneToMany().iterator()>
</cffunction>

<cffunction name="hasParentOneToMany" hint="Whether or not the object has a parent onetomany collections" access="public" returntype="boolean" output="false">
	<cfreturn NOT ArrayIsEmpty(getParentOneToMany())/>
</cffunction>

<cffunction name="getParentManyToManyIterator" hint="Gets the java.util.Iterator for the list of Parent Many to Many" access="public" returntype="any" output="false">
	<cfreturn getParentManyToMany().iterator()>
</cffunction>

<cffunction name="hasParentManyToMany" hint="Whether or not the object has a parent manytomany collections" access="public" returntype="boolean" output="false">
	<cfreturn NOT ArrayIsEmpty(getParentManyToMany())/>
</cffunction>

<cffunction name="getFunctionIterator" hint="Gets the java.util.Iterator for the list of custom functions" access="public" returntype="any" output="false">
	<cfreturn getFunction().iterator()>
</cffunction>

<cffunction name="getPrimaryKey" access="public" returntype="AbstractBaseKey" output="false">
	<cfreturn instance.PrimaryKey />
</cffunction>

<cffunction name="getSequence" access="public" returntype="string" output="false">
	<cfreturn instance.Sequence />
</cffunction>

<cffunction name="getDecorator" access="public" returntype="string" output="false">
	<cfreturn instance.Decorator />
</cffunction>

<cffunction name="hasDecorator" access="public" returntype="boolean" output="false">
	<cfreturn Len(getDecorator()) />
</cffunction>

<cffunction name="getTableAlias" access="public" returntype="string" output="false">
	<cfreturn instance.tableAlias />
</cffunction>

<cffunction name="hasTableAlias" hint="if the object has a table alias" access="public" returntype="boolean" output="false">
	<cfreturn StructKeyExists(instance, "tableAlias") />
</cffunction>

<cffunction name="validate" hint="Throws an exception if validation fails" access="public" returntype="void" output="false">
	<cfscript>
		var iterator = getManyToManyIterator();
		var manytomany = 0;
		var manytoone = 0;

		/*
			right now, I only need to validate manytoones and manytomany's for bad composite key structure
		*/
		while(iterator.hasNext())
		{
			manytomany = iterator.next();
			manytomany.validate();
		}

		iterator = getManyToOneIterator();

		while(iterator.hasNext())
		{
			manytoone = iterator.next();
			manytoone.validate();
		}

		getPrimaryKey().validate();
	</cfscript>
</cffunction>

<!------------------------------------------- PACKAGE ------------------------------------------->

<cffunction name="getIsComplete" access="package" returntype="boolean" output="false">
	<cfreturn instance.isComplete />
</cffunction>

<cffunction name="notifyComplete" hint="notifies the object that it has finished loading, and can do post processing" access="package" returntype="void" output="false">
	<cfscript>
		var iterator = 0;
		var manytomany = 0;
		var onetomany = 0;
		var hash = 0;
		var parentOnetoMany = 0;

		if(getIsComplete())
		{
			return;
		}

		hash = getHash();
		iterator = getParentOneToManyIterator();

		while(iterator.hasNext())
		{
			parentOnetoMany = iterator.next();

			hash = hash & parentOneToMany.getLink().getToObject().getHash();
		}

		setHash(hash(hash));

		iterator = getManyToManyIterator();

		while(iterator.hasNext())
		{
			manytomany = iterator.next();
			manytomany.notifyComplete();
		}

		iterator = getOneToManyIterator();

		while(iterator.hasNext())
		{
			onetomany = iterator.next();
			onetomany.notifyComplete();
		}

		getPrimaryKey().notifyComplete();

		setIsComplete(true);
	</cfscript>
</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->

<cffunction name="setIsComplete" access="private" returntype="void" output="false">
	<cfargument name="isComplete" type="boolean" required="true">
	<cfset instance.isComplete = arguments.isComplete />
</cffunction>


<cffunction name="setDecorator" access="private" returntype="void" output="false">
	<cfargument name="Decorator" type="string" required="true">
	<cfset instance.Decorator = arguments.Decorator />
</cffunction>

<cffunction name="setSequence" access="private" returntype="void" output="false">
	<cfargument name="Sequence" type="string" required="true">
	<cfset instance.Sequence = arguments.Sequence />
</cffunction>

<cffunction name="setPrimaryKey" access="private" returntype="void" output="false">
	<cfargument name="PrimaryKey" type="AbstractBaseKey" required="true">
	<cfset instance.PrimaryKey = arguments.PrimaryKey />
</cffunction>

<cffunction name="setClassName" access="private" returntype="void" output="false">
	<cfargument name="ClassName" type="string" required="true">
	<cfset instance.ClassName = arguments.ClassName />
</cffunction>

<cffunction name="setTable" access="private" returntype="void" output="false">
	<cfargument name="Table" type="string" required="true">
	<cfset instance.Table = arguments.Table />
</cffunction>

<cffunction name="setObjectName" access="private" returntype="void" output="false">
	<cfargument name="ObjectName" type="string" required="true">
	<cfset instance.ObjectName = arguments.ObjectName />
</cffunction>

<cffunction name="setTableAlias" access="private" returntype="void" output="false">
	<cfargument name="tableAlias" type="string" required="true">
	<cfset instance.tableAlias = arguments.tableAlias />
</cffunction>

<cffunction name="addProperty" hint="Adds a property to the Object" access="private" returntype="void" output="false">
	<cfargument name="Property" hint="The property to add" type="Property" required="Yes">
	<cfscript>
		ArrayAppend(getProperties(), arguments.property);
		StructInsert(getPropertyMap(), arguments.property.getName(), arguments.property);
	</cfscript>
</cffunction>

<cffunction name="clearProperties" hint="clears the properies" access="private" returntype="void" output="false">
	<cfscript>
		setProperties(ArrayNew(1));
		setPropertyMap(StructNew());
	</cfscript>
</cffunction>

<cffunction name="getProperties" access="private" returntype="array" output="false">
	<cfreturn instance.Properties />
</cffunction>

<cffunction name="setProperties" access="private" returntype="void" output="false">
	<cfargument name="Properties" type="array" required="true">
	<cfset instance.Properties = arguments.Properties />
</cffunction>

<cffunction name="getPropertyMap" access="private" returntype="struct" output="false">
	<cfreturn instance.PropertyMap />
</cffunction>

<cffunction name="setPropertyMap" access="private" returntype="void" output="false">
	<cfargument name="PropertyMap" type="struct" required="true">
	<cfset instance.PropertyMap = arguments.PropertyMap />
</cffunction>

<cffunction name="getManyToOne" access="private" returntype="array" output="false">
	<cfreturn instance.ManyToOne />
</cffunction>

<cffunction name="setManyToOne" access="private" returntype="void" output="false">
	<cfargument name="ManyToOne" type="array" required="true">
	<cfset instance.ManyToOne = arguments.ManyToOne />
</cffunction>

<cffunction name="getManyToMany" access="private" returntype="array" output="false">
	<cfreturn instance.ManyToMany />
</cffunction>

<cffunction name="setManyToMany" access="private" returntype="void" output="false">
	<cfargument name="ManyToMany" type="array" required="true">
	<cfset instance.ManyToMany = arguments.ManyToMany />
</cffunction>

<cffunction name="getParentManyToMany" access="private" returntype="array" output="false">
	<cfreturn instance.parentManyToMany />
</cffunction>

<cffunction name="setParentManyToMany" access="private" returntype="void" output="false">
	<cfargument name="manyToMany" type="array" required="true">
	<cfset instance.parentManyToMany = arguments.manyToMany />
</cffunction>

<cffunction name="getOneToMany" access="private" returntype="array" output="false">
	<cfreturn instance.OneToMany />
</cffunction>

<cffunction name="setOneToMany" access="private" returntype="void" output="false">
	<cfargument name="OneToMany" type="array" required="true">
	<cfset instance.OneToMany = arguments.OneToMany />
</cffunction>

<cffunction name="getParentOneToMany" access="private" returntype="array" output="false">
	<cfreturn instance.ParentOneToMany />
</cffunction>

<cffunction name="setParentOneToMany" access="private" returntype="void" output="false">
	<cfargument name="ParentOneToMany" type="array" required="true">
	<cfset instance.ParentOneToMany = arguments.ParentOneToMany />
</cffunction>

<cffunction name="getFunction" access="private" returntype="array" output="false">
	<cfreturn instance.Function />
</cffunction>

<cffunction name="setFunction" access="private" returntype="void" output="false">
	<cfargument name="Function" type="array" required="true">
	<cfset instance.Function = arguments.Function />
</cffunction>

<cffunction name="addFunction" hint="add a Custom Function" access="private" returntype="void" output="false">
	<cfargument name="Function" hint="A Custom Function BO" type="TFunction" required="Yes">
	<cfscript>
		ArrayAppend(getFunction(), arguments.function);
	</cfscript>
</cffunction>

<cffunction name="setHash" access="private" returntype="void" output="false">
	<cfargument name="Hash" type="string" required="true">
	<cfset instance.Hash = arguments.Hash />
</cffunction>

<cffunction name="getObjectManager" access="private" returntype="transfer.com.object.ObjectManager" output="false">
	<cfreturn instance.ObjectManager />
</cffunction>

<cffunction name="setObjectManager" access="private" returntype="void" output="false">
	<cfargument name="ObjectManager" type="transfer.com.object.ObjectManager" required="true">
	<cfset instance.ObjectManager = arguments.ObjectManager />
</cffunction>

<!--- mixins --->

<cffunction name="setInstance" hint="overwritten setInstance, to also clone composite elements" access="public" returntype="void" output="false">
	<cfargument name="instance" hint="the instance scope to pass through" type="struct" required="Yes">
	<cfscript>
		instance.manytoone = cloneArray(instance.manytoone);
		instance.manytomany = cloneArray(instance.manytomany);
		instance.parentManyToMany = cloneArray(instance.parentManyToMany);
		instance.oneToMany = cloneArray(instance.oneToMany);
		instance.parentOneToMany = cloneArray(instance.parentOneToMany);

		super.setInstance(arguments.instance);
	</cfscript>
</cffunction>

</cfcomponent>

