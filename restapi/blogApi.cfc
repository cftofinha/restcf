<cfcomponent rest="true" restpath="blog">

	<cfobject name="objBlog" component="cfc.Blog">
	
	<!--- Function to validate token--->
	<cffunction name="authenticate" returntype="any">
		<cfset var response = {}>
		<cfset requestData = GetHttpRequestData()>
		<cfif StructKeyExists( requestData.Headers, "authorization" )>
			<cfset token = GetHttpRequestData().Headers.authorization>
			<cftry>
				<cfset jwt = new cfc.jwt(Application.jwtkey)>
				<cfset result = jwt.decode(token)>
				<cfset response["success"] = true>
				<cfcatch type="Any">
					<cfset response["success"] = false>
					<cfset response["message"] = cfcatch.message>
					<cfreturn response>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset response["success"] = false>
			<cfset response["message"] = "Token de Autorização inválido ou inexistente">
		</cfif>
		<cfreturn response>
	</cffunction>
	
	<cffunction name="getPosPorId" restpath="detalhar-post/{id}" access="remote" returntype="struct" httpmethod="GET" produces="application/json">
		<cfargument name="id" type="numeric" required="yes" restargsource="path"/>
		
		<cfset var response = {}>
		
		<cfset verify = authenticate()>
		<cfif not verify.success>
			<cfset response["success"] = false>
			<cfset response["message"] = verify.message>
			<cfset response["errcode"] = 'no-token'>
		<cfelse>
			<cfset response = objBlog.getPostPorId(arguments.id)>
		</cfif>
		<cfset response = objBlog.getPostPorId(arguments.id)>
		
		<cfreturn response>

	</cffunction>

</cfcomponent>