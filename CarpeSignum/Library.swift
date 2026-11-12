import Foundation

/// Biblioteket med färdigskrivna texter som AI-astrologen väljer bland.
///
/// Luckor som fylls i med riktig data:
///   {dbm}        starkaste signalen, t.ex. "−41 dBm"
///   {svagast}    svagaste signalen, t.ex. "−97 dBm"
///   {tecken}     dagens tecken, t.ex. "Oxen"
///   {teckenrum}  t.ex. "Oxens rum"
///   {rum}        rummet för starkaste signalen, t.ex. "badrummet"
///   {planet}     en kontorsplanet eller pryl, t.ex. "Kaffemaskinen"
///   {planetnr}  planetens rumsnummer som romersk siffra, t.ex. "III"
///   {planetrum}  planetens rum, t.ex. "köket"
///   {foljare}    prylen som varit nära längst, t.ex. "en okänd Apple-enhet"
///   {tid}        hur länge, t.ex. "tre timmar"
///   {antal}      antal enheter, t.ex. "41"
///
/// Lägg gärna till fler texter. Håll tonen helt allvarlig.
enum Library {

    // MARK: Horoskop, rubriken

    static let headlines: [String] = [
        "{planet} står i ditt {planetord} rum",
        "{planet} har gått in i ditt {planetord} rum",
        "{planet} vandrar genom ditt {planetord} rum",
        "{planet} har tagit plats i {planetrum}",
        "{planet} har vänt sig mot dig",
    ]

    // MARK: Horoskop, stycke 1: signalstyrkan

    static let openings: [String] = [
        "Med en signalstyrka på {dbm} i {teckenrum} bör du undvika viktiga beslut före lunch.",
        "Signalen står i {dbm} i {teckenrum}. Det är ett gynnsamt läge för att säga nej till saker du redan sagt ja till.",
        "{teckenrum} lyser idag med {dbm}. Det har inte hänt sedan i tisdags, och då gick det som det gick.",
        "När {tecken} mäter {dbm} på morgonen bör man inte lita på sitt eget omdöme förrän efter klockan tre.",
        "En signalstyrka på {dbm} i {teckenrum} talar för förändring. Förändringen är liten och gäller troligen din lunch.",
        "{tecken} står i {dbm} idag. Det är starkare än vad som är lämpligt för en onsdag, oavsett vilken dag det är.",
        "Dagens starkaste signal, {dbm}, faller i {teckenrum}. Gör inga större inköp, särskilt inte av sladdar.",
        "Med {dbm} i {teckenrum} är du ovanligt mottaglig. Undvik möten där någon säger ”snabb fråga”.",
        "Signalerna i {teckenrum} ligger på {dbm}. Det är ett tecken på att du har rätt, men inte idag.",
        "{dbm} i {teckenrum} innebär att dina relationer stärks, framför allt den till din laddare.",
        "När signalen når {dbm} i {teckenrum} bör man vara försiktig med att svara ”alla” på e-post.",
        "{teckenrum} mäts idag till {dbm}. Den som föds under denna signal blir sällan tekniskt ansvarig, men ofta tillfrågad.",
    ]

    // MARK: Horoskop, stycke 2: en andra planet i sitt rum
    // (här betyder {planet} den andra planeten, inte den i rubriken)

    static let planets: [String] = [
        "{planet} har dragit sig tillbaka till det {planetord} rummet. Det talar för tålamod, men emot mjölkskum.",
        "{planet} står i ditt {planetord} rum. Det talar för tålamod, men emot mjölkskum.",
        "{planet} har gått in i {planetrum}. Det är ett gott tecken för den som väntar, och ett dåligt för den som har bråttom.",
        "{planet} befinner sig i ditt {planetord} rum. Lyssna på den, även om den bara säger ett enda ljud.",
        "Med {planet} i {planetrum} bör du hålla dina åsikter om kontorsmöbler för dig själv.",
        "{planet} står i {planetnr}. Det är en konstellation som brukar föregå missförstånd i kalendern.",
        "När {planet} vandrar in i ditt {planetord} rum blir det svårare att hitta rätt mötesrum.",
        "{planet} står stilla i {planetrum}. Gör du detsamma kommer dagen att gå bra.",
        "{planet} i {planetnr} talar för samarbete. Samarbetet kommer inte att fungera, men det talar för det.",
        "{planet} har tagit plats i ditt {planetord} rum och kommer att stanna där tills någon flyttar den.",
        "Det är ovanligt att {planet} står i {planetrum} så här tidigt i veckan. Ta det som en varning eller ett erbjudande.",
        "{planet} i ditt {planetord} rum innebär att någon nära dig har en åsikt om din kaffe.",
        "{planet} står i opposition till din telefon. Låt dem lösa det själva.",
    ]

    // MARK: Horoskop, stycke 3: prylen som följt dig

    static let followers: [String] = [
        "{foljare} har följt dig i {tid}. Det är ingen slump.",
        "{foljare} har varit nära dig i {tid}. Den vet mer än den säger.",
        "Under {tid} har {foljare} hållit sig inom två meter. Fråga dig varför.",
        "{foljare} har inte lämnat din sida på {tid}. Det är antingen lojalitet eller en kabel.",
        "I {tid} har {foljare} lyssnat. Den har inte sagt något, och det är det mest oroande.",
        "{foljare} har funnits i din närhet i {tid}. Det binder er samman, men inte juridiskt.",
        "{foljare} har sänt mot dig i {tid}. Du behöver inte svara, men du bör veta om det.",
        "Bland {antal} enheter har {foljare} valt dig. Den har gjort det i {tid}.",
        "{foljare} har varit med dig i {tid}. Ni är nu kompatibla, även om det inte gäller er.",
        "Svagast idag är {svagast}. Den signalen är någon annans problem. {foljare} däremot har följt dig i {tid}.",
    ]

    // MARK: Att göra, nivå 1 till 5 (vardagligt till drastiskt)

    static let todos: [[String]] = [
        // 1: vardagligt
        [
            "Håll dig borta från brunnar.",
            "Drick ditt vatten från vänster sida av glaset.",
            "Ladda inte telefonen före lunch.",
            "Säg ”tack” till hissen.",
            "Ta trapporna, men bara nedåt.",
            "Ställ inte koppen på skrivbordets högra halva.",
            "Byt sida på sängen ikväll.",
            "Öppna inga flikar som du inte tänker stänga.",
            "Lägg telefonen med skärmen uppåt. Den vill se.",
            "Undvik ord som börjar på B.",
        ],
        // 2: lite konstigt
        [
            "Hälsa på {planet} innan du hälsar på en människa.",
            "Undvik skrivaren efter klockan två.",
            "Sitt inte närmare än två meter från {planet}.",
            "Byt plats i mötesrummet varje gång någon säger ”synergi”.",
            "Sätt på dig skorna i omvänd ordning.",
            "Ät lunch i {planetrum}, oavsett var den serveras.",
            "Stäng av Bluetooth i elva minuter. Säg inget till någon.",
            "Fråga {planet} om lov innan du tar en kopp.",
            "Gå ett varv runt bordet innan du sätter dig.",
            "Byt namn på din telefon till något mer ödmjukt.",
        ],
        // 3: märkligt
        [
            "Gå baklänges till ditt nästa möte.",
            "Svara bara på mejl som innehåller ett udda antal ord.",
            "Ta inga beslut i rum med fler än tre uttag.",
            "Viska ditt namn till {planet} tre gånger.",
            "Bär dina hörlurar på fel öron hela eftermiddagen.",
            "Presentera dig med ditt tecken istället för ditt namn.",
            "Låt {planet} bestämma vad du äter till middag.",
            "Ställ alla stolar i {planetrum} så att de pekar mot routern.",
            "Tacka nej till allt som erbjuds i fyrkantiga förpackningar.",
            "Gå bara på varannan platta i korridoren.",
        ],
        // 4: allvarligt
        [
            "Säg upp din prenumeration på något du tycker om.",
            "Flytta in i {planetrum} tills signalen stabiliseras.",
            "Avboka alla möten där {planet} inte är inbjuden.",
            "Ge din telefon till den person du litar minst på, i en timme.",
            "Ändra din adress till {planetrum}.",
            "Ring din mamma och säg att {planet} hälsar.",
            "Sälj soffan. Den står i fel rum.",
            "Byt tandkräm till ett märke du aldrig har hört talas om.",
            "Tatuera in {dbm} någonstans där ingen ser det.",
            "Lämna jobbet tidigt och kom tillbaka sent, samma dag.",
        ],
        // 5: drastiskt
        [
            "Gör slut med din partner och lämna landet.",
            "Sälj din bostad och flytta närmare {planet}.",
            "Byt namn till {tecken} och flytta till en annan tidszon.",
            "Säg upp dig och starta ett företag tillsammans med {planet}.",
            "Lämna allt du äger i {planetrum} och börja om på nytt i hallen.",
            "Gifta dig med den första enhet som går under {dbm}.",
            "Flytta till en ö där det saknas Bluetooth. Ta inte med telefonen.",
            "Testamentera allt du äger till {planet}.",
            "Byt kontinent före klockan fem.",
            "Gå i exil i {planetrum} tills Merkurius har bestämt sig.",
        ],
    ]

}
