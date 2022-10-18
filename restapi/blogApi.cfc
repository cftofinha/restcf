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
	
	<cffunction name="salvarRegistro" restpath="salvar-post" access="remote" returntype="struct" httpmethod="POST" produces="application/json">
		<cfargument name="structForm" type="any" required="true">
		
		<cfset var response = {} />
		<cfset response = objBlog.salvarRegistro(arguments.structForm) />
		
		<cfreturn response>
		
	</cffunction>
	
	
</cfcomponent>
