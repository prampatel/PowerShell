$awscredentials = Get-Content "C:\Users\ppatel\.aws\credentials"

Add-Content .\AWSInstances.csv 'Role,Name,InstanceId,PrivateIpAddress,PublicIpAddress,PrivateDnsName,PublicDnsName'

foreach ($line in $awscredentials) {
    if ($line.StartsWith('[')) {
        $awsrole = $line.Replace("[", "").Replace("]", "")
        $awsroles += $awsrole + "`r`n"

        $instances = aws ec2 describe-instances `
            --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],InstanceId,PrivateIpAddress,PublicIpAddress,PrivateDnsName,PublicDnsName]' `
            --output json `
            --profile $awsrole | ConvertFrom-Json

        for ($i = 0; $i -le $instances.Count - 1; $i++) {
            $current = $instances[$i] -split ' '
            $InstanceName = $current[0]
            $InstanceId = $current[1]
            $PrivateIp = $current[2]
            $PublicIp = $current[3]
            $PrivateDns = $current[4]
            $PublicDns = $current[5]

            Add-Content .\AWSInstances.csv "$awsrole,$InstanceName,$InstanceId,$PrivateIp,$PublicIp,$PrivateDns,$PublicDns"

            Clear-Variable current, InstanceName, InstanceId, PrivateIp, PublicIp, PrivateDns, PublicDns
        }
    }
}