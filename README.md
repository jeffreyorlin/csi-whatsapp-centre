# CSI Meetpar Yesu Alayam — New Shared Register & WhatsApp Centre

This is a fresh project, separate from the existing Android app and from the old Supabase project. It provides a responsive browser dashboard, a Supabase database schema, manual WhatsApp drafts, and a secure Edge Function starter for automatic WhatsApp Business template messages.

## Included
- `index.html` — responsive dashboard, email/password auth, shared member contacts, birthday/anniversary fields, consent, CSV export, Tamil/English wish drafts.
- `supabase/schema.sql` — database tables and row-level security policies.
- `supabase/functions/send-due-wishes/index.ts` — daily sender starter using official Meta WhatsApp Cloud API.

## 1. Set up Supabase
1. Use your new Supabase project: `https://ziztbhuycxcmelxhnzlu.supabase.co`.
2. Open SQL Editor → New query and run the contents of `supabase/schema.sql`.
3. Open Authentication → Providers and ensure Email is enabled. Decide your email-confirmation policy before inviting users.
4. Only trusted church users should be allowed to create accounts. Current policies let any authenticated user in this project read/write shared contacts; tighten access before broad use.

## 2. Publish with GitHub Pages
1. Upload `index.html` to the root of your public repository (replace the old starter index.html only if you want to use this fresh version).
2. Keep `README.md` and `supabase/schema.sql` in the repository. GitHub upload of a folder can be awkward; create `supabase/schema.sql` through Add file → Create new file if necessary.
3. GitHub Settings → Pages → Deploy from a branch → `main` → `/(root)`.
4. Open the site and enter the Supabase URL and public publishable/anon key. Never put a service-role key or Meta access token in browser code.
5. Create an account and test with a contact whose phone number you control. Sign in on another device to verify shared data.

## 3. Connect an Android app
The same Supabase project and the same `church_contacts` table must be used by the Android app. This package is a web dashboard, not a ready-made APK. To make a new Android app, wrap this web project with Capacitor/Android Studio or build a native screen that uses Supabase Auth and this same table. Do not assume the older app is connected until verified. Existing local-only records must be exported/imported or migrated deliberately; they do not appear in Supabase automatically.

## 4. Automatic WhatsApp sending (not enabled until configured)
Manual drafts work without the WhatsApp Cloud API. Automatic sending requires a Meta developer app, WhatsApp Business Account, sender phone number ID, access token, approved templates, and consent from recipients. Template body must include one `{{1}}` variable for the recipient name. Confirm the template language codes match the templates actually approved in WhatsApp Manager.

Deploy the function with Supabase CLI:
```sh
supabase login
supabase link --project-ref ziztbhuycxcmelxhnzlu
supabase functions deploy send-due-wishes
```

Set these secrets under Supabase Edge Functions → Secrets:
- `WHATSAPP_ACCESS_TOKEN`
- `WHATSAPP_PHONE_NUMBER_ID`
- `WHATSAPP_BIRTHDAY_TEMPLATE`
- `WHATSAPP_ANNIVERSARY_TEMPLATE`
- `WHATSAPP_TEMPLATE_LANGUAGE` (default `ta`)
- `WHATSAPP_GRAPH_API_VERSION` (default `v23.0`; use a currently supported version)
- `CRON_SECRET` (long random secret)

Supabase supplies `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to Edge Functions. Never put the service role key in GitHub or the browser. The daily function uses Asia/Kolkata date and the `x-cron-secret` header; schedule an HTTP POST to `https://ziztbhuycxcmelxhnzlu.supabase.co/functions/v1/send-due-wishes` shortly after midnight India time, with `Content-Type: application/json`, `x-cron-secret: YOUR_CRON_SECRET`, and body `{}`. Store the secret securely, not in a public file.

The function records API acceptance, not delivery/read status; webhooks are needed for confirmed delivery receipts. Test with your own opted-in number before real use. Automatic delivery is not active just by uploading this ZIP.

## Safety
- Do not use the Meta access token or Supabase service-role key in `index.html` or GitHub.
- Never send messages to contacts without consent; honour opt-outs.
- Do not upload member CSV files to a public repository.
- Back up contacts before schema changes.
