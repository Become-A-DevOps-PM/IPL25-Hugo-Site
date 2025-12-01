# Repetition IPL25 – Vecka 1

Handwritten notes transcribed from 1dec.2025.pdf

---

## Allmänna reflektioner

### Teknisk sammanfattning

- **Server av webbapp** (full klient – browser)
  - Servar kod (HTML, CSS, JS) till browser över HTTP
- **Server som dator** (VM på Azure – Ubuntu Linux)
  - Storlek CPU+RAM, Disk m. OS, NIC + IP + NSG
- **Server med rollen Web Server** (nginx)
  - Servar tjänsten på en port och kör som daemon i bakgrunden

### Säkerhet (Defence In Depth)

- SSH (nycklar, ej password)
- chmod (filrättigheter)
- Brandvägg port 80 + 22
- Azure (username + password + 2FA)

### AI som medarbetare

- fråga → ge svar
- utreda → förklara
- planera → genomföra

### Context

- Intent
- Tech Stack, Tools

| Metodlista   | Konceptidéer |
|--------------|--------------|
| Scrum        | On Demand    |
| MVP          | XaC          |
| User Journey | DevOps       |
| GitOps       |              |

### Att göra

- [ ] Föreläsning – Artikel om SSH-nycklar
- [ ] Demo SCP av index.html

### Planering

Nedbrytning: affärsmodell (intent) → kravspec → user stories (epics) → Backlog → Kanban Board

Implementationsstrategi: MVP, Walking Skeleton, Rapid Prototyping, Spike (scrum)

↓ Designing feedback loops

### WBS-struktur

- Funktion, kvalitet, andra aspekter (juridik)
- Organisation (PPP: Product, People, Process)
- Verktyg & metoder

### Intent till User Stories

- Tools, Tech Stack, Architecture
- Sprints, Scrum, metodologi
- Stakeholders, kommunikation, presentation
- AI och "human in the loop", kunskapsspridning
- AI och "reverse break-up structure"

### Typiskt utvecklarteam

| Roll         | Antal |
|--------------|-------|
| Team leader  | 1     |
| Scrum master | 1     |
| Developers   | 3     |
| Testers (QA) | 1     |
| Architect    | 1     |
| Senior dev   | (1)   |

### System Under Review

- Svårigheten att begränsa ett system, speciellt under utveckling

### Kunskapskvadrant (Värande)

```text
            vet       vet ej
        ┌─────────┬─────────┐
    vet │  vet    │  vet ej │
        ├─────────┼─────────┤
 vet ej │  vet ej │  vet ej │
        └─────────┴─────────┘
```

### Feedback (allmänt)

- Tillgänglighetsanpassning
- Mätvärde för verktyg

---

## Feedback från grupper

### Grupp 1 – Tydlig presentation för context

- Lagt upp HTML-fil
- Verktyg: GitHub, Serverstruktur, SSH
- VS Code + Gemini

AI som kollega och värdeskapare → snabbt designerlook

Samsyn på hur det fungerar → skapa en baseline

Robust, många kan det mesta

Förstå varför det fungerar

Beslutslogg

Ambitiös plan.

### Grupp 2 – Snygg presentation med namn, samhörighet

- Tydlig återkoppling till affärsmodell
- Scrum, kanban, tidslinjer med milstolpar -> backlog
- Mycket visuell planering → gör det tydligt
- Insikt: VM är VM
- Alternativ lösning med vm under skrivbordet

### Grupp 3 – Snygg tydlig presentation

- Fint att visa en del redan i presentationerna
- AI: Intent → backlog
- Avgränsning: Design och layout
- Transparent hur man använder AI
- Tydlig retrospektiv → AI som mer än chat
  - [ ] GDPR, Frivilliga/obligatoriska
  - User Journey med registrerings-id
- Träffas IRL
- Feedback på layout vill de ha

### Grupp 4 – Todo-lista som kan utvecklas sedan

Allt gås igenom tillsammans → robust → alla med på tåget

- Extra: egen domän
- User Journey (med begränsningar)
- Scrum med user stories
- Fiskar efter feedback (bra)

### Grupp 5 – Spelregler för gruppen

- Sprint planering
- Designverktyg: CodePen
- Låg kostnad
- Ingen lagring (ger kontext)
- Kopiera fil i git bash → feedback: hur ska man göra?

### Grupp 6 – Ingen teknisk bakgrund

- Utmanande resa, tillsammans
- Gruppdynamik och samarbetsprocess

Intent → kravspecifikation → user stories

MVP ✓ finns med i backlog

- Gemini + ger instruktioner (förändra)
- Retro: tillsammans, med förberedelse individuellt → IRL

Kostnadsuppföljning.

- Alla med
- Hur man använder AI
- Att faktiskt kolla kostnad
- Förutsättningar
