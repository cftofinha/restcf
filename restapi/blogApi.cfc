<cfcomponent rest="true" restpath="blog">

	<cfobject name="objBlog" component="cfc.PostBlog">
	<cfobject name="objCategoria" component="cfc.Categorias">
	
	<cffunction name="getListaPosts" restpath="listagem-de-posts" access="remote" returntype="struct" httpmethod="GET" produces="application/json">
		
		<cfset var reponse = {} />
		
		<cfset response = objBlog.getListaPosts() />
		
		<cfreturn response>
		
	</cffunction>
	
	<cffunction name="getDetalharPost" restpath="detalhar-post/{id}" access="remote" returntype="struct" httpmethod="GET" produces="application/json">
		<cfargument name="id" type="any" required="true" restargsource="path">
		
		<cfset var response = {} />
		
		<cfset response = objBlog.getDetalharPost(arguments.id)>
		
		<cfreturn response> 
	</cffunction>
	
	
	<cffunction name="salvarPost" restpath="salvar-post" access="remote" returntype="struct" httpmethod="post" produces="application/json">
		<cfargument name="structform" type="any" required="true" >
		<cfset var reponse = {} />
		
		<cfset response = objBlog.salvarPost(arguments.structform) />
		
		<cfreturn response>
		
	</cffunction>
	
	<cffunction name="getListaCategorias" restpath="listagem-de-categorias" access="remote" returntype="struct" httpmethod="GET" produces="application/json">
		
		<cfset var reponse = {} />
		
		<cfset response = objCategoria.getListaCategorias() />
		
		<cfreturn response>
		
	</cffunction>
	
</cfcomponent>