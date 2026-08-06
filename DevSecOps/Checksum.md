# Checksum

```sh
# Download original file and checksum
curl.exe -LO "https://program.exe"
curl.exe -LO "https://program.exe.sha256"

# CMD
CertUtil -hashfile program.exe SHA256
type program.exe.sha256

# PowerShell
$(Get-FileHash -Algorithm SHA256 .\program.exe).Hash -eq $(Get-Content .\program.exe.sha256)

# Bash
echo "$(cat program.sha256) program" | sha256sum --check
```