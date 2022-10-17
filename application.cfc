component output="false" {
	this.name = "restcf";
	this.restsettings.cfclocation = "./";
	this.restsettings.skipcfcwitherror = true;
	this.datasource = "dbcursocf";
	
	setlocale("Portuguese (Brazilian)");
	setEncoding("URL", "UTF-8");
	setEncoding("FORM", "UTF-8");
	
	//Run when application starts up
	function onApplicationStart() returntype="boolean" {
		Application.jwtkey = "$3cR3!k@GH34";
		application.datasource = this.datasource;
		restInitApplication(getDirectoryFromPath(getCurrentTemplatePath()) & 'restapi', 'api');
		return true;
	}
	
	function onRequestStart(string targetPage) output="true" returnType="void" {
		if(structKeyExists(url, 'reload') && url.reload eq 2022){
			lock timeout="10" throwontimeout="No" type="Exclusive" scope="Application"{
				onApplicationStart();
			}
		}
	}

	//Run when application stops
	function onApplicationEnd() returnType="void" output="false"{
		
	}

	public void function onSessionStart() {
		
	}

	public void function onSessionEnd( struct sessionScope, struct appScope ) {
		
	}

	public boolean function onMissingTemplate( template ) {
		
	}
	
	function onError( any Exception, string EventName){
		writeDump(arguments.exception);
	}
}
