

## J2P4 Project

## Inleiding

Reumatoïde artritis (RA) is een chronische systemische auto-immuunziekte die wordt gekenmerkt door persisterende synovitis, een ontsteking van het gewrichtsslijmvlies. Deze ontsteking leidt tot progressieve gewrichtsschade, waaronder erosie van kraakbeen en bot, wat uiteindelijk kan resulteren in functieverlies en invaliditeit. De pathogenese van RA is complex en ontstaat door een samenspel van genetische aanleg, omgevingsfactoren en een ontregeld immuunsysteem. Hierbij spelen immuuncellen zoals T-cellen en B-cellen een centrale rol in het ontstekingsproces en de productie van autoantistoffen (Firestein et al., 2017).
Een belangrijk kenmerk van RA is de aanwezigheid van autoantistoffen zoals ACPA (anti-citrullinated protein antibodies), die vaak al jaren vóór het ontstaan van klinische symptomen aanwezig kunnen zijn. Vroege diagnose en behandeling zijn essentieel om blijvende gewrichtsschade te beperken. Hoewel therapieën zoals DMARD’s de ziekteactiviteit kunnen remmen, blijft RA ongeneeslijk en is er behoefte aan beter inzicht in de moleculaire mechanismen achter de ziekte (Smolen et al., 2018).
Transcriptomics biedt hiervoor een krachtige methode om verschillen in genexpressie in ontstoken synovium te analyseren. Door middel van RNA-sequencing kunnen genen worden geïdentificeerd die differentieel tot expressie komen tussen RA-patiënten en controles. Vervolgens kan met Gene Ontology-analyse worden bepaald welke biologische processen en pathways betrokken zijn bij de ziekteontwikkeling.

## Methode
<img width="1536" height="1024" alt="ChatGPT Image Jun 18, 2026 at 01_59_02 PM" src="https://github.com/user-attachments/assets/06ed6154-cc72-489e-8a4f-5b4f23e5d839" />


Voor dit onderzoek is gebruikgemaakt van RNA-sequencing (RNA-seq) data afkomstig van synoviumbiopten. De dataset bestaat uit acht samples: vier van controles zonder reumatoïde artritis (RA) en vier van RA-patiënten met een ziekteduur van >12 maanden. Alle patiënten waren ACPA-positief, terwijl controles ACPA-negatief waren. De data zijn afkomstig uit Platzer et al. (2019).

De analyse is uitgevoerd in R. Eerst is het humane referentiegenoom GRCh38.p14 (GCF_000001405.40) geïndexeerd met behulp van het R-package Rsubread (v2.24.0). Vervolgens zijn paired-end reads uitgelijnd tegen dit referentiegenoom, waarna BAM-bestanden zijn gegenereerd voor alle samples.

Op basis van de alignments is met featureCounts een gen-level countmatrix opgesteld met behulp van een GTF-annotatiebestand. Deze matrix vormde de input voor downstream analyse in DESeq2 (v1.50.2). Na normalisatie is een differentiële expressieanalyse uitgevoerd om genen te identificeren met significante expressieveranderingen tussen RA- en controlegroepen (padj < 0.05, |log2FC| > 1).

Voor visualisatie is een volcano plot gegenereerd met EnhancedVolcano. Daarnaast zijn significant differentieel tot expressie komende genen geselecteerd voor functionele verrijkingsanalyses. Gene Ontology (GO)-analyse is uitgevoerd met clusterProfiler, waarbij biologische processen, cellulaire componenten en moleculaire functies zijn onderzocht. KEGG pathway-analyse is gebruikt om verrijkte signaalroutes te identificeren. Visualisatie van pathways is uitgevoerd met pathview


## Resultaten


### Volcano plot

![Volcano plot](Resultaten/Vulcanoplot-WC3.png)

*Figuur 1. Volcano plot van de differentiële genexpressieanalyse tussen synoviumbiopten van RA-patiënten (n = 4) en gezonde controles (n = 4), uitgevoerd met DESeq2. De x-as geeft de log₂ fold change weer en de y-as de −log₁₀ p-waarde. Rode punten vertegenwoordigen genen met een significante verandering in expressie.*

### Kegg-Analyse
<p align="center">
  <img src="Resultaten/Rplot - dotplot kegg png.png" width="49%" />
  <img src="Resultaten/Rplot - balken.kegg.png" width="49%" />
</p> 

*Figuur 2. KEGG-analyse van differentieel tot expressie gebrachte genen tussen RA-patiënten en een gezonde controle. Dotplot van de verrijkte KEGG-pathways, waarbij de grootte van de punten het aantal genen per pathway weergeeft en de kleur de gecorrigeerde p-waarde representeert (Links). Barplot van de meest verrijkte KEGG-pathways, weergegeven op basis van het aantal tot expressie gebrachte genen (Rechts).*

### Go-Analyse
![Dotplot Go-analyse](Resultaten/Rplot%20-%20go.analyse.dotplot.png)


*Figuur 3. GO-enrichmentanalyse van differentieel tot expressie komende genen in synovium (RA vs. controle). De dotplot toont significante verrijkte biologische processen (padj < 0,05). De x-as geeft de GeneRatio weer, de grootte van de punten het aantal genen per term en de kleur de significantie.*


### Pathwayview-Analyse
<p align="center">
  <img src="Resultaten/hsa05323.png" width="49%" />
  <img src="Resultaten/hsa05323.pathview.png" width="49%" />
</p>



## Conclusie
