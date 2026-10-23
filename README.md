# CSI Meetpar Yesu Alayam — WhatsApp Automation Centre

A new, responsive starter app for the church. It uses GitHub Pages for the static dashboard and Supabase for shared sign-in, member contacts, and message logs. The dashboard can prepare WhatsApp drafts without paid services. Automatic sending is optional and only works after official Meta WhatsApp Cloud API setup and approved templates.

## Features in this starter
- Responsive dashboard for desktop and mobile.
- Supabase email/password sign-in; shared contacts across devices.
- Member name, phone, birthday, anniversary, language, and explicit WhatsApp consent.
- CSV import/export.
- Tamil greeting drafts and click-to-open WhatsApp manual sending.
- Campaign date matching, reports, and a scheduled sender Edge Function starter.
- Credentials kept out of the browser except the Supabase public anon/publishable key.

## 1. Create the Supabase database
1. Open your Supabase project dashboard and select **SQL Editor → New query**.
2. Open `supabase/schema.sql` in this ZIP, copy its contents, and paste into SQL Editor. Do not include Markdown backticks.
3. Click **Run** and confirm it succeeds.
4. Open **Project Settings → API** (or API Keys). Copy the Project URL and the public `anon` / publishable key. Never use a `service_role` / secret key in the web page.
5. In Authentication settings, decide whether to require email confirmation. For a small church register, invite only trusted church users and do not publish credentials.

## 2. Publish the dashboard with GitHub Pages (no Netlify)
1. Create a new GitHub repository, for example `csi-whatsapp-centre`.
2. Upload `index.html` and the `supabase` folder to the repository root (keep the folder structure).
3. In GitHub repository **Settings → Pages**, select **Deploy from a branch**, choose `main` and `/ (root)`, then Save.
4. Wait for GitHub Pages to show the site URL. Open that URL on your computer and phone.
5. Paste the Supabase Project URL and public key into the app, click **Connect project**, then create/sign in to an account. Use the same Supabase project on every device.

## 3. First test (no WhatsApp API cost)
1. Sign in, add a test contact using a number you control, and tick consent only if the recipient actually agreed.
2. Set a birthday/anniversary date and check Dashboard / Campaigns.
3. Use the Draft button to open WhatsApp with a prefilled message. You must press Send yourself. This is not automatic delivery.
4. Test CSV export/import using a small sample first.

## 4. Optional official automatic WhatsApp sending
Automatic delivery requires a Meta developer app, a WhatsApp Business Account/phone number, an active Cloud API access token, the phone number ID, and approved message templates. Meta may charge for messages according to current pricing and category/country. A personal WhatsApp number by itself is not enough to enable this server sender.

### Template assumptions
The sender sends **approved template messages** with one body text parameter containing the contact name. Create and get approval for templates in WhatsApp Manager whose names match the secrets below and whose body has a matching `{{1}}` variable. Set the language code to the exact approved template language (for example `ta` only if that language is available/approved for your template).

### Deploy the Edge Function
Install the Supabase CLI and sign in, then from this folder:
```sh
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase functions deploy send-due-wishes
```
Set these secrets in Supabase Dashboard → Edge Functions → Secrets (or CLI). Do not commit real values:
- `WHATSAPP_ACCESS_TOKEN` — Meta Cloud API token
- `WHATSAPP_PHONE_NUMBER_ID` — sender phone number ID from Meta
- `WHATSAPP_BIRTHDAY_TEMPLATE` — exact approved birthday template name
- `WHATSAPP_ANNIVERSARY_TEMPLATE` — exact approved anniversary template name
- `WHATSAPP_TEMPLATE_LANGUAGE` — exact approved language code
- `WHATSAPP_GRAPH_API_VERSION` — current supported Graph API version for your Meta app (default in code is `v23.0`; update if Meta has deprecated it)
- `CRON_SECRET` — long random secret used only by the scheduler

The Supabase project also provides `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to Edge Functions. Never put the service-role key in `index.html`, GitHub Pages, or a public repository.

### Schedule it
The function is designed to be called once daily and has a `x-cron-secret` guard. Use Supabase **Integrations → Cron** to schedule an HTTP request to:
`https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-due-wishes`
with method POST, header `Content-Type: application/json`, header `x-cron-secret: YOUR_CRON_SECRET`, and body `{}`. Schedule it after midnight in the timezone used by the function. The sender date calculation uses `Asia/Kolkata` (India Standard Time). Schedule the job shortly after midnight India time and test before enabling real member messages. Keep the secret in Supabase Vault / Cron secrets where supported, not in public SQL or GitHub files.

**Important limitation:** the current sender records the API acceptance as `sent`; it does not yet consume Meta webhooks for true delivered/read statuses. Delivery reporting requires a separate secured webhook integration. Test with your own opted-in number before scheduling real member messages. Avoid duplicate or unsolicited messages and honor opt-outs promptly.

## 5. Security checklist
- Do not make the repository private data public: GitHub Pages is public by default.
- Only the Supabase public anon/publishable key belongs in the browser, and RLS must remain enabled.
- Only invite authorized church users. This starter's policies allow any authenticated user in this project to read/write the shared register; restrict policies to an admin/approved-user table before inviting a large group.
- Never commit API tokens, `service_role` keys, member CSV files, or private contact data.
- Keep a record of consent and remove contacts who opt out.

## Troubleshooting
- **No contacts / relation missing:** run `supabase/schema.sql` in the same Supabase project whose URL/key you entered.
- **Invalid API key:** use the public anon/publishable key, not the service-role key.
- **Login works but contacts fail:** check RLS policies and browser console; ensure schema ran successfully.
- **WhatsApp opens but does not send automatically:** expected for manual draft mode; click Send yourself.
- **Cloud API error:** confirm number ID, token, approved template name, language code, and parameter count.
