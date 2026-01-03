# Rapport inför lansering av webbplats för webinarium

## Översikt

Du har byggt ett fullt fungerande anmälningsformulär för webinaret. Det är driftssatt på Azure och använder olika serverroller som en reverse proxy, bastion host och applikationsserver, tillsammans med en hanterad databastjänst. För denna uppgift ska du förbereda en **lanseringsrapport** som visar att lösningen är redo för lansering (och din förståelse för systemets komponenter).

Utöver att ge **tekniska** och **projektledningsmässiga** detaljer ska du inkludera **test- och verifieringssteg** för att visa hur du säkerställt att varje del av lösningen fungerar som förväntat. Använd **skärmbilder** och **beskrivningar**.


## Syfte

Uppgiften syftar till att:

1. Visa dina kunskaper om infrastruktur, applikationsstack och säkerhetsåtgärder samt koppla dessa till ett projektledningsperspektiv.
2. Visa din färdighet i att implementera samt testa och verifiera funktionalitet i lösningen.


## Disposition
Din rapport ska inkludera följande sektioner:

### 1. Sammanfattning (5%)
   - Ge en kort översikt av projektets syfte och mål.
   - Sammanfatta systemets huvudkomponenter och deras funktion.

### 2. Teknisk arkitektur och konfiguration (30%)

   - **Beskrivning:**

     - Redogör för Azure-infrastrukturen, inklusive:
       - Nätverkslayout (subnät, NSG-regler, intern/extern kommunikation).
       - Rollen för reverse proxy, bastion host och applikationsserver.
       - Den hanterade databastjänsten (Azure Database for PostgreSQL).
     - Beskriv nyckelkonfigurationer (t.ex. för reverse proxy, Azure Database for PostgreSQL, Gunicorn).
     - Om du använde automation (Azure CLI, bash-skript, etc.), beskriv ditt tillvägagångssätt och hur det förbättrar reproducerbarheten.

   - **Verifiering:**

     - Ge steg-för-steg-instruktioner för hur du verifierade:
       - Korrekt nätverkskommunikation mellan komponenter.
       - NSG-regler (t.ex. lyckade eller blockerade anslutningsförsök).
     - Inkludera skärmbilder från konfigurationssidor och testresultat (t.ex. Azure-portalen, SSH-terminal).

### 3. Applikationsstack och funktionalitet (30%)

   - **Beskrivning:**

     - Beskriv applikationsstacken:
       - **Operativsystem:** Ubuntu Linux
       - **Webbserver:** nginx (reverse proxy)
       - **Applikationsserver:** Gunicorn (WSGI-server)
       - **Webbramverk:** Flask (Python)
       - **Databas:** PostgreSQL (hanterad Azure-tjänst)
     - Förklara flödet för anmälningsformuläret - från användarinmatning genom reverse proxy och applikationsserver till datalagring i databasen.

   - **Verifiering:**

     - Visa hur du testade:
       - Anmälningsformuläret (t.ex. submit, validering och datalagring).
       - Databasanslutning (t.ex. frågor mot databasen för att hämta sparad data). Du kan använda ett GUI-verktyg som DBeaver eller PostgreSQL CLI (`psql`) för att ansluta och verifiera.
     - Inkludera skärmbilder av formuläret i aktion och resultat från databasfrågor.

### 4. Säkerhet (20%)

   - **Beskrivning:**

     - Belys säkerhetsåtgärder som vidtagits, inklusive:
       - Nätverkssäkerhet (NSG-regler, ASG, nätverkssegmentering)
       - SSH-åtkomst (bastion host, SSH-nycklar, agent forwarding)
       - HTTPS-konfiguration (SSL-certifikat på reverse proxy)
       - Hantering av hemligheter (hur databasanslutningssträngen hanteras)

   - **Verifiering:**
     - Beskriv tester för:
       - SSH-anslutning (t.ex. lyckad åtkomst via bastion host med agent forwarding eller ProxyJump).
       - NSG-regler (t.ex. blockerade och tillåtna anslutningar).
       - HTTPS (t.ex. att certifikatet visas, webbläsaren visar säker anslutning).
     - Ge skärmbilder som visar blockerade och tillåtna anslutningar, samt att HTTPS fungerar.

### 5. Riskmedvetenhet (5%)

   - **Beskrivning:**

     - Reflektera över potentiella risker kopplade till lanseringen av webbplatsen. Vad kan gå fel?
     - Överväg tekniska, operativa eller säkerhetsrelaterade problem.
     - För varje risk du identifierar, föreslå kort hur den kan hanteras.

   Denna sektion handlar om att visa medvetenhet om risker, inte en formell riskanalys.

### 6. Processreflektion (10%)

   Reflektera kort över hur du arbetade:

   - **Iterativ utveckling:** Hur påverkade det att bygga stegvis (MVP först, sedan lägga till lager) din framgång? Vad lärde du dig av de veckovisa demonstrationerna?
   - **AI-användning:** Hur använde du AI-verktyg (Claude, ChatGPT, Copilot, etc.) i detta projekt? För vilka uppgifter - förstå koncept, felsökning, generera kod, skriva konfigurationer? Vad fungerade bra, och var gav AI dig felaktig vägledning? Hur verifierade du AI-genererade lösningar?
   - **Automation:** Om du var tvungen att bygga om hela din infrastruktur från grunden imorgon, hur lång tid skulle det ta? Vad är automatiserat respektive kräver manuella steg?

   **Viktigt:** Det finns inget avdrag för att använda AI för att bygga din lösning - tvärtom uppmuntras och belönas effektiv användning av AI. Däremot måste denna rapport skrivas av dig själv, inte genereras av AI.


### Inlämningsdetaljer

- **Format:** PDF-dokument (uppladdat på Google Classroom)
- **Längd:** Cirka 4–8 sidor (exklusive bilder).

---


# Tips: Bygg lösningen gradvis!

När du bygger lösningen och förbereder din rapport är det viktigt att vara metodisk. Börja enkelt, säkerställ att varje komponent fungerar, och lägg sedan till mer komplexitet. På så sätt har du en fungerande lösning tidigt, även om säkerhet och arkitekturella funktioner inte är fullt implementerade från början.

### 1. Fokusera på en Minimal Viable Product (MVP) först

- Börja med **kärnfunktionaliteten**:

  - Utveckla Flask-applikationen lokalt med SQLite för snabb iteration.
  - Provisionera en enda VM med Gunicorn för att köra Flask-appen (SQLite fungerar bra initialt).
  - Se till att kontaktformuläret fungerar och att formulärdata lagras i databasen.

Detta ger dig en fungerande grund att bygga vidare på innan du lägger till avancerade konfigurationer som den hanterade PostgreSQL-databasen, reverse proxy och nätverkssegmentering.

### 2. Bygg upp lösningen gradvis i lager

Efter MVP, lägg till lager till lösningen ett i taget och testa varje steg.

- **Steg 1: Grundläggande nätverk**
  - Skapa ett virtuellt nätverk (VNet) med ett enda subnät.
  - Koppla applikationsservern till detta subnät och bekräfta att det går att nå via dess IP-adress.
  - Testa SSH-åtkomst.

- **Steg 2: Reverse Proxy**
  - Introducera nginx som reverse proxy för att hantera inkommande trafik.
  - Konfigurera nginx att vidarebefordra förfrågningar till Gunicorn (vanligtvis på port 5001).
  - Testa att trafik till proxyn vidarebefordras korrekt till Flask-applikationen.
  - Kontrollera regelbundet (t.ex. med curl eller webbläsare) att det fungerar.

- **Steg 3: Hanterad databas**
  - Provisionera Azure Database for PostgreSQL (hanterad tjänst).
  - Konfigurera Flask-applikationen att ansluta till PostgreSQL istället för SQLite.
  - Verifiera databasanslutningen och att data från formuläret lagras i databasen (använd DBeaver eller `psql` för att fråga databasen).

### 3. Arbeta tidigt med säkerhet

Även när du arbetar med grundläggande funktionalitet kan du implementera några viktiga säkerhetssteg:

- Använd SSH-nycklar för åtkomst till servrar.
- Begränsa inkommande trafik till nödvändiga portar (t.ex. port 22 för SSH, port 80 för HTTP) med hjälp av NSG.

### 4. Testa och verifiera kontinuerligt

Verifiera vid varje steg att din lösning fungerar som förväntat. Du kan använda dessa tekniker:

- **Manuella tester:** Testa anslutningar (t.ex. curl eller webbläsare och databasfrågor).
- **Skärmbilder:** Ta skärmbilder när det fungerar av formulär, databasfrågor, etc. Kör history.
- **Iterativ testning:** Efter att du gjort en förändring, testa arbetsflödet igen så att det fortfarande fungerar.

### 5. Lägg till avancerad säkerhet sist

När den grundläggande funktionaliteten är verifierad kan du fokusera på avancerade aspekter som:

- Implementera NSG, ASG och Service Tags.
- Provisionera en bastion host för säker SSH-åtkomst till interna servrar.
- Konfigurera systemd-tjänster för automatisk uppstart och hantering av applikationen.
- Konfigurera ett självsignerat SSL-certifikat på reverse proxy för att aktivera HTTPS.

Säkerhets- och arkitekturella förbättringar bör byggas ovanpå en stabil och fungerande grund.

### 6. Använd Azure-portalen och CLI för verifiering

- **Portalen:** Använd Azure-portalen för visuell återkoppling av Azure CLI-kommandon (NSG-regler, nätverkstopologi, etc.).

### 7. Gör noteringar

- Dokumentera varje steg medan du arbetar:
  - Vad du lade till eller ändrade.
  - Hur du testade det.
  - Vilka resultat du fick.
- Detta gör det enklare att skriva rapporten och att du inte glömmer något.


### Exempelprogression

1. Utveckla Flask-applikationen lokalt med SQLite-databas.
2. Testa kontaktformuläret för att säkerställa grundläggande funktionalitet lokalt.
3. Provisionera en enda Azure VM med Gunicorn för att köra Flask-appen.
4. Driftsätt Flask-applikationen och verifiera att den fungerar via HTTP.
5. Provisionera Azure Database for PostgreSQL och konfigurera applikationen att använda den.
6. Lägg till nätverkssegmentering med VNet och NSG-regler.
7. Lägg till ASG och Service Tags för finmaskig säkerhet.
8. Provisionera en Bastion Host och verifiera säker SSH-åtkomst.
9. Konfigurera systemd för produktionshantering av processer.
10. Kör ett slutligt test av lösningen och ta skärmbilder.
