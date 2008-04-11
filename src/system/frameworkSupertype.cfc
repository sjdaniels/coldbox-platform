<!-----------------------------------------------------------------------********************************************************************************Copyright 2005-2007 ColdBox Framework by Luis Majano and Ortus Solutions, Corpwww.coldboxframework.com | www.luismajano.com | www.ortussolutions.com********************************************************************************Author 	    :	Luis MajanoDate        :	August 21, 2006Description :	This is a cfc that contains method implementations for the base	cfc's eventhandler and plugin. This is an action base controller,	is where all action methods will be placed.	The front controller remains lean and mean.-----------------------------------------------------------------------><cfcomponent name="frameworkSupertype" 			 hint="This is the layer supertype cfc." 			 output="false"><!------------------------------------------- CONSTRUCTOR ------------------------------------------->	<cfscript>	/* Controller Reference */	controller = structNew();	/* Instance scope */	instance = structnew();	/* Unique Instance ID for the object. */	instance.__hash = hash(createUUID());	</cfscript><!------------------------------------------- RESOURCE METHODS ------------------------------------------->		<!--- Get object Hash --->	<cffunction name="getHash" access="public" hint="Get the instance's unique UUID" returntype="string" output="false">		<cfreturn instance.__hash>	</cffunction>		<!--- Discover fw Locale --->	<cffunction name="getfwLocale" access="public" output="false" returnType="any" hint="Get the default locale string used in the framework. Returns a string">		<cfscript>			var localeStorage = controller.getSetting("LocaleStorage");			var storage = evaluate(localeStorage);			if ( localeStorage eq "" )				throw("The default settings in your config are blank. Please make sure you create the i18n elements.","","Framework.actioncontroller.i18N.DefaultSettingsInvalidException");			if ( not structKeyExists(storage,"DefaultLocale") ){				controller.getPlugin("i18n").setfwLocale(controller.getSetting("DefaultLocale"));			}			return storage["DefaultLocale"];		</cfscript>	</cffunction>	<!------------------------------------------- Private RESOURCE METHODS ------------------------------------------->	<!--- Get a Datasource Object --->	<cffunction name="getDatasource" access="private" output="false" returnType="coldbox.system.beans.datasourceBean" hint="I will return to you a datasourceBean according to the alias of the datasource you wish to get from the configstruct">		<!--- ************************************************************* --->		<cfargument name="alias" type="string" hint="The alias of the datasource to get from the configstruct (alias property in the config file)">		<!--- ************************************************************* --->		<cfscript>		var datasources = controller.getSetting("Datasources");		//Check for datasources structure		if ( structIsEmpty(datasources) ){			throw("There are no datasources defined for this application.","","Framework.actioncontroller.DatasourceStructureEmptyException");		}		//Try to get the correct datasource.		if ( structKeyExists(datasources, arguments.alias) ){			return CreateObject("component","coldbox.system.beans.datasourceBean").init(datasources[arguments.alias]);		}		else{			throw("The datasource: #arguments.alias# is not defined.","","Framework.actioncontroller.DatasourceNotFoundException");		}		</cfscript>	</cffunction>	<!--- Get Mail Settings Object --->	<cffunction name="getMailSettings" access="private" output="false" returnType="coldbox.system.beans.mailsettingsBean" hint="I will return to you a mailsettingsBean modeled after your mail settings in your config file.">		<cfscript>		return CreateObject("component","coldbox.system.beans.mailsettingsBean").init(controller.getSetting("MailServer"),controller.getSetting("MailUsername"),controller.getSetting("MailPassword"), controller.getSetting("MailPort"));		</cfscript>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getResource" access="private" output="false" returnType="any" hint="Facade to i18n.getResource. Returns a string.">		<!--- ************************************************************* --->		<cfargument name="resource" type="any" hint="The resource to retrieve from the bundle.">		<!--- ************************************************************* --->		<cfreturn controller.getPlugin("resourceBundle").getResource("#arguments.resource#")>	</cffunction>	<!--- ************************************************************* --->	<cffunction name="getSettingsBean"  hint="Returns a configBean with all the configuration structure." access="private"  returntype="coldbox.system.beans.configBean"   output="false">		<cfset var ConfigBean = CreateObject("component","coldbox.system.beans.configBean").init(controller.getSettingStructure(false,true))>		<cfreturn ConfigBean>	</cffunction>	<!--- ************************************************************* --->		<cffunction name="announceInterception" access="private" returntype="void" hint="Announce an interception to the system." output="false" >		<cfargument name="state" 			required="true"  type="string" hint="The interception state to execute">
		<cfargument name="interceptData" 	required="false" type="struct" default="#structNew()#" hint="A data structure used to pass intercepted information.">		<cfset controller.getInterceptorService().processState(argumentCollection=arguments)>	</cffunction>		<!--- ************************************************************* --->	<!------------------------------------------- FRAMEWORK FACADES ------------------------------------------->	<!--- View Rendering Facades --->	<cffunction name="renderView"         access="private" hint="Facade to plugin's render view." output="false" returntype="Any">		<!--- ************************************************************* --->		<cfargument name="view" required="true" type="string">		<cfargument name="cache" 					required="false" type="boolean" default="false" hint="True if you want to cache the view.">		<cfargument name="cacheTimeout" 			required="false" type="string"  default=""		hint="The cache timeout">		<cfargument name="cacheLastAccessTimeout" 	required="false" type="string"  default="" 		hint="The last access timeout">		<!--- ************************************************************* --->		<cfreturn controller.getPlugin("renderer").renderView(argumentCollection=arguments)>	</cffunction>	<cffunction name="renderExternalView" access="private" hint="Facade to plugins' render external view." output="false" returntype="Any">		<!--- ************************************************************* --->		<cfargument name="view" required="true" type="string">		<!--- ************************************************************* --->		<cfreturn controller.getPlugin("renderer").renderExternalView(arguments.view)>	</cffunction>		<!--- Purge View Facade --->	<cffunction name="purgeView" output="false" access="private" returntype="void" hint="Purges a view from the cache.">		<!--- ************************************************************* --->		<cfargument name="view" required="true" type="string" hint="The view to purge from the cache">		<!--- ************************************************************* --->		<cfset controller.getPlugin("renderer").purgeView(argumentCollection=arguments)>	</cffunction>	<!--- Plugin Facades --->	<cffunction name="getMyPlugin" access="private" hint="Facade" returntype="any" output="false">		<!--- ************************************************************* --->		<cfargument name="plugin" 		type="any"  	required="true" hint="The plugin name as a string" >		<cfargument name="newInstance"  type="boolean"  required="false" default="false">		<!--- ************************************************************* --->		<cfreturn controller.getPlugin(arguments.plugin, true, arguments.newInstance)>	</cffunction>	<cffunction name="getPlugin"   access="private" hint="Facade" returntype="any" output="false">		<!--- ************************************************************* --->		<cfargument name="plugin"       type="any" hint="The Plugin object's name to instantiate, as a string" >		<cfargument name="customPlugin" type="boolean" required="false" default="false">		<cfargument name="newInstance"  type="boolean" required="false" default="false">		<!--- ************************************************************* --->		<cfreturn controller.getPlugin(argumentCollection=arguments)>	</cffunction>	<!--- Interceptor Facade --->	<cffunction name="getInterceptor" access="private" output="false" returntype="any" hint="Get an interceptor">		<!--- ************************************************************* --->		<cfargument name="interceptorClass" required="true" type="string" hint="The qualified class of the itnerceptor to retrieve">		<!--- ************************************************************* --->		<cfscript>			return controller().getInterceptorService().getInterceptor(arguments.interceptorClass);		</cfscript>	</cffunction>		<!---Cache Facades --->	<cffunction name="getColdboxOCM" access="private" output="false" returntype="any" hint="Get ColdboxOCM: coldbox.system.cache.cacheManager">		<cfreturn controller.getColdboxOCM()/>	</cffunction>	<!--- Setting Facades --->	<cffunction name="getSettingStructure"  hint="Facade" access="private"  returntype="struct"   output="false">		<!--- ************************************************************* --->		<cfargument name="FWSetting"  	type="boolean" 	 required="false"  default="false">		<cfargument name="DeepCopyFlag" type="boolean"   required="false"  default="false">		<!--- ************************************************************* --->		<cfreturn controller.getSettingStructure(argumentCollection=arguments)>	</cffunction>	<cffunction name="getSetting" 			hint="Facade" access="private" returntype="any"      output="false">		<!--- ************************************************************* --->		<cfargument name="name" 	    type="string"   required="true">		<cfargument name="FWSetting"  	type="boolean" 	required="false"  default="false">		<!--- ************************************************************* --->		<cfreturn controller.getSetting(argumentCollection=arguments)>	</cffunction>	<cffunction name="settingExists" 		hint="Facade" access="private" returntype="boolean"  output="false">		<!--- ************************************************************* --->		<cfargument name="name" 		type="string"  	required="true">		<cfargument name="FWSetting"  	type="boolean"  required="false"  default="false">		<!--- ************************************************************* --->		<cfreturn controller.settingExists(argumentCollection=arguments)>	</cffunction>	<cffunction name="setSetting" 		    hint="Facade" access="private"  returntype="void"     output="false">		<!--- ************************************************************* --->		<cfargument name="name"  type="string" required="true" >		<cfargument name="value" type="any" required="true" >		<!--- ************************************************************* --->		<cfset controller.setSetting(argumentCollection=arguments)>	</cffunction>	<!--- Event Facades --->	<cffunction name="setNextEvent" access="private" returntype="void" hint="Facade"  output="false">		<!--- ************************************************************* --->		<cfargument name="event"  			type="string"   required="false"	default="#controller.getSetting("DefaultEvent")#" >		<cfargument name="queryString"  	type="string" 	required="No" 		default="" >		<cfargument name="addToken"			type="boolean" 	required="false" 	default="false"	>		<cfargument name="persist" 			type="string"   required="false"  	default="">		<!--- ************************************************************* --->		<cfset controller.setNextEvent(argumentCollection=arguments)>	</cffunction>	<cffunction name="setNextRoute" access="private" returntype="void" hint="I Set the next ses route to relocate to. This method pre-pends the baseURL"  output="false">		<!--- ************************************************************* --->		<cfargument name="route"  			hint="The route to relocate to, do not prepend the baseURL or /." type="string" required="yes" >		<cfargument name="persist" 			hint="What request collection keys to persist in the relocation" required="false" type="string" default="">		<!--- ************************************************************* --->		<cfset controller.setNextRoute(argumentCollection=arguments)>	</cffunction>	<cffunction name="runEvent" 	access="private" returntype="void" hint="Facade" output="false">		<!--- ************************************************************* --->		<cfargument name="event" 			type="string" required="no" default="">		<cfargument name="prepostExempt" 	type="boolean" required="false" default="false" hint="If true, pre/post handlers will not be fired.">		<cfargument name="private" 		 	type="boolean" required="false" default="false" hint="Execute a private event or not, default is false"/>		<!--- ************************************************************* --->		<cfset controller.runEvent(argumentCollection=arguments)>	</cffunction>		<!--- Flash Perist variables. --->	<cffunction name="persistVariables" access="private" returntype="void" hint="Persist variables for flash redirections" output="false" >		<!--- ************************************************************* --->		<cfargument name="persist" 	hint="What request collection keys to persist in the relocation" required="false" type="string" default="">		<!--- ************************************************************* --->		<cfset controller.persistVariables(argumentCollection=arguments)>	</cffunction>		<!--- Debug Mode Facades --->	<cffunction name="getDebugMode" access="private" hint="Facade to get your current debug mode" returntype="boolean"  output="false">		<cfreturn controller.getDebuggerService().getDebugMode()>	</cffunction>	<cffunction name="setDebugMode" access="private" hint="Facade to set your debug mode" returntype="void"  output="false">		<cfargument name="mode" type="boolean" required="true" >		<cfset controller.getDebuggerService().setDebugMode(arguments.mode)>	</cffunction>		<!--- Controller Accessor/Mutators --->	<cffunction name="getcontroller" access="private" output="false" returntype="any" hint="Get controller: coldbox.system.controller">
		<cfreturn variables.controller/>
	</cffunction>
	<cffunction name="setcontroller" access="private" output="false" returntype="void" hint="Set controller">
		<cfargument name="controller" type="any" required="true" hint="coldbox.system.controller"/>
		<cfset variables.controller = arguments.controller/>
	</cffunction><!------------------------------------------- UTILITY METHODS ------------------------------------------->		<!--- cfhtml head facade --->	<cffunction name="htmlhead" access="public" returntype="void" hint="Facade to cfhtmlhead" output="false" >		<!--- ************************************************************* --->		<cfargument name="content" required="true" type="string" hint="The content to send to the head">		<!--- ************************************************************* --->		<cfhtmlhead text="#arguments.content#">		
	</cffunction>		<!--- Include UDF --->	<cffunction name="includeUDF" access="private" hint="Injects a UDF Library into the handler." output="false" returntype="void">		<!--- ************************************************************* --->		<cfargument name="udflibrary" required="true" type="string" hint="The UDF library to inject.">		<!--- ************************************************************* --->		<cfset var UDFFullPath = ExpandPath(arguments.udflibrary)>		<cfset var UDFRelativePath = ExpandPath("/" & getController().getSetting("AppMapping") & "/" & arguments.udflibrary)>				<!--- check if UDFLibraryFile is defined  --->		<cfif arguments.udflibrary neq "">			<!--- Check if file exists on declared relative --->			<cfif fileExists(UDFRelativePath)>				<cfinclude template="/#getController().getSetting("appMapping")#/#arguments.udflibrary#">			<cfelseif fileExists(UDFFullPath)>				<cfinclude template="#arguments.udflibrary#">						<cfelse>				<cfthrow type="Framework.eventhandler.UDFLibraryNotFoundException" 				         message="Error loading UDFLibraryFile. The UDF library was not found in your application's include directory or in the location you specified: <strong>#UDFFullPath#</strong>. Please make sure you verify the file's location.">			</cfif>		</cfif>	</cffunction>		<!--- CFLOCATION Facade --->	<cffunction name="relocate" access="private" hint="Facade for cflocation" returntype="void">		<cfargument name="url" 		required="true" 	type="string">		<cfargument name="addtoken" required="false" 	type="boolean" default="false">		<cflocation url="#arguments.url#" addtoken="#addtoken#">	</cffunction>		<!--- Throw Facade --->	<cffunction name="throw" access="private" hint="Facade for cfthrow" output="false">		<!--- ************************************************************* --->		<cfargument name="message" 	type="string" 	required="yes">		<cfargument name="detail" 	type="string" 	required="no" default="">		<cfargument name="type"  	type="string" 	required="no" default="Framework">		<!--- ************************************************************* --->		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">	</cffunction>		<!--- Dump facade --->	<cffunction name="dump" access="private" hint="Facade for cfmx dump" returntype="void">		<cfargument name="var" required="yes" type="any">		<cfdump var="#var#">	</cffunction>		<!--- Abort Facade --->	<cffunction name="abort" access="private" hint="Facade for cfabort" returntype="void" output="false">		<cfabort>	</cffunction>		<!--- Include Facade --->	<cffunction name="include" access="private" hint="Facade for cfinclude" returntype="void" output="false">		<cfargument name="template" type="string">		<cfinclude template="#template#">	</cffunction></cfcomponent>