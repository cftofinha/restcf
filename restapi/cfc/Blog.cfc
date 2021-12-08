<cfcomponent displayname="Funcoes do blog" hint="Funcoes do blog" output="false">
	
	<!--- Detalhes do Post --->
	<cffunction name="getPostPorId" access="public" output="false" hint="Buscar um post pelo ID" returntype="struct">
		<cfargument name="blogpostid" required="true" type="numeric" />
	
		<cfset var resObj = {}>
		<cfset returnArray = ArrayNew(1) />
		
		<cftry>
			<cfquery name="qCons" datasource="#application.datasource#">
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
				where blogpostid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.blogpostid#">
			</cfquery>
		
			<cfif qCons.recordcount eq 0>
				<cfset resObj["success"] = false>
				<cfset resObj["message"] = "Id de Post inválido">
			<cfelse>
				<cfloop query="qCons">
					<cfset postStruct = structNew() />
					<cfset postStruct["blogpostid"] = blogpostid />
					<cfset postStruct["idUsuario"] = idUsuario />
					<cfset postStruct["nomeCategoria"] = nomeCategoria />
					<cfset postStruct["titulo"] = titulo />
					<cfset postStruct["resumo"] = resumo />
					<cfset postStruct["conteudo"] = conteudo />
					<cfset postStruct["qtdComentarios"] = qtdComentarios />
					<cfset postStruct["dataPostagem"] = dataPostagem />
					<cfset postStruct["dataHoraSistema"] = dataHoraSistema />
					
					<cfset ArrayAppend(returnArray,postStruct) />
				</cfloop>
			
				<cfset resObj["success"] = true>
				<cfset resObj["data"] = SerializeJSON(returnArray)>
			</cfif>
			
			<cfcatch type="any">
				<cfset resObj["success"] = false>
				<cfset resObj["message"] = "Problema na execução da query do banco " & #cfcatch["message"]#>
			</cfcatch>
		</cftry>
			
		<cfreturn resObj>
	</cffunction>
	
</cfcomponent>