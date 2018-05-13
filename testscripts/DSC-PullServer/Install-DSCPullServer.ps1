param
    (
            [ValidateNotNullOrEmpty()]
            [string] $DNSName = "dsc.yourdomain.tld",

            [ValidateNotNullOrEmpty()]
            [string] $NodeName = "localhost"
     )

function CreateCertificate($_DNSName){
    $NewCert = New-SelfSignedCertificate -DnsName 9384df2b-21c1-4466-b49d-fc7c593b2041 -CertStoreLocation Cert:\LocalMachine\My
    return $NewCert
}

function CreateGUID {
    $NewGUID = New-Guid
    return $NewGUID.Guid
}

$Cert = CreateCertificate -_DNSName $DNSName
$GUID = CreateGUID
.\Install-xDscPullServer.ps1

Install-xDscPullServer -certificateThumbPrint $Cert.Thumbprint -RegistrationKey $GUID -NodeName $NodeName -OutputPath c:\Configs\PullServer 

Start-DscConfiguration -Path c:\Configs\PullServer -Wait -Verbose -Force