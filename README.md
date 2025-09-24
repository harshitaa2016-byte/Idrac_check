# iDRAC / Redfish Batch Power & Reboot Script

This PowerShell script automates power and iDRAC reboot operations across multiple server sites using the Redfish API interface. It reads site IDs, constructs FQDNs, checks power state, powers on hosts as needed, and issues graceful iDRAC reboots.

---

## 🔧 Features

- Forces TLS 1.2 / 1.3 for secure REST calls  
- Ignores SSL certificate validation (for testing environments)  
- Reads site IDs from a text file  
- Builds FQDN for each site to call Redfish endpoints  
- Checks the power state and powers on systems if offline  
- Issues graceful iDRAC reboot command  
- Handles errors gracefully per site and continues processing  

---

## 🧰 Prerequisites

- PowerShell 5.1+ or PowerShell Core  
- Credentials with privileges to access Redfish APIs on the target servers  
- Network connectivity to the iDRAC / Redfish ports (typically 443)  
- A list of site IDs, e.g., `sites.txt`

---

## 📦 Setup Instructions

1. **Update your credentials**  
   Modify the script to supply or prompt for the correct username/password or credential file rather than hardcoding.  
   
2. **Domain suffix**  
   Ensure your `$domainSuffix` matches your environment (for example: `-xr-bmc001.paas.prod.corp.dish-wireless.net`).

3. **Prepare `sites.txt`**  
   Create a text file listing each site ID on a new line.  
   E.g.:
xyc005a
abc006a

yaml
Copy code

4. **Place script & input file**  
Save the script and `sites.txt` in an appropriate folder. Update the `$siteFile` path if needed.

---

## ▶️ Usage

Open PowerShell (can run as non-admin unless restricted) and run:

```powershell
.\idrac_batch.ps1
