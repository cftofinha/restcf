<cfscript>
	param name="url.username" default="tofinha";
	param name="url.senha" default="cf123@";
	
	variables.structform = {};
	
	variables.structform['username'] = "tofinha";
	variables.structform['password'] = "cf123@";
	
	variables.structform = serializeJSON(variables.structform)
	
	writeDump(variables.structform);
</cfscript>
<!doctype html>
<html lang="en">
<head>
	<!-- Required meta tags -->
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

	<title>Testes simples</title>

	<!---css --->
	<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
	<script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
</head>
<body data-spy="scroll" data-target=".navbar" data-offset="50" style="padding-top: 60px">
	<!---Top NavBar --->
	<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top" role="navigation">
		
	</nav>

	<!---Container And Views --->
	<div class="container">
		<cfhttp url="http://localhost:8500/rest/api/usuario/login" method="post" result="httpResposta" timeout="60">
			<cfhttpparam type="header" name="Content-Type" value="application/json">
			<cfhttpparam type="body" value="#variables.structform#">
		</cfhttp>
		<cfdump var="#httpResposta#">
		
		<br><hr><br>
		<p>Clique aqui para chamar o login</p>
	</div>

	<footer class="border-top py-3 mt-5">
		<div class="container"></div>
	</footer>

	<!---js --->
	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
	<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>
	
	<script>
		jQuery(document).ready(function(){
			
			$("p").click(function(){
				//var jsonObj = '{"password":"cf123@","username":"tofinha"}';
				var jsonObj = '{"username": "senac221", "firstname": "SENAC","lastname": "de São Paulo","password": "cf123@", "email": "senac@senac.com"}';
				
				$.ajax({
					url: 'http://localhost:8500/rest/api/usuario/cadastrar',
					type:'post',
					data: JSON.stringify($.parseJSON(jsonObj)),
					dataType: 'json',
					contentType: "application/json",
					success: function (response){
						console.log(response);
						//console.log("Nome do usuario ==> " + response.data.firstname);
					}
				});
			});
			
		});
	</script>
</body>
</html>

