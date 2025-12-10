# Injection Attacks & SSRF

Today I studied two important API attack classes: Injection vulnerabilities and SSRF.  
Using techniques like fuzzing, Burp Intruder, Postman Collection Runner, and webhook.site, I practiced how these issues appear and how to detect them in APIs.

--------------------------------------------------

## Injection Attacks

I learned how to detect weaknesses by **fuzzing inputs**, especially:
- Headers  
- Query parameters  
- POST/PUT bodies  
:contentReference[oaicite:2]{index=2}

Fuzz payloads included:
- Large numbers & strings  
- Negative numbers  
- Random characters  
- Meta characters  
- SQL / NoSQL operators  
- OS command separators  

### SQL Injection  
Learned how SQL metacharacters such as `'`, `"`, `--`, `%00`, and `OR 1=1` can break queries or bypass authentication.  
Reviewed how verbose SQL errors often reveal backend database details.  

### NoSQL Injection  
Using payloads like:  
{"$gt":""}
{"$ne":-1}
{"$where":"sleep(1000)"}

Attackers can manipulate MongoDB-style filters or trigger server delays.  
Practiced exploiting coupon validation via NoSQLi (Intruder + wfuzz).  
:contentReference[oaicite:3]{index=3}

### OS Command Injection  
Used separators like `|`, `||`, `&`, `&&`, `;`, `'`, `"` to chain system commands.  
Reviewed how knowing the OS helps (Linux: `ls`, `ifconfig`, `whoami` / Windows: `dir`, `ipconfig`).  
:contentReference[oaicite:4]{index=4}

--------------------------------------------------

## SSRF (Server-Side Request Forgery)

SSRF happens when applications fetch remote URLs without validating user input.  
I learned both types:  
- **In-Band SSRF** → server returns attacker-controlled content  
- **Blind SSRF** → server makes the request but gives no output back  
:contentReference[oaicite:5]{index=5}

### In-Band Example  
Modifying an inventory URL lets the server fetch sensitive data, e.g.:  
"inventory": "http://localhost/secrets"
and returns secrets like tokens.  

### Blind SSRF  
Used **webhook.site** to detect server requests.  
When the server hits my webhook URL → blind SSRF confirmed.  
Tested various URLs using Burp Intruder Pitchfork mode.  

### Practice  
- Enumerated endpoints handling URLs  
- Used webhook.site to confirm outbound requests  
- Successfully exploited SSRF in `contact_mechanic` request  
:contentReference[oaicite:6]{index=6}

--------------------------------------------------

## Tools Used

- Burp Suite (Proxy, Repeater, Intruder)  
- Postman Collection Runner  
- WFuzz  
- webhook.site  

--------------------------------------------------

## Key Takeaways

- Fuzz everything: params, headers, body  
- Injection issues often reveal themselves through verbose errors  
- NoSQLi payloads behave differently from SQLi  
- SSRF impact depends on what the internal server can reach  
- Always document anomalies: timing delays, error messages, unexpected responses

