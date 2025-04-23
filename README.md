# Oracle-APEX-App-level-Automatic-Read-Only-Mode

This repository provides a PL/SQL snippet to enforce a global read-only mode in Oracle APEX applications. This functionality ensures that certain users (e.g., auditors) can view the application without making changes.

---

## How to Implement

### 1. Create an Application Process for Global Read-Only Mode
1. Go to **Shared Components > Application Processes**.
2. Create a new process with the following settings:
   - **Point**: `On Load: Before Header`
   - **Process Code**: Use the provided PL/SQL snippet.
3. Save the process.

### 2. Set Up an Authorization Scheme
1. Go to **Shared Components > Authorization Schemes**.
2. Create a new scheme named `Auditor`.
3. Assign this scheme to users who should have read-only access.

### 3. Test the Implementation
1. Log in as a user with the `Auditor` role.
2. Verify that all form items, buttons, and other interactive elements are disabled.

---

This process ensures secure and dynamic enforcement of read-only access for specific roles in your APEX application.
