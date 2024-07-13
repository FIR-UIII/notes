New-ADOrganizationalUnit -Name Accounts
New-ADOrganizationalUnit -Name VIP -path 'OU=Accounts,dc=lab,DC=local'
New-ADOrganizationalUnit -Name Sysadmins -path 'OU=Accounts,dc=lab,DC=local'
New-ADOrganizationalUnit -Name Progr -path 'OU=Accounts,dc=lab,DC=local'
New-ADOrganizationalUnit -Name Buhg -path 'OU=Accounts,dc=lab,DC=local'
New-ADOrganizationalUnit -Name HR -path 'OU=Accounts,dc=lab,DC=local'

New-ADUser -Name "Alex" -GivenName "Alex" -UserPrincipalName "Alex@lab.local" -path 'OU=VIP,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString A-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Gleb" -GivenName "Gleb" -UserPrincipalName "Gleb@lab.local" -path 'OU=Progr,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString G-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Petr" -GivenName "Petr" -UserPrincipalName "Petr@lab.local" -path 'OU=Sysadmins,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString P-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Anton" -GivenName "Anton" -UserPrincipalName "Anton@lab.local" -path 'OU=Buhg,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString A-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Igor" -GivenName "Igor" -UserPrincipalName "Igor@lab.local" -path 'OU=Sysadmins,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString I-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Vasya" -GivenName "Vasya" -UserPrincipalName "Vasya@lab.local" -path 'OU=Progr,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString V-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Pavel" -GivenName "Pavel" -UserPrincipalName "Pavel@lab.local" -path 'OU=Progr,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString P-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Boris" -GivenName "Boris" -UserPrincipalName "Boris@lab.local" -path 'OU=Progr,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString B-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Lida" -GivenName "Lida" -UserPrincipalName "Lida@lab.local" -path 'OU=Buhg,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString L-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Sveta" -GivenName "Sveta" -UserPrincipalName "Sveta@lab.local" -path 'OU=VIP,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString S-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Nata" -GivenName "Nata" -UserPrincipalName "Nata@lab.local" -path 'OU=HR,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString N-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Yana" -GivenName "Yana" -UserPrincipalName "Yana@lab.local" -path 'OU=Buhg,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString Y-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Maria" -GivenName "Maria" -UserPrincipalName "Maria@lab.local" -path 'OU=HR,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString M-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Ada" -GivenName "Ada" -UserPrincipalName "Ada@lab.local" -path 'OU=Progr,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString A-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Roza" -GivenName "Roza" -UserPrincipalName "Roza@lab.local" -path 'OU=Buhg,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString R-Qq123456 -AsPlainText -force) -Enabled $true

New-ADUser -Name "Olga" -GivenName "Olga" -UserPrincipalName "Olga@lab.local" -path 'OU=HR,OU=Accounts,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString O-Qq123456 -AsPlainText -force) -Enabled $true


New-ADGroup "VIP" -path 'OU=VIP,OU=Accounts,dc=lab,DC=local' -GroupCategory Distribution -GroupScope Global -PassThru –Verbose
New-ADGroup "VIP-sec" -path 'OU=VIP,OU=Accounts,dc=lab,DC=local' -GroupCategory Security -GroupScope Global -PassThru –Verbose

Add-ADGroupMember -Identity VIP -Members Alex, Sveta, Petr, Ada, Maria, Anton
Add-ADGroupMember -Identity VIP-sec -Members Alex, Sveta

New-ADGroup "Sysadmins" -path 'OU=Sysadmins,OU=Accounts,dc=lab,DC=local' -GroupCategory Distribution -GroupScope Global -PassThru –Verbose
New-ADGroup "Sysadmins-sec" -path 'OU=Sysadmins,OU=Accounts,dc=lab,DC=local' -GroupCategory Security -GroupScope Global -PassThru –Verbose

Add-ADGroupMember -Identity Sysadmins -Members Petr, Igor
Add-ADGroupMember -Identity Sysadmins-sec -Members Petr, Igor

New-ADGroup "HR" -path 'OU=HR,OU=Accounts,dc=lab,DC=local' -GroupCategory Distribution -GroupScope Global -PassThru –Verbose
New-ADGroup "HR-sec" -path 'OU=HR,OU=Accounts,dc=lab,DC=local' -GroupCategory Security -GroupScope Global -PassThru –Verbose

Add-ADGroupMember -Identity HR -Members Nata, Maria, Olga
Add-ADGroupMember -Identity HR-sec -Members Nata, Maria, Olga

New-ADGroup "Buhg" -path 'OU=Buhg,OU=Accounts,dc=lab,DC=local' -GroupCategory Distribution -GroupScope Global -PassThru –Verbose
New-ADGroup "Buhg-sec" -path 'OU=Buhg,OU=Accounts,dc=lab,DC=local' -GroupCategory Security -GroupScope Global -PassThru –Verbose

Add-ADGroupMember -Identity Buhg -Members Roza, Yana, Lida, Anton
Add-ADGroupMember -Identity Buhg-sec -Members Roza, Yana, Lida, Anton

New-ADGroup "Progr" -path 'OU=Progr,OU=Accounts,dc=lab,DC=local' -GroupCategory Distribution -GroupScope Global -PassThru –Verbose
New-ADGroup "Progr-sec" -path 'OU=Progr,OU=Accounts,dc=lab,DC=local' -GroupCategory Security -GroupScope Global -PassThru –Verbose

Add-ADGroupMember -Identity Progr -Members Gleb, Vasya, Pavel, Boris, Ada
Add-ADGroupMember -Identity Progr-sec -Members Gleb, Vasya, Pavel, Boris, Ada



New-ADOrganizationalUnit -Name ADM
New-ADUser -Name "ADMPetr" -GivenName "ADMPetr" -UserPrincipalName "ADMPetr@lab.local" -path 'OU=ADM,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString Qq123456 -AsPlainText -force) -Enabled $true
New-ADUser -Name "ADMIgor" -GivenName "ADMIgor" -UserPrincipalName "ADMIgor@lab.local" -path 'OU=ADM,dc=lab,DC=local' -AccountPassword (ConvertTo-SecureString Qq123456 -AsPlainText -force) -Enabled $true

Add-ADGroupMember -Identity 'Domain Admins' -Members ADMPetr, ADMIgor