# API Security Practice — 2025-12-08

Topic: Improper Assets Management & Mass Assignment

Today I practiced two critical API vulnerabilities that often lead to full account takeover and business logic abuse.

---

## Improper Assets Management

This happens when old, test, or internal API versions are left exposed.

Examples:
/api/v1
/api/v2
/api/test
/api/internal

Even if the latest version is secure, old versions may still be vulnerable.

### Real Attack Case

The OTP verification endpoint was protected in v3:
Rate limited

But in v2:
No rate limit

This allowed brute forcing the OTP and resetting the victim’s password.

Result:
Full account takeover

---

## Mass Assignment

Mass assignment happens when the API accepts extra parameters that users should not control.

### Example

Normal request:

```json
{
  "email": "user@test.com",
  "password": "123456"
}
```

Attacker adds:

```json
{
  "email": "user@test.com",
  "password": "123456",
  "isadmin": true
}
```

If the API accepts this, the attacker becomes an admin.

### Real Lab Result

I was able to:
Create my own store product
Set a negative price
Purchase it
Increase my balance instead of decreasing it

This confirms a full Mass Assignment vulnerability.

---

## Key Lessons

Never trust client-side parameters
Old API versions are dangerous
Always whitelist allowed fields
Reject unknown input

---

## Tools Used

Postman
Burp Suite
Param Miner
WFuzz
