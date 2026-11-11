# CLAUDE.md – Carpe Signum

Det här projektet är vårt bidrag till ett "Stupid hackaton". Läs hela filen innan du börjar bygga något.

## Vad vi bygger

**Carpe Signum** ("fånga signalen") är ett horoskop som bygger på vilka enheter du varit nära under dagen, hur nära och hur länge. En AI-astrolog tolkar datan med fullt allvar. Arbetsnamnet var Bluetoothskopet, så det namnet kan dyka upp i äldre material.

- **Tagline:** "Stjärnorna var aldrig nära nog."
- **Underrubrik:** "Parkopplad med ödet"
- **Kärnbudskap:** signaler, inte stjärnor. Du påverkas av prylarnas signaler runt dig, och en AI-astrolog tolkar dem åt dig.
- **Ytterligare rad:** "Carpe Signum leder dig rätt" / "Låt dig guidas rätt av experter"

### Funktioner

1. **Data:** vilka enheter du varit nära, ungefärligt avstånd via signalstyrka (dBm) och hur länge.
2. **Dagshoroskop:** AI-astrologen skriver ett horoskop utifrån datan. Exempel: "Med en signalstyrka på −67 dBm i Oxens hus bör du undvika viktiga beslut före lunch."
3. **Daglig att göra-lista:** uppgifter för dagen utifrån horoskopet, i ett spann från vardagligt till drastiskt. Exempel:
   - Håll dig borta från brunnar.
   - Undvik skrivaren efter klockan två.
   - Gå baklänges till ditt nästa möte.
   - Gör slut med din partner och lämna landet.

### Begreppen i vår "astrologi"

| | Horoskop | Carpe Signum |
|---|---|---|
| Styrs av | planeter | prylar i närheten |
| Avstånd | miljontals km | ett par meter |
| Tecken | bestäms vid födseln | byts när du byter pryl |
| Hus | tolv fält på himlen | fem rum i hemmet: hall, vardagsrum, kök, sovrum, badrum |

## Hackatonets regler (styr alla beslut)

- Vår tilldelade teknik är **parkoppling/igenkänning av andra enheter inom rumslig distansdimension**. Den måste synas tydligt i demon.
- Produkten ska vara onödig, dum eller poänglös. **Minuspoäng om lösningen blir för användbar.**
- Det finns en lista med extratekniker som ger extrapoäng. Fråga efter listan om den behövs, gissa inte vad som står på den.
- Produkten byggs helt eller delvis med AI, och vi jobbar agentiskt.

## Tidsplan

- Arbetstid: onsdag 11 nov 2026 kl 13–18
- **Demo: torsdag 12 nov 2026 kl 11:00**

Det är alltså mycket kort tid. Prioritera något som fungerar stabilt i en livedemo framför något tekniskt ambitiöst.

## Gruppen och hur du ska jobba med oss

Gruppen är en HR-person, en designer och en projektledare. Ingen av oss är utvecklare.

- Förklara tekniska val och steg enkelt, utan att förutsätta förkunskaper.
- Ge kommandon som går att kopiera och köra rakt av, och säg vad som ska hända när de körs.
- Föreslå hellre den enklaste lösningen som räcker för demon.
- Hitta inte på saker. Om du är osäker på om något fungerar (till exempel ett API, en plattform eller hårdvara), säg det och föreslå hur vi testar det snabbt.
- Om du tycker att ett beslut vi tar är dåligt, säg det och förklara varför.
- Fatta inte beslut i frågorna under "Öppet" på egen hand. Lägg fram alternativen och låt oss välja.

## Ton för AI-astrologens texter

- Fullständigt allvar. Inga skämtmarkörer, inga emojis, ingen blinkning till publiken. Humorn ska komma ur kontrasten mellan högtidlig ton och absurt innehåll.
- Använd tekniska detaljer som om de vore astrologiska: dBm-värden, enhetsnamn, rum som "hus".
- dBm läses "decibel" när texten läses upp, t.ex. "minus 67 dBm".
- Att göra-listan ska trappas upp, så att den sista punkten gärna är den mest drastiska.
- Allt innehåll är på svenska.

## Öppet (inte beslutat)

- **Metod för närhetsdetektering.** Inget är testat än. Alternativen vi känner till:
  - *Native-app med BLE:* varje telefon både sänder och lyssnar. Mest äkta, men alla måste installera en utvecklarversion och det är krångligast på iPhone.
  - *ESP32-kort eller BLE-beacons:* bärs eller placeras ut. Brukar vara stabilast för en demo och passar med idén om kontorsplaneter.
  - *Ultraljud i webbläsaren:* telefonerna spelar en nästan ohörbar ton runt 18–19 kHz och lyssnar efter varandras. Ingen installation, men högtalare och mikrofoner varierar mycket i det frekvensområdet.
  - *Ren webb med Web Bluetooth:* fungerar inte telefon till telefon. Webbläsaren kan inte sända ut en signal, skanning ligger bakom en experimentflagga i Chrome och saknas i Safari på iPhone.
- Oavsett metod blir avståndet ungefärligt, snarare "nära / mellan / långt" än exakta meter. Låtsas inte att det går att mäta exakt.
- **Vilka enheter gruppen har** (iPhone, Android, datorer). Fråga innan du väljer plattform.
- **Vilka upptrappningar som är med.** Föreslagna men inte beslutade:
  - *Kontorsplaneter:* beacons på kaffemaskinen, skrivaren och mikron, så att AI:n kan konstatera att "kaffemaskinen står i ditt sjunde hus".
  - *Merkurius i retrograd:* utlöses när någon backar bort från dig och signalen blir svagare.
  - *Enhetskompatibilitet:* kompatibilitet räknas bara mellan enheter, inte människor.
  - *Retroaktiva horoskop:* förutsäger med imponerande träffsäkerhet vad som hände igår.
  - *Oenig astrolog:* en andra AI-astrolog läser samma data och håller konsekvent inte med den första.
- **Vilka extratekniker från listan** vi får in.
- **Hur AI-astrologen anropas** (vilken modell/API och hur nyckeln hanteras) är inte bestämt.

## Presentationen

- Byggs i Figma, inte i det här repot.
- Läses helt stone-faced medan de andra står bakom och ser mystiska ut.
- Demon ska därför vara lätt att visa på en skärm och tåla att något går lite fel. Ha gärna en reservväg (t.ex. förinspelad eller simulerad data) om den riktiga detekteringen strular.

## Referenser

- Idédokument (Claude Doc): https://claude.ai/artifact/BujmoUeTAJ25Qpp8o2S32i
- Mötesanteckningar (Notion): https://app.notion.com/p/41525bdd917d8166af12dd0ab71949e1
