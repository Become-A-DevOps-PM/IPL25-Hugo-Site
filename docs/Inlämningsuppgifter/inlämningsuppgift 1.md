# Rapport inför lansering av webbplats för webinarium

## Översikt

Du har byggt ett fullt fungerande anmälningsformulär för webinaret. Det är driftssatt på Azure och använder olika serverroller som en reverse proxy, bastion host, applikationsserver och databasserver. För denna uppgift ska du förbereda en **lanseringsrapport** som visar att lösningen är redo för lansering (och din förståelse för systemets komponenter). 

Utöver att ge **tekniska** och **projektledningsmässiga** detaljer ska du inkludera **test- och verifieringssteg** för att visa hur du säkerställt att varje del av lösningen fungerar som förväntat. Använd **skärmbilder** och **beskrivningar**.


## Syfte

Uppgiften syftar till att:

1. Visa dina kunskaper om infrastruktur, applikationsstack och säkerhetsåtgärder samt koppla dessa till ett projektledningsperspektiv.
2. Visa din färdighet i att implementera samt testa och verifiera funktionalitet i lösningen.


## Disposition
Din rapport ska inkludera följande sektioner:

### 1. Sammanfattning (10%)
   - Ge en övergripande beskrivning av projektets syfte, omfattning och mål.
   - Sammanfatta systemets huvudkomponenter och deras funktion.

### 2. Teknisk arkitektur och konfiguration (30%)

   - **Beskrivning:**

     - Redogör för Azure-infrastrukturen, inklusive:
       - Nätverkslayout (subnät, NSG-regler, intern/extern kommunikation).
       - Rollen för reverse proxy, bastion host, applikationsserver och databasserver.
     - Beskriv nyckelkonfigurationer (t.ex. Nginx-regler för reverse proxy, MySQL-inställningar).

   - **Verifiering:**
 
     - Ge steg-för-steg-instruktioner för hur du verifierade:
       - Korrekt nätverkskommunikation mellan komponenter.
       - NSG-regler (t.ex. lyckade eller blockerade anslutningsförsök).
     - Inkludera skärmbilder från konfigurationssidor och testresultat (t.ex. Azure-portalen, SSH-terminal).

### 3. Applikationsstack och funktionalitet (30%)

   - **Beskrivning:**

     - Beskriv applikationsstacken (LEMP: Linux, Nginx, MySQL, PHP).
     - Förklara flödet för kontaktformuläret - från användarinmatning till datalagring i databasen.

   - **Verifiering:**

     - Visa hur du testade:
       - Kontaktformuläret (t.ex. formulärinlämning, validering och datalagring).
       - Databasanslutning (t.ex. frågor mot databasen för att hämta sparad data).
     - Inkludera skärmbilder av formuläret i aktion och resultat från databasfrågor.

### 4. Säkerhet (20%)

   - **Beskrivning:**
  
     - Belys säkerhetsåtgärder som vidtagits (Ex. med NSG, ASG och SSH).
     
   - **Verifiering:**
     - Beskriv tester för:
       - SSH-anslutning (t.ex. lyckad åtkomst via bastion host).
       - NSG-regler (t.ex. blockerade och tillåtna anslutningar).
     - Ge skärmbilder som visar blockerade och tillåtna anslutningar.

### 5. Riskanalys (10%)

   - **Beskrivning:**
   
     - Identifiera potentiella risker (tekniska, operativa eller säkerhetsrelaterade) för lanseringen av webbplatsen.
     - Föreslå åtgärdsstrategier för varje identifierad risk.


### Inlämningsdetaljer

- **Format:** PDF-dokument (uppladdat på Google Classroom)
- **Längd:** Cirka 3–6 sidor (exklusive bilder).

---


# Tips: Bygg lösningen gradvis!

När du bygger lösningen och förbereder din rapport är det viktigt att du är metodiskt. Börja enkelt, säkerställ att varje komponent fungerar, och lägg sedan till mer komplexitet. På så sätt har du en fungerande lösning tidigt, även om säkerhet och arkiturella funktioner inte är fullt implementerade från början.

### 1. Fokusera på en Minimal Viable Product (MVP) först

- Börja med **kärnfunktionaliteten**:

  - Provisionera en enda VM med Nginx, PHP och MySQL.
  - Se till att kontaktformuläret fungerar och att formulärdata lagras i databasen.

Detta ger dig en fungerande grund att bygga vidare på innan du lägger till avancerade konfigurationer som säkerhet och nätverk.

### 2. Bygg upp lösningen gradvis i lager

Efter MVP, lägg till lager till lösningen en i taget och testa varje steg.

- **Steg 1: Grundläggande Nätverk**
  - Skapa ett virtuellt nätverk (VNet) med ett enda subnät.
  - Koppla applikationsservern till detta subnät och bekräfta att det går att nå via dess IP-adress.
  - Testa SSH-åtkomst.

- **Steg 2: Reverse Proxy**
  - Introducera Nginx som reverse proxy för att hantera inkommande trafik.
  - Testa att trafik till proxyn vidarebefordras korrekt till webbservern.
  - Kontrollera regelbundet (t.ex. med curl eller webbläsare) att det fungerar.

- **Steg 3: Databasserver**
  - Lägg till databasservern (MySQL).
  - Konfigurera applikationsservern (PHP-koden) att ansluta till databasservern.
  - Verifiera databasanslutningen och att data från formuläret lagras i databasen.

### 3. Arbeta tidigt med säkerhet

Även när du arbetar med grundläggande funktionalitet kan du implementera några viktiga säkerhetssteg:

- Använd SSH-nycklar för åtkomst till servrar.
- Begränsa inkommande trafik till nödvändiga portar (t.ex. port 22 för SSH, port 80 för HTTP) med hjälp av NSG.

### 4. Testa och verifiera kontinuerligt

Verifiera vid varje steg att din lösning fungerar som förväntat. Du kan använda dessa tekniker:

- **Manuella tester:** Testa anslutningar (t.ex. curl eller webbläsare och databassökningar).
- **Skärmbilder:** Ta skärmbilder när det fungerar av formulär, databassökningar, etc. Kör history.
- **Iterativ testning:** Efter att du gjort en förändring, testa arbetsflödet igen så att det fortfarande fungerar.

### 5. Lägg till avancerad säkerhet sist

När den grundläggande funktionaliteten är verifierad kan du fokusera på avancerade aspekter som:

- Implementera NSG, ASG och Service Tags.
- Provisionera en bastion host för säker SSH-åtkomst till interna servrar.

Säkerhets- och arkitekturella förbättringar bör byggas ovanpå en stabil och fungerande grund.

### 6. Använd Azure-portalen och CLI för verifiering

- **Portalen:** Använd Azure-portalen för visuell återkoppling av Azure CLI-kommandon (NSG-regler, nätverkstopologi, etc).

### 7. Gör noteringar

- Dokumentera varje steg medan du arbetar:
  - Vad du lade till eller ändrade.
  - Hur du testade det.
  - Vilka resultat du fick.
- Detta gör det enklare att skriva rapporten och att du inte glömmer något.


### Exempel

1. Provisionera och konfigurera en enda VM med Nginx, PHP och MySQL.
2. Testa kontaktformuläret för att säkerställa grundläggande funktionalitet.
3. Lägg till en reverse proxy och testa.
4. Separera databasen till en egen VM och testa app-till-databas-kommunikation.
5. Lägg till ASG och Service Tags.
6. Provisionera en Bastion Host och verifiera säker SSH-åtkomst.
7. Kör ett slutligt test av lösningen och ta skärmdumpar
