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
	
	<!--- Detalhes do Usuario --->
	<cffunction name="userDetails" access="public" output="false" hint="Get user details" returntype="struct">
		<cfargument name="userid" required="true" type="numeric" />
		
		<cfset var resObj = {}>
		<cfset returnArray = ArrayNew(1) />
		
		<cfquery name="getuser" datasource="#application.datasource#">
			select userid,
				firstname,
				lastname,
				email,
				username,
				password,
				salt,
				DATE_FORMAT(lastlogin,'%d/%m/%Y %H:%i:%s') as lastlogin
			from users
			where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
		</cfquery>
		
		<cfif getuser.recordcount eq 0>
			<cfset resObj["success"] = false>
			<cfset resObj["message"] = "ID do Usuário não encontrado.">
		<cfelse>
			<cfloop query="getuser">
				<cfset userStruct = StructNew() />
				<cfset userStruct["id"] = userid />
				<cfset userStruct["firstname"] = firstname />
				<cfset userStruct["lastname"] = lastname />
				<cfset userStruct["email"] = email />
				<cfset userStruct["lastlogin"] = lastlogin />
				<cfset ArrayAppend(returnArray,userStruct) />
			</cfloop>
			
			<cfset resObj["success"] = true>
			<cfset resObj["data"] = SerializeJSON(returnArray)>
		</cfif>
		
		<cfreturn resObj>
	</cffunction>
	
	<!--- Atualização dos dados do Usuário --->
	<cffunction name="updateUser" access="public" output="false" hint="Update user details" returntype="struct">
		<cfargument name="userid" required="true" type="numeric" />
		<cfargument name="structform" required="true" type="any" />
		
		<cfset var resObj = {}>
		
		<cfquery name="validuser" datasource="#application.datasource#">
			select userid
			from users
			where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
		</cfquery>
		
		<cfif validuser.recordcount eq 1>
			<cftry>
				<cfquery name="updateuser" datasource="#application.datasource#">
					update users set 
						firstname = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#structform.firstname#">,
						lastname = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#structform.lastname#">,
						email = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="255" value="#structform.email#">
					where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
				</cfquery>
		
				<cfset resObj["success"] = true>
				<cfset resObj["message"] = "Detalhes do usuário atualziado com sucesso.">
				
				<cfcatch type="any">
					<cfset resObj["success"] = false>
					<cfset resObj["message"] = "Problema ao executar database query " & #cfcatch["message"]#>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset resObj["success"] = false>
			<cfset resObj["message"] = "ID do Usuário não encontrado.">
		</cfif>
		
		<cfreturn resObj>
		
	</cffunction>
	
	<!--- Atualizando a senha do Usuário --->
	<cffunction name="updatePassword" access="public" output="false" hint="Update user password" returntype="struct">	
		<cfargument name="userid" required="true" type="numeric" />
		<cfargument name="structform" required="true" type="any" />
		
		<cfset var resObj = {}>
		
		<cfquery name="pwduser" datasource="#application.datasource#">
			select userid,
				password,
				salt
			from users
			where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
		</cfquery>
		
		<cfif pwduser.recordcount eq 1>
			<cfif Hash(pwduser.salt & structform.oldpassword, 'SHA-256', 'UTF-8') eq pwduser.password>
				<cftry>
					<cfset hashpwd = Hash(pwduser.salt & structform.password, 'SHA-256', 'UTF-8')>
					
					<cfquery name="updatepwd" datasource="#application.datasource#">
						update users set 
							password = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="255" value="#hashpwd#">
						where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
					</cfquery>
					
					<cfset resObj["success"] = true>
					<cfset resObj["message"] = "Password updated successfully.">
					
					<cfcatch type="any">
						<cfset resObj["success"] = false>
						<cfset resObj["message"] = "Problem executing database query " & #cfcatch["message"]#>
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset resObj["success"] = false>
				<cfset resObj["message"] = "Incorrect old password.">
			</cfif>
		<cfelse>
			<cfset resObj["success"] = false>
			<cfset resObj["message"] = "Incorrect user id provided.">
		</cfif>
		
		<cfreturn resObj>
		
	</cffunction>
	
</cfcomponent>