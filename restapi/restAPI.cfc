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
	
	<!--- detalhes do usuário --->
	<cffunction name="getUser" restpath="detalhes/{id}" access="remote" returntype="struct" httpmethod="GET" produces="application/json">
		<cfargument name="id" type="any" required="true" restargsource="path">
		
		<cfset var response = {} />
		
		<cfset response = objUser.userDetails(arguments.id)>
		
		<cfreturn response> 
	</cffunction>
	
	<!--- update dos dados do usuario --->
	<cffunction name="putUser" restpath="atualizar-dados/{id}" access="remote" returntype="struct" httpmethod="PUT" produces="application/json">
		<cfargument name="id" type="any" required="true" restargsource="path">
		<cfargument name="structform" type="any" required="true"> 
		
		<cfset var response = {} />
		
		<cfset response = objUser.updateUser(arguments.id, arguments.structform)>
		
		<cfreturn response> 
	</cffunction>

	<cffunction name="putPassword" restpath="atualizar-senha/{id}" access="remote" returntype="struct" httpmethod="PUT" produces="application/json">
		<cfargument name="id" type="any" required="true" restargsource="path">
		<cfargument name="structform" type="any" requirexcluir-usuarioed="true"> 
		
		<cfset var response = {} />
		
		<cfset response = objUser.updatePassword(arguments.id, arguments.structform)>
		
		<cfreturn response> 
	</cffunction>
	
	<cffunction name="delUser" restpath="excluir-usuario/{id}" access="remote" returntype="struct" httpmethod="DELETE" produces="application/json">
		<cfargument name="id" type="any" required="true" restargsource="path">
		
		<cfset var response = {} />
		
		<cfset response = objUser.deleteUser(arguments.id)>
		
		<cfreturn response> 
	</cffunction>
	
</cfcomponent>