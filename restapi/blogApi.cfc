<cfcomponent rest="true" restpath="blog">
	<cfobject name="objBlog" component="cfc.PostBlog">
	
	<cffunction name="getListaPosts" restpath="listagem-de-posts" 
				access="remote" returntype="struct" httpmethod="GET" produces="application/json">
		<cfset var response = {} />
		
		<cfset response = objBlog.getListaPosts() />
		
		<cfreturn response>
		
	</cffunction>
	
	<cffunction name="getDetalharRegistro" restpath="detalhar-post/{id}" access="remote" returntype="struct"
				httpmethod="GET" produces="application/json">
				
		<cfargument name="id" type="any" required="true" restargsource="path"> 
		
		<cfset var response = {} />
		
		<cfset response = objBlog.getDetalharRegistro(arguments.id) />
		
		<cfreturn response>
		
	</cffunction>
	
</cfcomponent>
