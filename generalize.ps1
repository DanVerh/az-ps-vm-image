Remove-Item -Path C:\Windows\Panther -Recurse -Force -Confirm:$false
C:\Windows\system32\sysprep\sysprep.exe /oobe /generalize /mode:vm /shutdown