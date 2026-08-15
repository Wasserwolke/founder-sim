# Languages

Founder Sim starts in German. All player-facing text should use translation keys instead of hard-coded UI strings.

Current core language:
- `de.json`

To add a language later:
1. copy `de.json`, e.g. to `en.json`
2. keep the same key structure
3. translate only the values
4. load/select that locale in the UI when language selection is implemented

Mods may also merge their own translation keys at runtime.
