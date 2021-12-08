<cfcomponent rest="true" restpath="usuario">

	<cfobject name="objUser" component="cfc.Usuario">
	
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
	
	<!--- cadastrar usuario --->
	<cffunction name="signup" restpath="cadastrar" access="remote" returntype="struct" httpmethod="POST" produces="application/json">
		<cfargument name="structform" type="any" required="true">
		
		<cfset var response = {} />
		<cfset bolSignup = objUser.registerUser(structform)>
		<cfif bolSignup>
			<cfset response["success"] = true />
			<cfset response["message"] = "Usuário criado com sucesso" />
		<cfelse>
			<cfset response["success"] = false />
			<cfset response["message"] = "Usuário existente. Utilize outro username para cadastro" />
		</cfif>
		
		<cfreturn response>
		
	</cffunction>
	
	<cffunction name="login" restpath="login" access="remote" returntype="struct" httpmethod="POST" produces="application/json">
		<cfargument name="structform" type="any" required="true">
		
		<cfset var response = {} />
		<cfset response = objUser.loginUser(structform)>
		
		<cfreturn response>
		
	</cffunction>
	
	<!--- Detalhes do usuário --->
	<cffunction name="getuser" restpath="detalhes/{id}" access="remote" returntype="struct" httpmethod="GET" produces="application/json">
		<cfargument name="id" type="any" required="yes" restargsource="path"/>
		<cfset var response = {}>
		
		<cfset verify = authenticate()>
		<cfif not verify.success>
			<cfset response["success"] = false>
			<cfset response["message"] = verify.message>
			<cfset response["errcode"] = 'no-token'>
		<cfelse>
			<cfset response = objUser.userDetails(arguments.id)>
		</cfif>

		<cfreturn response>

	</cffunction>
	
	<cffunction name="putuser" restpath="atualizar-dados/{id}" access="remote" returntype="struct" httpmethod="PUT" produces="application/json">
		<cfargument name="id" type="any" required="yes" restargsource="path"/>
		<cfargument name="structform" type="any" required="yes">
		
		<cfset var response = {}>
		
		<cfset verify = authenticate()>
		<cfif not verify.success>
			<cfset response["success"] = false>
			<cfset response["message"] = verify.message>
			<cfset response["errcode"] = 'no-token'>
		<cfelse>
			<cfset response = objUser.updateUser(arguments.id, arguments.structform)>
		</cfif>
		
		<cfreturn response>

	</cffunction>
	
	<cffunction name="password" restpath="atualizar-senha/{id}" access="remote" returntype="struct" httpmethod="PUT" produces="application/json">
		<cfargument name="id" type="numeric" required="yes" restargsource="path"/>
		<cfargument name="structform" type="any" required="yes">
		
		<cfset var response = {}>
		
		<cfset verify = authenticate()>
		<cfif not verify.success>
			<cfset response["success"] = false>
			<cfset response["message"] = verify.message>
			<cfset response["errcode"] = 'no-token'>
		<cfelse>
			<cfset response = objUser.updatePassword(arguments.id, arguments.structform)>
		</cfif>
		
		<cfreturn response>
		
	</cffunction>
	

</cfcomponent>