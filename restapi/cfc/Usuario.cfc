<cfcomponent hint="Funções específicas do usuário" displayname="Usuario">
	
	<cffunction name="registerUser" access="public" output="false" hint="cadastrar usuário via API" returntype="boolean">
		<cfargument name="structform" required="true" type="any">
		
		<cfquery name="validUser" datasource="#application.datasource#">
			select username from users where username = <cfqueryparam value="#structform.username#" cfsqltype="cf_sql_varchar" maxlength="20">
		</cfquery>
		
		<cfif validUser.recordCount eq 1>
			<cfreturn false>
		<cfelse>
			<cfset variables.salt = "">
			<cfloop index="i" from="1" to="12">
				<cfset variables.salt = variables.salt & chr(RandRange(65,90))>
			</cfloop>
			
			<cfset variables.hashPwd = hash(variables.salt & structform.password, 'SHA-256', 'UTF-8')>
			<cfquery name="saverUser" datasource="#application.datasource#">
				insert into users (
					firstname
					,lastname
					,email
					,username
					,password
					,salt
				) values (
					<cfqueryparam value="#structform.firstname#" cfsqltype="cf_sql_varchar" maxlength="50">
					,<cfqueryparam value="#structform.lastname#" cfsqltype="cf_sql_varchar" maxlength="50">
					,<cfqueryparam value="#structform.email#" cfsqltype="cf_sql_varchar" maxlength="50">
					,<cfqueryparam value="#structform.username#" cfsqltype="cf_sql_varchar" maxlength="50">
					,<cfqueryparam value="#variables.hashPwd#" cfsqltype="cf_sql_varchar" maxlength="255">
					,<cfqueryparam value="#variables.salt#" cfsqltype="cf_sql_varchar" maxlength="15">
				)
			</cfquery>
			<cfreturn true>
		</cfif>
		
	</cffunction>
	
	<cffunction name="loginUser" access="public" output="false" hint="Login do usuário" returntype="struct">
		<cfargument name="structform" required="true" type="any">
		
		<cfset var resObj = {}>
		<cfquery name="loginUser" datasource="#application.datasource#">
			select userid
				,firstname
				,lastname
				,email
				,username
				,password
				,salt
				,DATE_FORMAT(lastlogin, '%d/%m/%Y %H:%i:%s') as lastlogin
			from users
			where username = <cfqueryparam value="#structform.username#" cfsqltype="cf_sql_varchar" maxlength="20">
		</cfquery>
		
		<cfif loginUser.recordCount eq 1 and not compareNocase(hash(loginUser.salt & structform.password, 'SHA-256', 'UTF-8'), loginuser.password)>
			<!--- atualizar data/hora do ultimo login dele --->
			<cfquery datasource="#application.datasource#">
				update users set 
					lastlogin = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
				where username = <cfqueryparam value="#structform.username#" cfsqltype="cf_sql_varchar" maxlength="20">
			</cfquery>
			
			<cfset expDt = dateAdd("n",30,now())>
			<cfset utcDate = dateDiff('s', dateConvert('utc2Local', createDateTime(1970, 1, 1, 0, 0, 0)), expDt)>
			<cfset jwt = new jwt(Application.jwtkey)>
			<cfset payload = {"ts" = now(), "userid" = loginUser.userid, "exp" = utcDate}>
			<cfset token = jwt.encode(payload)>
			
			<cfset resObj["success"] = true>
			<cfset resObj["data"] = {'userid': loginUser.userid, 'username': loginUser.username, 'firstname': loginUser.firstname, 'lastlogin': loginUser.lastlogin}>
			<cfset resObj["token"] = token>
		<cfelse>
		 	<cfset resObj["success"] = false>
			<cfset resObj["data"] = "Credenciais inváliadas para o login">
		</cfif>
		
		<cfreturn resObj>
		
	</cffunction>
	
	<cffunction name="userDetails" access="public" output="false" hint="Obter detalhes do usuário" returntype="struct">
		<cfargument name="userid" required="true" type="numeric">
		
		<cfset var resObj = {} />
		<cfset returnArray = ArrayNew(1) />
		
		<cfquery name="getUser" datasource="#application.datasource#">
			select userid
				,firstname
				,lastname
				,email
				,username
				,password
				,salt
				,DATE_FORMAT(lastlogin, '%d/%m/%Y %H:%i:%s') as lastlogin
			from users
			where userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" maxlength="4">
		</cfquery>
		
		<cfif getUser.recordCount eq 0>
			<cfset resObj["success"] = false>
			<cfset resObj["data"] = "Id do usuário não encontrado">
		<cfelse>
			<cfloop query="getUser">
				<cfset userStruct = structNew() />
				<cfset userStruct["id"] = userid />
				<cfset userStruct["firstname"] = firstname />
				<cfset userStruct["lastname"] = lastname />
				<cfset userStruct["email"] = email />
				<cfset userStruct["lastlogin"] = lastlogin />
				<cfset arrayAppend(returnArray, userStruct) />
			</cfloop>
			
			<cfset resObj["success"] = true>
			<!---<cfset resObj["data"] = serializeJson(returnArray)>--->
			<cfset resObj["data"] = returnArray>
			
		</cfif>
		
		<cfreturn resObj>
		
	</cffunction>
	
	<cffunction name="updateUser" access="public" hint="atualizar dados do usuário" output="false" returntype="struct">
		<cfargument name="userid" required="true" type="numeric">
		<cfargument name="structform" required="true" type="any">
		
		<cfset var resObj = {} />
		
		<cfquery name="validUser" datasource="#application.datasource#">
			select userid from users
			where userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" maxlength="4">
		</cfquery>
		
		<cfif validUser.recordCount eq 1>
			<cftry>
				<cfquery datasource="#application.datasource#">
					update users set 
						firstname = <cfqueryparam value="#structform.firstname#" cfsqltype="cf_sql_varchar" maxlength="50">
						,lastname = <cfqueryparam value="#structform.lastname#" cfsqltype="cf_sql_varchar" maxlength="50">
						,email = <cfqueryparam value="#structform.email#" cfsqltype="cf_sql_varchar" maxlength="50">
					where userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" maxlength="4">
				</cfquery>
				<cfset resObj["success"] = true />
				<cfset resObj["data"] = "Dados do Usuário atualizado com sucesso" />
				
				<cfcatch type="any">
					<cfset resObj["success"] = false />
					<cfset resObj["data"] = "Problema ao executar a atualização do usuário" & #cfcatch["message"]# />
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset resObj["success"] = false />
			<cfset resObj["data"] = "Usuário não encontrado com o ID informado" />
		</cfif>
		
		<cfreturn resObj>
	</cffunction>
	
	<cffunction name="updatePassword" access="public" hint="atualizar senha do usuário" output="false" returntype="struct">
		<cfargument name="userid" required="true" type="numeric">
		<cfargument name="structform" required="true" type="any">
		
		<cfset var resObj = {} />
		
		<cfquery name="validUser" datasource="#application.datasource#">
			select 
				userid, password, salt 
			from users
			where userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" maxlength="4">
		</cfquery>
		
		<cfif validUser.recordCount eq 1>
			<cfif not compareNocase(hash(validUser.salt & structform.senhaAntiga, 'SHA-256', 'UTF-8'), validUser.password)>
				<cftry>
					<cfset novaSenha = hash(validUser.salt & structform.senhaNova, 'SHA-256', 'UTF-8') />
					<cfquery datasource="#application.datasource#">
						update users set 
							password = <cfqueryparam value="#variables.novaSenha#" cfsqltype="cf_sql_varchar" maxlength="255">
						where userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" maxlength="4">
					</cfquery>
					<cfset resObj["success"] = true />
					<cfset resObj["data"] = "Senha do Usuário atualizada com sucesso" />
					
					<cfcatch type="any">
						<cfset resObj["success"] = false />
						<cfset resObj["data"] = "Problema ao executar a atualização da senha do usuário" & #cfcatch["message"]# />
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset resObj["success"] = false />
				<cfset resObj["data"] = "Senha informada não é compatível com a gravada em banco" />
			</cfif>
		<cfelse>
			<cfset resObj["success"] = false />
			<cfset resObj["data"] = "Usuário não encontrado com o ID informado" />
		</cfif> 
		
		<cfreturn resObj>
		
	</cffunction>
	
	<cffunction name="deleteUser" access="public" hint="excluir usuário" output="false" returntype="struct">
		<cfargument name="userid" required="true" type="numeric">
		
		<cfset var resObj = {} />
		
		<cfquery name="validUser" datasource="#application.datasource#">
			select userid
			where userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" maxlength="4">
		</cfquery>
		
		<cfif validUser.recordCount eq 1>
			<cftry>
				<cfquery datasource="#application.datasource#">
					delete from users
					where userid = <cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer" maxlength="4">
				</cfquery>
				<cfset resObj["success"] = true />
				<cfset resObj["data"] = "Usuário excluído com sucesso" />
				
				<cfcatch type="any">
					<cfset resObj["success"] = false />
					<cfset resObj["data"] = "Problema ao executar a exclusão do usuário" & #cfcatch["message"]# />
				</cfcatch>
				</cftry>
		<cfelse>
			<cfset resObj["success"] = false />
			<cfset resObj["data"] = "Usuário não encontrado com o ID informado" />
		</cfif> 
		
		<cfreturn resObj>
		
	</cffunction>
	
</cfcomponent>