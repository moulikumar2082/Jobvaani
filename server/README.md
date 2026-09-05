# JobVaani Authentication & API Backend

Secure, multi-user authentication backend built with **Node.js**, **Express**, **JWT**, **bcryptjs**, and **MongoDB**.

## Features

- **Multi-User Registration (`POST /api/auth/register`)**:
  - Validates input format, full name (min 2 characters), email, password (min 6 characters).
  - Enforces unique email constraint; returns:
    `"An account with this email already exists. Please login."`
  - Salts and hashes passwords using `bcryptjs` (10 rounds). Plain-text passwords are never saved.
  - Automatically signs and returns a JWT token and user profile.
- **Login (`POST /api/auth/login`)**:
  - Validates credentials against bcrypt hash.
  - Generates signed JWT tokens containing `userId` and `email`.
- **User Data Isolation (`/api/saved-jobs`)**:
  - Every saved job request verifies the JWT Bearer token in the `Authorization` header.
  - Data operations use `req.user.id` strictly from the token. Client-provided user IDs are never trusted.
  - User A never sees User B's saved jobs.
- **Password Reset (`POST /api/auth/forgot-password`)**:
  - Neutral responses to prevent user enumeration attacks.

## How to Run the Backend

```bash
cd server
npm install
npm start
```

For development with auto-reload:
```bash
npm run dev
```

Server runs by default on `http://localhost:5000`.
