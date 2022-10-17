<cfcomponent displayname="PostBlog">
	
	<cffunction name="getListaPosts" output="false" access="public" returntype="struct">
		
		<cfset var resObj = {} />
		<cfset returnArray = ArrayNew(1) />
		
		<cfquery name="qPosts" datasource="#application.datasource#">
			select a.blogpostid as id
				, (select c.name from blogCategory c, blogpostcategory rl 
					where c.blogcategoryid = rl.categoryid and rl.postid = a.blogpostid limit 1)
					 as nomeCategoria
				, (select c.blogcategoryid from blogCategory c, blogpostcategory rl 
					where c.blogcategoryid = rl.categoryid and rl.postid = a.blogpostid limit 1)
					 as idCategoria
				, a.title as titulo
				, a.summary as resumo
				, a.body as conteudo
				, to_char(a.dateposted, 'DD/MM/YYYY') as dataPostagem
				, to_char(a.createdDateTime, 'DD/MM/YYYY HH12:MI:SS') as dataHoraSistema
			, (select count(*) from BlogComment bc where a.blogpostid = bc.blogpostid) as qtdComentarios
			from blogPost a
			where a.deleted = '0'
			order by a.dateposted desc
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
		<cfset resObj["qtdRegistros"] = qPosts.recordCount>
		<cfset resObj["data"] = returnArray>
		
		<cfreturn resObj>
		
	</cffunction>
	
	<cffunction name="getDetalharRegistro" output="false" access="public" returntype="struct">
		<cfargument name="blogpostid" type="numeric" required="true">
		
		<cfset var resObj = {} />
		<cfset returnArray = ArrayNew(1) />
		
		<cfquery name="qPosts" datasource="#application.datasource#">
			select a.blogpostid as id
				, (select c.name from blogCategory c, blogpostcategory rl 
					where c.blogcategoryid = rl.categoryid and rl.postid = a.blogpostid limit 1)
					 as nomeCategoria
				, (select c.blogcategoryid from blogCategory c, blogpostcategory rl 
					where c.blogcategoryid = rl.categoryid and rl.postid = a.blogpostid limit 1)
					 as idCategoria
				, a.title as titulo
				, a.summary as resumo
				, a.body as conteudo
				, to_char(a.dateposted, 'DD/MM/YYYY') as dataPostagem
				, to_char(a.createdDateTime, 'DD/MM/YYYY HH12:MI:SS') as dataHoraSistema
			, (select count(*) from BlogComment bc where a.blogpostid = bc.blogpostid) as qtdComentarios
			from blogPost a
			where a.deleted = '0'
			and a.blogpostid = <cfqueryparam value="#arguments.blogpostid#" cfsqltype="cf_sql_integer" maxlength="4">
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
		<cfif !qPosts.recordCount>
			<cfset resObj["success"] = false>
		<cfelse>
			<cfset resObj["success"] = true>
			<cfset resObj["data"] = returnArray>
		</cfif>
		<cfset resObj["qtdRegistros"] = qPosts.recordCount>
		
		<cfreturn resObj>
		
	</cffunction>
	
</cfcomponent>
