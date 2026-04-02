# Osusu API Documentation

**Base URL:** `http://localhost:3000` (development) | `https://prod-url.com` (production)

**API Version:** 1.0 | **Last Updated:** April 2, 2026

---

## Table of Contents
1. [Authentication](#authentication)
2. [Groups](#groups)
3. [Members](#members)
4. [Collections & Payouts](#collections--payouts)
5. [Reports & Status](#reports--status)
6. [Error Handling](#error-handling)
7. [Rate Limits](#rate-limits)

---

## Authentication

### Common Response Fields

```typescript
{
  user: { id: string, email: string, role: 'user' | 'admin' | 'superadmin' },
  token: string,           // JWT access token (2h expiry)
  refreshToken: string     // Refresh token (7d expiry)
}
```

### POST /auth/signup

Create a new user account.

**Request:**
```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePassword123!",
    "role": "user"
  }'
```

**Parameters:**
| Param | Type | Required | Notes |
|-------|------|----------|-------|
| `email` | string | ✓ | Valid email address, unique |
| `password` | string | ✓ | Minimum 8 characters |
| `role` | enum | ✗ | `user` (default), `admin`, `superadmin` |

**Response (201 Created):**
```json
{
  "user": {
    "id": "u_abc123def456",
    "email": "user@example.com",
    "role": "user"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses:**
- `400 Bad Request` - Invalid email/password format, password too short
- `409 Conflict` - Email already registered

**Rate Limit:** 5 requests per 5 minutes

---

### POST /auth/signin

Authenticate with existing credentials.

**Request:**
```bash
curl -X POST http://localhost:3000/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePassword123!"
  }'
```

**Parameters:**
| Param | Type | Required |
|-------|------|----------|
| `email` | string | ✓ |
| `password` | string | ✓ |

**Response (200 OK):**
```json
{
  "user": { "id": "u_abc123", "email": "user@example.com", "role": "user" },
  "token": "eyJhbGciOiJIUzI1NiI...",
  "refreshToken": "eyJhbGciOiJIUzI1NiI..."
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid email or password
- `400 Bad Request` - Missing required fields

**Rate Limit:** 5 requests per 5 minutes

---

### POST /auth/forgot

Request password reset link.

**Request:**
```bash
curl -X POST http://localhost:3000/auth/forgot \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com"}'
```

**Response (200 OK):**
```json
{
  "message": "Password reset link sent to your email"
}
```

**Note:** In production, a secure reset link is sent via email. The response never contains the reset token for security.

**Error Responses:**
- `404 Not Found` - Email not registered

**Rate Limit:** 5 requests per 5 minutes

---

### POST /auth/refresh

Get a new access token using refresh token.

**Request:**
```bash
curl -X POST http://localhost:3000/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "eyJhbGciOiJIUzI1NiI..."}'
```

**Parameters:**
| Param | Type | Required |
|-------|------|----------|
| `refreshToken` | string | ✓ |

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiI...",
  "refreshToken": "eyJhbGciOiJIUzI1NiI..."
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid or expired refresh token

---

### POST /auth/logout

Logout current user (client-side: discard token).

**Request:**
```bash
curl -X POST http://localhost:3000/auth/logout \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiI..."
```

**Response (200 OK):**
```json
{
  "message": "Logged out"
}
```

---

## Groups

### POST /group

Create a savings group.

**Requirements:** Authenticated user

**Request:**
```bash
curl -X POST http://localhost:3000/group \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "name": "Bootstrap Savings",
    "currency": "GBP",
    "locale": "en-GB",
    "country": "UK",
    "contributionAmount": 100,
    "cycleType": "weekly",
    "feePercent": 1
  }'
```

**Parameters:**
| Param | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| `name` | string | ✓ | - | 3-100 characters, unique |
| `currency` | string | ✗ | `GBP` | ISO 4217 code |
| `locale` | string | ✗ | `en-GB` | BCP 47 language tag |
| `country` | string | ✗ | `UK` | ISO 3166-1 alpha-2 |
| `contributionAmount` | number | ✗ | `100` | Positive number |
| `cycleType` | enum | ✗ | `weekly` | `weekly`, `biweekly`, `monthly` |
| `feePercent` | number | ✗ | `1` | Fee as % of collection |

**Response (201 Created):**
```json
{
  "id": "g_xyz789",
  "name": "Bootstrap Savings",
  "currency": "GBP",
  "locale": "en-GB",
  "country": "UK",
  "contributionAmount": 100,
  "cycleType": "weekly",
  "feePercent": 1,
  "creatorId": "u_abc123",
  "createdAt": "2026-04-02T10:30:00.000Z",
  "totalBalance": 0,
  "members": []
}
```

**Error Responses:**
- `400 Bad Request` - Validation failed
- `409 Conflict` - Group name already exists
- `401 Unauthorized` - Not authenticated

---

### GET /group/:groupName

Get group details with members.

**Requirements:** Authenticated user

**Request:**
```bash
curl -X GET http://localhost:3000/group/Bootstrap%20Savings \
  -H "Authorization: Bearer TOKEN"
```

**Response (200 OK):**
```json
{
  "name": "Bootstrap Savings",
  "currency": "GBP",
  "locale": "en-GB",
  "country": "UK",
  "contributionAmount": 100,
  "cycleType": "weekly",
  "totalBalance": 750,
  "members": [
    {
      "id": "m_123",
      "name": "Alice",
      "balance": 350,
      "joinedAt": "2026-04-02T10:35:00.000Z"
    },
    {
      "id": "m_456",
      "name": "Bob",
      "balance": 400,
      "joinedAt": "2026-04-02T10:36:00.000Z"
    }
  ],
  "cycles": [
    {
      "id": "c_001",
      "status": "collected",
      "grossPot": 200,
      "feeAmount": 2,
      "netPot": 198,
      "createdAt": "2026-04-02T11:00:00.000Z"
    }
  ]
}
```

**Error Responses:**
- `404 Not Found` - Group doesn't exist
- `401 Unauthorized` - Not authenticated

---

### GET /group/:groupName/status

Get group cycle status and statistics.

**Requirements:** Authenticated user

**Request:**
```bash
curl -X GET http://localhost:3000/group/Bootstrap%20Savings/status \
  -H "Authorization: Bearer TOKEN"
```

**Response (200 OK):**
```json
{
  "group": {
    "name": "Bootstrap Savings",
    "currency": "GBP",
    "locale": "en-GB",
    "country": "UK",
    "contributionAmount": 100,
    "cycleType": "weekly",
    "memberCount": 2
  },
  "stats": {
    "totalCollected": 200,
    "totalFee": 2,
    "netPayout": 198,
    "lastCycleStatus": "collected"
  },
  "members": [...],
  "cycles": [...]
}
```

---

## Members

### POST /group/:groupName/member

Add a member to group.

**Requirements:** Authenticated user (ideally admin/treasurer role)

**Request:**
```bash
curl -X POST http://localhost:3000/group/Bootstrap%20Savings/member \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"memberName": "Alice"}'
```

**Parameters:**
| Param | Type | Required |
|-------|------|----------|
| `memberName` | string | ✓ |

**Response (201 Created):**
```json
{
  "group": "Bootstrap Savings",
  "member": "Alice"
}
```

**Error Responses:**
- `400 Bad Request` - Missing memberName
- `404 Not Found` - Group not found
- `409 Conflict` - Member already exists in group
- `401 Unauthorized` - Not authenticated

---

### POST /group/:groupName/member/:memberName/deposit

Record a contribution/deposit for a member.

**Requirements:** Authenticated user

**Request:**
```bash
curl -X POST http://localhost:3000/group/Bootstrap%20Savings/member/Alice/deposit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"amount": 100}'
```

**Parameters:**
| Param | Type | Required | Constraints |
|-------|------|----------|-------------|
| `amount` | number | ✓ | > 0, ≤ 1,000,000 |

**Response (200 OK):**
```json
{
  "member": "Alice",
  "balance": 100
}
```

**Error Responses:**
- `400 Bad Request` - Invalid amount (negative, too large, or missing)
- `404 Not Found` - Group or member not found
- `401 Unauthorized` - Not authenticated

---

## Collections & Payouts

### POST /group/:groupName/collect

Collect contributions for the current cycle.

**Requirements:** Authenticated user with `admin` or `superadmin` role

**Request:**
```bash
curl -X POST http://localhost:3000/group/Bootstrap%20Savings/collect \
  -H "Authorization: Bearer TOKEN"
```

**Calculation Logic:**
```
Gross Pot = contributionAmount × activeMembers
Fee = Gross Pot × (feePercent / 100)
Net Pot = Gross Pot - Fee
```

**Response (200 OK):**
```json
{
  "message": "Collection completed",
  "grossPot": 200,
  "feeAmount": 2,
  "netPot": 198,
  "cycle": {
    "id": "c_001",
    "groupId": "g_xyz789",
    "status": "collected",
    "grossPot": 200,
    "feePercent": 1,
    "feeAmount": 2,
    "netPot": 198,
    "createdAt": "2026-04-02T11:00:00.000Z"
  }
}
```

**Error Responses:**
- `400 Bad Request` - No members in group
- `403 Forbidden` - Insufficient role
- `404 Not Found` - Group not found
- `401 Unauthorized` - Not authenticated

**Rate Limit:** 10 requests per hour

---

### POST /group/:groupName/payout

Pay out net pot to a member.

**Requirements:** Authenticated user with `admin` or `superadmin` role

**Request:**
```bash
curl -X POST http://localhost:3000/group/Bootstrap%20Savings/payout \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"recipient": "Alice"}'
```

**Parameters:**
| Param | Type | Required |
|-------|------|----------|
| `recipient` | string | ✓ |

**Response (200 OK):**
```json
{
  "message": "Payout successful",
  "recipient": "Alice",
  "netPayout": 198,
  "grossPot": 200,
  "feeAmount": 2,
  "cycleId": "c_001"
}
```

**Error Responses:**
- `400 Bad Request` - Recipient required, no cycle available
- `403 Forbidden` - Insufficient role
- `404 Not Found` - Group, member, or cycle not found
- `401 Unauthorized` - Not authenticated

**Rate Limit:** 10 requests per hour

---

## Reports & Status

### GET /reports/user

Get user's group memberships and financial summary.

**Requirements:** Authenticated user (any role)

**Request:**
```bash
curl -X GET http://localhost:3000/reports/user \
  -H "Authorization: Bearer TOKEN"
```

**Response (200 OK):**
```json
{
  "userId": "u_abc123",
  "data": [
    {
      "groupName": "Bootstrap Savings",
      "balance": 350,
      "totalContributed": 300
    },
    {
      "groupName": "Emergency Fund",
      "balance": 200,
      "totalContributed": 200
    }
  ]
}
```

---

### GET /reports/admin

Get administrative dashboard (group-level statistics).

**Requirements:** Authenticated user with `admin` or `superadmin` role

**Request:**
```bash
curl -X GET http://localhost:3000/reports/admin \
  -H "Authorization: Bearer TOKEN"
```

**Response (200 OK):**
```json
{
  "stats": {
    "activeGroups": 5
  },
  "users": {
    "totalUsers": 25
  },
  "cycles": {
    "totalCycles": 18
  },
  "byMonth": [
    {
      "month": "2026-04",
      "totalGross": 5000,
      "totalFees": 50,
      "totalNet": 4950
    },
    {
      "month": "2026-03",
      "totalGross": 4800,
      "totalFees": 48,
      "totalNet": 4752
    }
  ]
}
```

**Error Responses:**
- `403 Forbidden` - Insufficient role

---

### GET /reports/superadmin

Get superadmin dashboard (system-wide analytics).

**Requirements:** Authenticated user with `superadmin` role

**Request:**
```bash
curl -X GET http://localhost:3000/reports/superadmin \
  -H "Authorization: Bearer TOKEN"
```

**Response (200 OK):**
```json
{
  "roleBreakdown": [
    { "role": "user", "count": 20 },
    { "role": "admin", "count": 4 },
    { "role": "superadmin", "count": 1 }
  ],
  "volume": [
    {
      "day": "2026-04-02",
      "grossVolume": 1200,
      "feeVolume": 12,
      "netVolume": 1188,
      "cycles": 3
    }
  ],
  "geo": [
    {
      "country": "UK",
      "currency": "GBP",
      "groupCount": 5,
      "grossByRegion": 5000
    }
  ]
}
```

---

## Health Check

### GET /health

System health status (no authentication required).

**Request:**
```bash
curl -X GET http://localhost:3000/health
```

**Response (200 OK):**
```json
{
  "status": "ok"
}
```

---

## Error Handling

### Standard Error Response

```json
{
  "error": "Error message describing what went wrong"
}
```

### Common HTTP Status Codes

| Code | Meaning |
|------|---------|
| `200` | OK - Request succeeded |
| `201` | Created - Resource successfully created |
| `400` | Bad Request - Invalid input parameters |
| `401` | Unauthorized - Missing or invalid authentication token |
| `403` | Forbidden - Authenticated but insufficient permissions |
| `404` | Not Found - Resource doesn't exist |
| `409` | Conflict - Resource already exists (e.g., duplicate email) |
| `429` | Too Many Requests - Rate limit exceeded |
| `500` | Internal Server Error - Server-side error |

### Example Error Responses

**Invalid Email:**
```json
{
  "error": "\"email\" must be a valid email"
}
```

**Rate Limit Exceeded:**
```json
{
  "error": "Too many requests, please try again later"
}
```

**Insufficient Permissions:**
```json
{
  "error": "Forbidden"
}
```

---

## Rate Limits

All endpoints are rate-limited to prevent abuse:

| Endpoint Group | Limit | Window |
|---|---|---|
| **Global** | 100 requests | 1 minute |
| **Auth (signup/signin/forgot)** | 5 requests | 5 minutes |
| **Financial (collect/payout)** | 10 requests | 1 hour |

Rate limit information is included in response headers:
```
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 3
X-RateLimit-Reset: 1680000000
```

When rate limit is exceeded, you receive:
```
HTTP/1.1 429 Too Many Requests
{
  "error": "Too many requests, please try again later"
}
```

---

## Authentication Flow

### Token Format

Access tokens are JWT tokens with 2-hour expiry. Include them in request headers:

```bash
curl -X GET http://localhost:3000/reports/user \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Refresh Token Flow

When access token expires:

1. Use refresh token to get new access token:
```bash
curl -X POST http://localhost:3000/auth/refresh \
  -d '{"refreshToken": "..."}'
```

2. Response includes new access token (and new refresh token)

3. Update client-side token storage and retry original request

---

## Testing with cURL

**Sign up:**
```bash
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test1234"}'
```

**Save token (result from signup):**
```bash
TOKEN="eyJhbGci..."
```

**Create group:**
```bash
curl -X POST http://localhost:3000/group \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"My Group","contributionAmount":100}'
```

**Add member:**
```bash
curl -X POST "http://localhost:3000/group/My%20Group/member" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"memberName":"Alice"}'
```

**Record deposit:**
```bash
curl -X POST "http://localhost:3000/group/My%20Group/member/Alice/deposit" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"amount":100}'
```

---

## Deprecation & Versioning

- **Current API Version:** 1.0
- **Deprecation Notice:** None active
- **Next Version:** 2.0 (planned Q3 2026)

For version migration guides, see [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)

---

## Support

- **Issues:** Report bugs via [GitHub Issues](https://github.com/trykon/osusu/issues)
- **Questions:** Post in [Discussions](https://github.com/trykon/osusu/discussions)
- **Security:** Report to security@trykon.com

