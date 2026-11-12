# carpesignum
Stjärnorna var aldrig nära nog.

## Så kör du appen

Appen är en iPhone-app som byggs i Xcode på en Mac.

**I simulatorn (utan Bluetooth):** öppna `CarpeSignum.xcodeproj` i Xcode, välj en iPhone-simulator uppe i mitten och tryck på ▶. Simulatorn har ingen Bluetooth, så appen visar påhittade signaler.

**På din egen iPhone (riktig Bluetooth):**
1. Koppla telefonen till Macen med en sladd och lås upp den.
2. I Xcode: *Settings → Accounts* och logga in med ditt Apple-ID.
3. Klicka på projektet **CarpeSignum** i listan till vänster → *Signing & Capabilities* → välj ditt namn under *Team*.
4. På telefonen: *Inställningar → Integritet och säkerhet → Utvecklarläge* → slå på (telefonen startar om).
5. Välj din telefon uppe i mitten i Xcode och tryck på ▶.
6. Första gången: *Inställningar → Allmänt → VPN och enhetshantering* på telefonen → lita på ditt Apple-ID.

Appen fungerar i sju dagar med ett gratis Apple-ID.

## Flödet (följer Figma-filen "Carpe Signum – första utkast")

1. **Första gången:** startskärm med "Koppla till Bluetooth". Visas bara en gång.
2. **Hämtar signaler:** skannar i sju sekunder och visar prylarna live.
3. **Dagens horoskop:** frågetecknet uppe till höger öppnar "Så räknade vi".
4. **Guida mig rätt:** "Tar fram din guide…" och sedan att göra-listan under fliken Guide.

Samma horoskop gäller hela dagen. Nästa dag hoppar appen över startskärmen och börjar skanna direkt.

## Bonustekniker

- **Gyro:** lägg telefonen med skärmen nedåt på horoskopet för att konsultera signalerna. Vänd upp den för att se guiden. (`CarpeSignum/Motion.swift`)
- **Konfetti:** gyllene stjärnstoft när du bockar av en punkt i guiden. (`CarpeSignum/Stardust.swift`)
- **Öppet API:** vädret i en avlägsen stad från Open-Meteo, utan nyckel. Utan internet visas raden inte. (`CarpeSignum/Weather.swift`)

## Dolt reglage för demon

**Håll inne på datumet** högst upp på horoskopet i drygt en sekund: läs signalerna igen, eller slå på/av demoläget med påhittade signaler.

## Var saker finns

- `CarpeSignum/Library.swift`: alla texter till horoskop och att göra-listor. Lägg gärna till fler.
- `CarpeSignum/Theme.swift`: färger, typsnitt och komponenter från Figma.
- `CarpeSignum/Astrology.swift`: hur signaler blir rum, tecken och kontorsplaneter.
