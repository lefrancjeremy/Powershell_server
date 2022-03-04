Function New-SimpleHTTPListener { 
 # Port en écoute paramétrable  
 Param ( 
   [Parameter()] [Int] $Port = 8000 
 ) 
 # Par défaut en écoute sur localhost  
 Begin{ 
   $listener = New-Object System.Net.HttpListener 
   $prefix = "http://localhost:$Port/" 
   $listener.Prefixes.Add($prefix) 
 } 
 
 Process{ 
 
   try{ 
     # Démarrer le serveur 
     $listener.Start() 
     $pwd = Get-Location 
      
     # Attendre les connexions 
    while ($listener.IsListening) { 
       $context = $listener.GetContext() 
 
       # Terminer le serveur si l'URL demandée est '/quit' 
       if ($context.Request.HttpMethod -eq 'GET' -and  
$context.Request.RawUrl -eq '/quit') { 
           $listener.Close() 
           break; 
       }     
 
       # Préparer la réponse 
       $HTTPresponse = $context.Response 
       $HTTPresponse.StatusCode = "200" 
       $HTTPResponse.Headers.Add("Content-Type","text/text")  
 
       # Lire le fichier demandé par l'URL 
       $RequestUrl = $context.Request.Url.OriginalString 
       $data = [System.Text.UTF8Encoding]::UTF8.GetBytes
([System.IO.File]::ReadAllText(Join-Path "$pwd" ($RequestUrl.
Split('/')[-1]))) 
 
       # Renvoyer le contenu du fichier en réponse 
       $HTTPresponse.ContentLength64 = $data.Length 
       $output = $HTTPresponse.OutputStream 
       $output.Write($data,0,$data.Length) 
 
       # Fermer la connexion 
       $output.Close()  
     } 
   }catch{ 
      Write-Host "erreur : $_"  
   }Finally{ 
     Write-Host "Fin d'éxécution : $_"  
     $listener.Stop() 
   } 
 } 
 
 End{ 
    
 } 
} 
#Vous pouvez lancer ce serveur web en appelant la fonction :

#> New-SimpleHTTPListener 
#Et en téléchargeant un fichier pour valider le fonctionnement :

#> (Invoke-WebRequest -Uri http://localhost:8000/.bashrc).Content 