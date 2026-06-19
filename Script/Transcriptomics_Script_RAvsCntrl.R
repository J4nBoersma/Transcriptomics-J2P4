############################################################
# RNA-seq Analyse Reuma
# Workflow:
# 1. Reference index bouwen
# 2. Aligneren
# 3. Read counting
# 4. Differential expression (DESeq2)
# 5. Volcano plot
# 6. KEGG analyse
# 7. Pathview visualisatie
# 8. GO analyse
############################################################

########################
# 1. Setup
########################

setwd("/Users/jan/Desktop/School/BML-2/Periode 4/Transcriptnomics/Casus REUMA/Data_RA_raw")

library(Rsubread)
library(DESeq2)
library(clusterProfiler)
library(org.Hs.eg.db)
library(EnhancedVolcano)
library(pathview)
library(KEGGREST)

########################
# 2. Reference index bouwen
########################

buildindex(
  basename = "ref_reuma",
  reference = "GCF_000001405.40_GRCh38.p14_genomic.fna",
  memory = 4000,
  indexSplit = TRUE
)

########################
# 3. Aligneren
########################

# Controle samples
align.cntrl1 <- align(
  index = "ref_reuma",
  readfile1 = "SRR4785819_1_subset40k.fastq",
  readfile2 = "SRR4785819_2_subset40k.fastq",
  output_file = "control1.BAM")

align.cntrl2 <- align(
  index = "ref_reuma",
  readfile1 = "SRR4785820_1_subset40k.fastq",
  readfile2 = "SRR4785820_2_subset40k.fastq",
  output_file = "control2.BAM")

align.cntrl3 <- align(
  index = "ref_reuma",
  readfile1 = "SRR4785828_1_subset40k.fastq",
  readfile2 = "SRR4785828_2_subset40k.fastq",
  output_file = "control3.BAM")

align.cntrl4 <- align(
  index = "ref_reuma",
  readfile1 = "SRR4785831_1_subset40k.fastq",
  readfile2 = "SRR4785831_2_subset40k.fastq",
  output_file = "control4.BAM")

# Reumatoïde artritis samples
align.reuma1 <- align(
  index = "ref_reuma",
  readfile1 = "SRR4785979_1_subset40k.fastq",
  readfile2 = "SRR4785979_2_subset40k.fastq",
  output_file = "patient1.BAM")

align.reuma2 <- align(
  index = "ref_reuma",
  readfile1 = "SRR4785980_1_subset40k.fastq",
  readfile2 = "SRR4785980_2_subset40k.fastq",
  output_file = "patient2.BAM")

align.reuma3 <- align(
  index = "ref_reuma",
  readfile1 = "SRR4785986_1_subset40k.fastq",
  readfile2 = "SRR4785986_2_subset40k.fastq",
  output_file = "patient3.BAM")

align.reuma4 <- align(
  index = "ref_reuma",
  readfile1 = "SRR4785988_1_subset40k.fastq",
  readfile2 = "SRR4785988_2_subset40k.fastq",
  output_file = "patient4.BAM")


########################
# 4. Read counting
########################

all.samples <- c(
  "control1.BAM",
  "control2.BAM",
  "control3.BAM",
  "control4.BAM",
  "patient1.BAM",
  "patient2.BAM",
  "patient3.BAM",
  "patient4.BAM"
)

count_matrix <- featureCounts(
  files = all.samples,
  annot.ext = "genomic.gtf",
  isPairedEnd = TRUE,
  isGTFAnnotationFile = TRUE,
  GTF.attrType = "gene_id",
  useMetaFeatures = TRUE
)

counts <- count_matrix$counts

colnames(counts) <- c(
  "control1",
  "control2",
  "control3",
  "control4",
  "patient1",
  "patient2",
  "patient3",
  "patient4"
)

write.csv(counts, "reuma_countmatrix.csv")

########################
# 5. DESeq2 analyse
########################

treatment_table <- data.frame(
  treatment = c(
    "control",
    "control",
    "control",
    "control",
    "patient",
    "patient",
    "patient",
    "patient"
  )
)

rownames(treatment_table) <- colnames(counts)

dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = treatment_table,
  design = ~ treatment
)

dds <- DESeq(dds)

resultaten <- results(dds)

write.csv(
  as.data.frame(resultaten),
  "Resultaten_RA.csv"
)

########################
# 6. Aantal significante genen
########################

upregulated <- sum(
  resultaten$padj < 0.05 &
    resultaten$log2FoldChange > 1,
  na.rm = TRUE
)

downregulated <- sum(
  resultaten$padj < 0.05 &
    resultaten$log2FoldChange < -1,
  na.rm = TRUE
)

cat("Aantal upregulated genen:", upregulated, "\n")
cat("Aantal downregulated genen:", downregulated, "\n")

########################
# 7. Top genen bekijken
########################

hoogste_fold_change <- resultaten[
  order(resultaten$log2FoldChange, decreasing = TRUE),
]

laagste_fold_change <- resultaten[
  order(resultaten$log2FoldChange),
]

laagste_p_waarde <- resultaten[
  order(resultaten$padj),
]

head(hoogste_fold_change)
head(laagste_fold_change)
head(laagste_p_waarde)

########################
# 8. Volcano plot
########################

EnhancedVolcano(
  resultaten,
  lab = rownames(resultaten),
  x = "log2FoldChange",
  y = "padj"
)

########################
# 9. Significante genen selecteren
########################

sig_genen <- subset(
  resultaten,
  padj < 0.05 &
    abs(log2FoldChange) > 1
)

cat("Aantal significante genen:", nrow(sig_genen), "\n")

########################
# 10. SYMBOL -> ENTREZID
########################

entrez_ids <- mapIds(
  org.Hs.eg.db,
  keys = rownames(sig_genen),
  column = "ENTREZID",
  keytype = "SYMBOL",
  multiVals = "first"
)

entrez_ids <- na.omit(entrez_ids)

########################
# 11. KEGG analyse
########################

kegg_result <- enrichKEGG(
  gene = entrez_ids,
  organism = "hsa",
  pvalueCutoff = 0.05
)

kegg_df <- as.data.frame(kegg_result)

head(kegg_df)

dotplot(
  kegg_result,
  showCategory = 10
)

barplot(
  kegg_result,
  showCategory = 10
)

########################
# 12. Pathview
########################

gene_data <- sig_genen$log2FoldChange
names(gene_data) <- entrez_ids

gene_data <- gene_data[
  !is.na(names(gene_data))
]

top_pathway <- kegg_df$ID[1]

pathview(
  gene.data = gene_data,
  pathway.id = top_pathway,
  species = "hsa"
)

# Rheumatoid arthritis pathway

pathview(
  gene.data = gene_data,
  pathway.id = "hsa05323",
  species = "hsa"
)

########################
# 13. GO analyse
########################

gene.df <- bitr(
  rownames(sig_genen),
  fromType = "SYMBOL",
  toType = "ENTREZID",
  OrgDb = org.Hs.eg.db
)

ego_bp <- enrichGO(
  gene = gene.df$ENTREZID,
  OrgDb = org.Hs.eg.db,
  keyType = "ENTREZID",
  ont = "BP",
  pAdjustMethod = "BH",
  pvalueCutoff = 0.05,
  qvalueCutoff = 0.05
)

go_results <- as.data.frame(ego_bp)

head(go_results)

########################
# 14. GO visualisatie
########################

dotplot(
  ego_bp,
  showCategory = 15,
  font.size = 8
)

png(
  "GO_dotplot_RA.png",
  width = 2000,
  height = 1500,
  res = 300
)

dotplot(
  ego_bp,
  showCategory = 15
)

dev.off()

########################
# 15. Zoek specifieke pathways
########################

grep(
  "Rheumatoid",
  kegg_df$Description,
  value = TRUE
)

grep(
  "TNF",
  kegg_df$Description,
  value = TRUE
)

grep(
  "IL-17",
  kegg_df$Description,
  value = TRUE
)

########################
# Einde analyse
########################
