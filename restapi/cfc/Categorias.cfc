<cfcomponent displayname="Categorias">
	
	<cffunction name="getListaCategorias" output="false" access="public" returntype="struct">
		
		<cfset var resObj = {} />
		<cfset returnArray = ArrayNew(1) />
		
		<cfquery name="qCons" datasource="#application.datasource#">
			select c.blogCategoryid as id
				, c.name as nomeCategoria
				, c.imagem
				, c.css
			from blogCategory c
		</cfquery>
		
		<cfloop query="qCons">
			<cfscript>
				structCategorias = structNew();
				structCategorias["id"] = id;
				structCategorias["categoria"] = nomeCategoria;
				structCategorias["imagem"] = imagem;
				structCategorias["css"] = css;
				arrayAppend(returnArray, structCategorias);
			</cfscript>
			
		</cfloop>
		<cfset resObj["success"] = true>
		<cfset resObj["data"] = returnArray>
		
		<cfreturn resObj>
		
	</cffunction>
	
</cfcomponent>
