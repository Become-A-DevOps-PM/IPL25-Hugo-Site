# Uppgift 1 - Bakgrund

## Projektscenario: CM Corp

Studenterna har arbetat med ett fiktivt uppdrag från "CM Corp" där de agerar som IT-projektledare med ansvar för att leverera en teknisk lösning.

### Uppdrag (Business Demand)

Marknadsavdelningen på CM Corp har begärt skapandet av en enkel, användarvänlig webbplats för att marknadsföra ett kommande webinar.

Webbplatsen ska innehålla:
- Information om evenemanget
- Ett registreringsformulär för anmälan

### Affärsbehov (Business Needs)

| Nr | Behov | Beskrivning |
|----|-------|-------------|
| 1 | **Webinar-information** | En dedikerad webbsida med information om webinariet: ämne, datum, tid, agenda, talarprofilerna och övriga detaljer |
| 2 | **Registreringsformulär** | Ett funktionellt anmälningsformulär som samlar in deltagarinformation (namn, e-post, företag, titel). Formuläret ska ha datavalidering |
| 3 | **Skalbarhet** | Infrastrukturen ska hantera förväntade trafikspikar, särskilt när webinar-datumet närmar sig |
| 4 | **Tidplan** | Webbplatsen måste vara live till jul för att passa marknadsföringskampanjens schema |

## Lärandekontext

### Kursupplägg

Uppdraget genomfördes som ett praktiskt projekt där studenterna:

- **Arbetade i grupp** med gemensamt ansvar för lösningen
- **Deltog i veckovisa demonstrationer** där de visade framsteg och fick feedback
- **Tillämpade teoretisk kunskap** från föreläsningar och kursmaterial
- **Genomförde praktiska övningar** som byggde upp kompetens stegvis

### Agilt arbetssätt

Projektet följde ett agilt upplägg med:

- **Iterativ utveckling** - börja med MVP, lägg till funktionalitet successivt
- **Veckovisa demos** - visa fungerande delar, få feedback, justera
- **Kontinuerlig förbättring** - lär av misstag, dokumentera framsteg

### Teknisk progression

Studenterna förväntades bygga lösningen stegvis:

1. **Lokal utveckling** - Flask-applikation med SQLite
2. **Grundläggande deployment** - En VM i Azure med applikationen
3. **Databasintegration** - Azure Database for PostgreSQL
4. **Nätverkssegmentering** - VNet, subnät, NSG-regler
5. **Säkerhetsförbättringar** - Bastion host, HTTPS, SSH-nycklar
6. **Produktionsredo** - systemd, reverse proxy, övervakning

### AI-assistans

Studenterna uppmuntrades att använda AI-verktyg (Claude, ChatGPT, Copilot, Gemini) för:

- Förståelse av koncept
- Felsökning
- Generering av kod och konfigurationer
- Skrivande av scripts

**Viktigt:** Rapporten skulle skrivas av studenten själv, inte genereras av AI.

## Koppling till examination

Uppgift 1 (denna inlämning) examinerar studentens förmåga att:

1. **Kunskap:** Redogöra för hur IT-system och dess komponenter är uppbyggda
2. **Färdighet:** Bygga en fungerande IT-konfiguration och redovisa dess säkerhetsaspekter

För **Väl godkänt (VG)** krävs att studenten visar förmåga att tillämpa sina kunskaper för en mer säker och robust lösning.

## Referensmaterial

- [Presentation: Uppdrag CM Corp](/presentations/project-assignment.html)
- [Uppgiftsbeskrivning: assignment-1.md](assignment-1.md)
- [Kursbeskrivning: course-description.md](../course-description.md)
