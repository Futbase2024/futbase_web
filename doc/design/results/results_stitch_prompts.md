# Prompts de Stitch - Feature Resultados

> Proyecto: FutBase 3.0
> Feature: Results (Live Scores)
> Fecha: 2026-02-20

---

## Configuracion Stitch

```json
{
  "projectId": "10448117637612065749",
  "deviceType": "DESKTOP",
  "modelId": "GEMINI_3_PRO"
}
```

---

## Prompt 1: Results Page - Vista Principal

```
Design a Results Page for FutBase - a football club management app.

Design System:
- Theme: Light Mode (OBLIGATORIO)
- Background: #F5F5F5 (page), #FFFFFF (cards)
- Primary: #00554E (green dark)
- Accent: #A4EC13 (green neon - for LIVE indicators)
- Text: #1F2937 (primary), #6B7280 (secondary), #9CA3AF (muted)
- Borders: #E5E7EB, radius 12px (cards), 8px (inputs)
- Font: Lexend (headings bold, body normal)
- Shadows: shadow-sm (cards)

Screen: Results Page

Layout:
- Header with title "Resultados" and a toggle button "EN VIVO" (with pulsing green dot)
- Filter bar with: date range picker, team dropdown, status chips (Live/Scheduled/Finished)
- Content area: List grouped by date

Date Group Header:
- Date label (e.g., "Hoy", "Ayer", "Sabado, 15 Febrero")
- Subtle horizontal line

Live Match Card (special design):
- Border: 2px solid #A4EC13 (green neon)
- Top badge: Animated pulsing green dot + "EN VIVO" + "67'" (minute)
- Center: Team shields (48x48) with score below
  - Left: My team shield, name, goals (larger font)
  - Center: "-" separator
  - Right: Rival shield, name, goals
- Bottom: Field name and competition name
- Subtle pulsing glow effect on the card border

Normal Match Card:
- White background, 12px border radius
- Top row: Date (small) | Status badge (Victoria/Derrota/Empate with colors)
- Center: Same layout as live card but static
- Status badges:
  - Victoria: Green bg #EAF7EF, text #078830
  - Derrota: Red bg #FEF2F2, text #FA4838
  - Empate: Gray bg, gray text
  - Programado: Blue bg #EFF6FF, blue text

Scheduled Match Card:
- Similar to normal card
- Shows "Programado" badge
- No score, shows "- : -"
- Shows time (e.g., "18:00")

Empty State:
- Icon: soccer ball outline (64px, gray)
- Text: "No hay partidos para mostrar"
- Subtext: "Prueba a cambiar los filtros"

Components to create:
1. ResultsFilterBar - Horizontal bar with filters
2. ResultsDateGroup - Date header with matches list
3. ResultsLiveMatchCard - Animated live match with pulsing indicator
4. ResultsMatchCard - Standard match card for finished/scheduled
5. ResultsEmptyState - Empty state illustration

States to design:
- Loaded (with live matches + finished + scheduled)
- Empty (no matches)
- Loading (skeleton cards)

Responsive:
- Desktop: 3 cards per row
- Tablet: 2 cards per row
- Mobile: 1 card per row (stacked)
```

---

## Prompt 2: Live Match Card Component

```
Design a Live Match Card component for FutBase football app.

Design System:
- Theme: Light Mode
- Primary: #00554E (green dark)
- Accent: #A4EC13 (green neon)
- Background: #FFFFFF
- Text: #1F2937 (primary), #6B7280 (secondary)

Component: LiveMatchCard

Layout (vertical):
1. Top Badge Row:
   - Animated pulsing green dot (8px) - CSS animation: pulse 1s infinite
   - "EN VIVO" text in accent color, bold, uppercase
   - Minute display: "67'" in accent color

2. Teams Score Section (main content):
   - Two columns with center separator
   - Each team column:
     - Team shield (circular, 48x48, with fallback icon)
     - Team name (short, max 10 chars)
     - Goals (large font, 32px, bold)
   - Center: "-" separator (24px, gray)

3. Bottom Info Row:
   - Field name (small, gray)
   - Competition name (small, gray)

Card Container:
- Background: white
- Border: 2px solid #A4EC13
- Border radius: 16px
- Padding: 16px
- Shadow: subtle glow effect (green neon blur)

Animation:
- Pulsing dot animation (1s ease-in-out infinite)
- Optional: subtle border glow pulse

Example data:
- Home: Real Madrid (shield url), 2
- Away: FC Barcelona (shield url), 1
- Minute: 67'
- Field: Santiago Bernabeu
- Competition: La Liga
```

---

## Prompt 3: Results Filter Bar

```
Design a Filter Bar component for the Results page in FutBase.

Design System:
- Theme: Light Mode
- Primary: #00554E
- Background: #FFFFFF
- Border: #E5E7EB
- Radius: 8px (inputs), 20px (chips)

Component: ResultsFilterBar

Layout (horizontal, wrapped on mobile):
1. Date Range Picker:
   - Two inputs: "Desde" and "Hasta"
   - Calendar icon on the left
   - Date format: DD/MM/YYYY
   - Clearable (X button when has value)

2. Team Dropdown:
   - Label: "Equipo"
   - Dropdown with all teams of the club
   - Default: "Todos los equipos"
   - Width: ~200px

3. Status Filter Chips (horizontal scroll):
   - "En Vivo" - Green accent, pulsing dot
   - "Programados" - Blue
   - "Finalizados" - Gray
   - Single select (only one active at a time)
   - Pill shaped (border radius 20px)

4. Clear Filters Button:
   - Icon: close/X
   - Text: "Limpiar"
   - Appears only when filters are active
   - Ghost button style

States:
- Default (no filters)
- Active (some filters applied)
- Hover states on all interactive elements

Mobile:
- Stack vertically
- Full width inputs
- Horizontal scroll for chips
```

---

## Notas de Implementacion

1. El indicador "EN VIVO" debe usar animacion CSS pulsante
2. Los escudos de equipos pueden ser URLs o iconos fallback
3. Los colores de badges de resultado (V/D/E) deben ser consistentes
4. El modo "EN VIVO" activa actualizacion automatica cada 30 segundos
5. Pull-to-refresh disponible en la lista

---

**Proximo paso**: Ejecutar estos prompts en Stitch y descargar los HTMLs.
