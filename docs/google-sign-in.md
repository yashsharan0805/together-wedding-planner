# Connect Google sign-in

## Setup instructions

1. Open [Google Auth Platform](https://console.cloud.google.com/auth/overview). Create or select a Google Cloud project, for example “Together wedding planner”.
2. Under **Branding**, use “Together” as the application name and supply a support email and developer contact. For public production, add the actual app homepage and privacy policy on a domain you control.
3. Under **Audience**, choose External if inviting people outside your Workspace. This app uses only basic Sign in with Google identity, so Google's testing-mode exception means users do not need to be on the test-user list. If additional OAuth permissions are added later, configure test users before testing those permissions. An Internal app limits who can sign in.
4. Under **Clients**, choose **Create client → Web application**. Add these **Authorized JavaScript origins** for local use:

   ```text
   http://localhost
   http://localhost:8080
   ```

   When the live backend is deployed, also add its exact HTTPS origin, for example `https://wedding.example.com`. Do not include a path, query, or trailing route. The static sample preview is not the live backend.

5. Copy the **Client ID**, ending in `.apps.googleusercontent.com`. This implementation uses a browser popup callback and server ID-token verification; it needs no client secret or authorized redirect URI. Authentication uses basic identity information; no Drive or Calendar permissions are requested.
6. Set the ID in the local `.env` file:

   ```dotenv
   GOOGLE_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
   ```

7. Recreate the backend container so Compose reloads the environment:

   ```sh
   docker compose -f compose.yml up -d --force-recreate backend web
   ```

8. Open http://localhost:8080, choose a wedding address such as `aanya-arjun`, select **Create a new wedding with Google**, and sign in. For subsequent visits, leave the creation box unchecked. Add names and celebrations after signing in.

For hosted collaborators, add their exact Gmail or Google Workspace email first, then share the workspace link yourself. Their verified Google sign-in accepts a pending membership within one week; no email is sent and the link alone grants no access. The local development variant retains upstream confirmation messages captured in Letter Opener.

The adapter permits Gmail and verified Google Workspace identities for email linking. A Google account using a third-party email address uses password login instead, because Google is not authoritative for continued ownership of that email. The backend checks token signature/audience/issuer/expiry through `googleauth`, checks email verification and a session nonce, binds identity to Google's stable subject, and separately checks confirmed wedding membership.

If you get `origin_mismatch`, compare the browser address with the configured origin. If the button says the client ID is missing, recreate the container after editing `.env`. If hosted access is denied for a collaborator, check that their exact Google email was added and the pending membership has not expired. When creating your first wedding, select **Create a new wedding with Google** before signing in.

Sources: [Google setup](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid), [server token verification](https://developers.google.com/identity/gsi/web/guides/verify-google-id-token), [testing audience exception for basic sign-in](https://support.google.com/cloud/answer/15549945?hl=en).
