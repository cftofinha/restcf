<cfcomponent displayname="PostBlog">
	
	<cffunction name="getListaPosts" output="false" access="public" returntype="struct">
		
		<cfset var resObj = {} />
		<cfset returnArray = ArrayNew(1) />
		
		<cfquery name="qPosts" datasource="#application.datasource#">
			select a.blogpostid as id
					, a.idUsuario
					, a.idCategoria
					, c.name as nomeCategoria
					, a.title as titulo
					, a.summary as resumo
					, a.body as conteudo
					, DATE_FORMAT(a.dateposted,'%d/%m/%Y') as dataPostagem
					, TIME_FORMAT(a.dateposted, '%T') AS horaPostagem
					, DATE_FORMAT(a.createdDateTime,'%d/%m/%Y %H:%i:%s') as dataHoraSistema
					, (select count(*) from BlogComment bc where a.blogpostid = bc.blogpostid) as qtdComentarios
			 from blogPost a
			 inner join blogCategory c on c.blogCategoryid = a.idCategoria
		</cfquery>
		
		<cfloop query="qPosts">
			<cfscript>
				structPosts = structNew();
				structPosts["id"] = id;
				structPosts["categoria"] = nomeCategoria;
				structPosts["titulo"] = titulo;
				structPosts["dataPostagem"] = dataPostagem;
				structPosts["qtdComentarios"] = qtdComentarios;
				arrayAppend(returnArray, structPosts);
			</cfscript>
			
		</cfloop>
		<cfset resObj["success"] = true>
		<cfset resObj["data"] = returnArray>
		
		<cfreturn resObj>
		
	</cffunction>
	
	<cffunction name="getDetalharPost" output="false" access="public" returntype="struct">
		<cfargument name="blogpostid" type="numeric" required="true">
		
		<cfset var resObj = {} />
		<cfset returnArray = ArrayNew(1) />
		
		<cfquery name="qPosts" datasource="#application.datasource#">
			select a.blogpostid as id
					, a.idUsuario
					, a.idCategoria
					, c.name as nomeCategoria
					, a.title as titulo
					, a.summary as resumo
					, a.body as conteudo
					, DATE_FORMAT(a.dateposted,'%d/%m/%Y') as dataPostagem
					, TIME_FORMAT(a.dateposted, '%T') AS horaPostagem
					, DATE_FORMAT(a.createdDateTime,'%d/%m/%Y %H:%i:%s') as dataHoraSistema
					, (select count(*) from BlogComment bc where a.blogpostid = bc.blogpostid) as qtdComentarios
			 from blogPost a
			 inner join blogCategory c on c.blogCategoryid = a.idCategoria
			 where blogpostid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.blogpostid#" maxlength="4">
		</cfquery>
		
		<cfloop query="qPosts">
			<cfscript>
				structPosts = structNew();
				structPosts["id"] = id;
				structPosts["categoria"] = nomeCategoria;
				structPosts["titulo"] = titulo;
				structPosts["dataPostagem"] = dataPostagem;
				structPosts["qtdComentarios"] = qtdComentarios;
				arrayAppend(returnArray, structPosts);
			</cfscript>
			
		</cfloop>
		<cfset resObj["success"] = true>
		<cfset resObj["data"] = returnArray>
		
		<cfreturn resObj>
		
	</cffunction>
	
	<cffunction name="salvarPost" output="false" access="public" returntype="struct">
		<cfargument name="structform" type="any" required="true">
		
		<cfset variables.dataPostagem = lsDateFormat(now(), 'yyyy-mm-dd') &" "& lsTimeFormat(now(), 'HH:mm:ss') />
		<cfset variables.dateposted = lsDateFormat(structform.dataPostagem, 'yyyy-mm-dd') &" "& lsTimeFormat(now(), 'HH:mm:ss') />
		
		<cfset var resObj = {} />
		
		<cfif not isDefined("structform.idPost")>
			<cftry>
				<cfquery datasource="#application.datasource#">
					insert into blogPost (
						idUsuario
						, idCategoria
						, title
						, summary
						, body
						, dateposted
						, createdDateTime
					)
					values(
						<cfqueryparam value="#structform.idUsuario#" cfsqltype="cf_sql_integer" maxlength="4">
						, <cfqueryparam value="#structform.idCategoria#" cfsqltype="cf_sql_integer" maxlength="4">
						, <cfqueryparam value="#structform.titulo#" cfsqltype="cf_sql_varchar" maxlength="70">
						, <cfqueryparam value="#structform.resumo#" cfsqltype="cf_sql_longvarchar">
						, <cfqueryparam value="#structform.conteudo#" cfsqltype="cf_sql_longvarchar">
						, <cfqueryparam value="#variables.dateposted#">
						, <cfqueryparam value="#variables.dataPostagem#">
					)
				</cfquery>
				<cfset resObj["success"] = true>
				<cfset resObj["data"] = "Post cadastrado com sucesso">
				
				<cfcatch type="any">
					<cfset resObj["success"] = false>
					<cfset resObj["data"] = "Erro ao cadastrar o novo Post" & #cfcatch["message"]#>
				</cfcatch>
			</cftry>
		<cfelse>
			<cftry>
				<cfquery datasource="#application.datasource#">
					update blogPost set 
						idUsuario = <cfqueryparam value="#structform.idUsuario#" cfsqltype="cf_sql_integer" maxlength="4">
						, idCategoria = <cfqueryparam value="#structform.idCategoria#" cfsqltype="cf_sql_integer" maxlength="4">
						, title = <cfqueryparam value="#structform.titulo#" cfsqltype="cf_sql_varchar" maxlength="70">
						, summary = <cfqueryparam value="#structform.resumo#" cfsqltype="cf_sql_longvarchar">
						, body = <cfqueryparam value="#structform.conteudo#" cfsqltype="cf_sql_longvarchar">
						, dateposted = <cfqueryparam value="#variables.dateposted#">
						, createdDateTime = <cfqueryparam value="#variables.dataPostagem#">
					where blogpostid = <cfqueryparam value="#structform.idPost#" cfsqltype="cf_sql_integer" maxlength="4">
				</cfquery>
				<cfset resObj["success"] = true>
				<cfset resObj["data"] = "Post atualizado com sucesso">
				
				<cfcatch type="any">
					<cfset resObj["success"] = false>
					<cfset resObj["data"] = "Erro ao atualizar o Post">
				</cfcatch>
			</cftry>
		</cfif>
		
		<cfreturn resObj>
		
	</cffunction>
		
</cfcomponent>
