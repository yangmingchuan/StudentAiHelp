# Supabase account and record sync

Target project: onvhkbbfvvjvdzqsalcd. All new public tables, functions and sequences use todo_. Existing flower_* and tasks tables are untouched.

## Acceptance
- Existing phone-format usernames keep password login. Supabase issues and refreshes sessions after first verified migration from CloudBase.
- Each account has its own local database and cloud rows. Login on a second device downloads records; account switching cannot upload the previous account's records.
- Offline edits persist in an SQLite transactional outbox. Foreground/resume and local writes trigger sync. Concurrent different records merge; same-record conflicts are retained for explicit resolution.
- Import legacy SQLite only when its stored CloudBase username matches the authenticated username. Keep the legacy file intact. Health fields are decrypted only for TLS transport and re-encrypted with the receiving device's key.
- Tasks, historical completions, child profile, badges, rest days, rewards, redemptions, cycles, medicines, members, medication logs and reminders sync. Star balances are derived from records rather than overwritten by device snapshots.
- Cloud API denies anonymous access and access to another owner's rows. No server/admin key in the app.

## Storage and protocol
Per-entity todo_ tables carry owner_id, record_key, payload (versioned local model fields), revision and deleted. This preserves existing app models and audit rows while isolating sync metadata. RLS is owner-only. An atomic RPC validates entity names, serializes each owner's sync transaction, applies compare-and-set writes and deduplicates operation IDs. Pull is revision-paginated. Tombstones propagate deletions. Device-local asset snapshots and notification IDs are not cloud identities.

Supabase Auth uses a private synthetic email namespace for existing phone-format usernames (not verified telephone ownership). A server-only migration/registration function verifies the old account before provisioning a Supabase identity; it never logs passwords or replaces existing Supabase passwords. During transition, new usernames are reserved through the existing registration service to avoid claiming an old CloudBase username. Normal sign-in and refresh use Supabase only once migrated. Shared project Auth settings are unchanged.

## Verification
Unit tests cover token parsing, auth endpoints, account separation, import ownership, outbox persistence, push retry, tombstones, conflicts, encrypted health transport and two independent databases. Remote checks use disposable test accounts to prove owner isolation, idempotency and cross-device read/write. Android build/install checks the configured project. Real legacy accounts require the user to enter their password on the device.
