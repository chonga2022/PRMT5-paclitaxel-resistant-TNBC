#####
#heatmap (436 20ABC VS PAR)
data1 <- read.csv("D:/wj/RNA_seq/20ABC VS PAR GO/GSEA_GO_20AvsPAR.csv",sep = ",",stringsAsFactors = F)
data2 <- read.csv("D:/wj/RNA_seq/20ABC VS PAR GO/GSEA_GO_20BvsPAR.csv",sep = ",",stringsAsFactors = F)
data3 <- read.csv("D:/wj/RNA_seq/20ABC VS PAR GO/GSEA_GO_20CvsPAR.csv",sep = ",",stringsAsFactors = F)
b1=merge(data1,data2,by='X')
b2=merge(b1,data3,by='X')
write.csv(b2,'D:/wj/RNA_seq/20ABC VS PAR GO/Commonsamples.csv')

selected_rows <- b2[b2$X %in% c("GOCC_DNA_PACKAGING_COMPLEX", "GOBP_NUCLEOSOME_ASSEMBLY", "GOCC_PROTEIN_DNA_COMPLEX"), ]

selected_cells <- c(selected_rows[3, 12],selected_rows[3, 23], selected_rows[3, 34])
merged_content <- unlist(selected_cells)
print(merged_content)

split_cells <- lapply(strsplit(merged_content, "/"), sort) 
common_elements <- Reduce(intersect, split_cells)
common_values <- data.frame(GENE = common_elements)
common_values$GENE<- sub("^\\s+", "", common_values$GENE)

#input
data1 <- read.csv("D:/wj/RNA_seq/tpm.csv",sep = ",",stringsAsFactors = F)
extract_content <- function(input_string) {
  result <- sub("^[^|]*\\|([^|]*)\\|.*$", "\\1", input_string)
  return(result)
}
# 
data1$ENSEMBL <- sapply(data1$target_id, extract_content)
print(data1$ENSEMBL)
install.packages("stringr")
library(stringr)
data1$ENSEMBL=str_split(data1$ENSEMBL,'[.]',simplify = T)[,1]
data1 <- data1[!duplicated(data1$ENSEMBL), ]
library(clusterProfiler)
id=bitr(data1$ENSEMBL,'ENSEMBL',c('ENTREZID','SYMBOL'),'org.Hs.eg.db')
head(id,3)
keytypes(org.Hs.eg.db)
#match id
b1=merge(id,data1,by='ENSEMBL')
b1 <- b1[!duplicated(b1$SYMBOL), ]
rownames(b1)<- b1$SYMBOL
selected_columns <- b1[, grepl("MDAMB436", names(b1))]
countdata <-selected_columns[, grepl("DMSO", names(selected_columns))]
heatmap_input <- countdata[rownames(countdata) %in% common_values$GENE, ]
print(colnames(heatmap_input))
tmp <- heatmap_input[, c("Q1._MDAMB436.Par.DMSO.Rep1_S1", "Q13._MDAMB436.Par.DMSO.Rep2_S13", 
                         "Q4._MDAMB436.20A.DMSO.Rep1_S29", "Q16._MDAMB436.20A.DMSO.Rep2_S16", 
                         "Q19._MDAMB436.20B.DMSO.Rep2_S19", "Q7._MDAMB436.20B.DMSO.Rep1_S7", 
                         "Q10._MDAMB436.20C.DMSO.Rep1_S10", "Q22._MDAMB436.20C.DMSO.Rep2_S22")]
library(pheatmap)

num_cols <- ncol(tmp)
num_groups <- num_cols / 2

# 
result_df <- data.frame(matrix(0, nrow = nrow(tmp), ncol = num_groups))

# 
for (i in 1:num_groups) {
  start_col <- 2 * i - 1
  end_col <- 2 * i
  result_df[, i] <- apply(tmp[, start_col:end_col], 1, mean)
}

# 
print(result_df)
rownames(result_df)<-rownames(tmp)
colnames(result_df) <- c("MDAMB436.Par", "MDAMB436.20A","MDAMB436.20B", "MDAMB436.20C")
p<-pheatmap(result_df, cluster_cols=FALSE,cluster_rows=FALSE,fontsize = 6,cellwidth = 10,cellheight = 10,main ="1_NUCLEOSOME_ASSEMBLY",scale = "row")


#####
##RNA seq data (DE of 20ABC LLY283 VS DMSO)
data1 <- read.csv("D:/wj/RNA_seq/count.csv",sep = ",",stringsAsFactors = F)
extract_content <- function(input_string) {
  result <- sub("^[^|]*\\|([^|]*)\\|.*$", "\\1", input_string)
  return(result)
}
# 
data1$id <- sapply(data1$target_id, extract_content)
print(data1$id)
data1 <- data1[!duplicated(data1$id), ]
selected_columns <- data1[, grepl("MDAMB436", names(data1))]
countdata <-selected_columns[, grepl("20C", names(selected_columns))]
rownames(countdata)<-data1$id
countdata <- countdata[, -c(2, 6)]
print(colnames(countdata))
countdata <- countdata[, c("Q10._MDAMB436.20C.DMSO.Rep1_S10", "Q22._MDAMB436.20C.DMSO.Rep2_S22", 
                           "Q24._MDAMB436.20C.1uM_LLY283.Rep2_S24", "Q12._MDAMB436.20C.1uM_LLY283.Rep1_S31")]


##DEseq
library(DESeq2)
library(dplyr)
#
coldata <- data.frame(
  row.names = c("Q10._MDAMB436.20C.DMSO.Rep1_S10", "Q22._MDAMB436.20C.DMSO.Rep2_S22", 
                "Q24._MDAMB436.20C.1uM_LLY283.Rep2_S24", "Q12._MDAMB436.20C.1uM_LLY283.Rep1_S31"),
  condition = c("Con","Con",  "Treat",  "Treat")
)

all(rownames(coldata) %in% colnames(countdata))  
all(rownames(coldata) == colnames(Res))
## 
countdata = countdata[rowMeans(countdata) > 1,]
countdata <- round(countdata)
## 
dds <-  DESeqDataSetFromMatrix(countData=countdata,colData = coldata,design = ~ condition) 
dim(dds)
## 
dds <- dds[rowSums(counts(dds)) > 1,]  
nrow(dds)
## 
dep <- DESeq(dds)
res <- results(dep)
diff = res
dim(res)
diff <- na.omit(diff)  
dim(diff)
write.csv(diff,"D:/wj/RNA_seq/20ABC LLY283 VS DMSO/436_20C_LLY283_all_diff.csv")  

#####
#GSEA (20ABC LLY283 VS DMSO)
BAF299 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO/436_20B_LLY283_all_diff.csv",sep = ",",stringsAsFactors = F)
library(stringr)
library(clusterProfiler)
#BiocManager::install('msigdbr')
library('msigdbr')
library(dplyr)
library(enrichplot)
BAF299$X=str_split(BAF299$X,'[.]',simplify = T)[,1]
BAF299 <- BAF299[!duplicated(BAF299$X), ]
rownames(BAF299)=BAF299$X
genelist=BAF299$log2FoldChange

names(genelist)=row.names(BAF299)
head(genelist)
id=bitr(names(genelist),'ENSEMBL',c('ENTREZID','SYMBOL'),'org.Hs.eg.db')
head(id,3)
keytypes(org.Hs.eg.db)
#match id
genelist=genelist[names(genelist) %in% id[,1]]
names(genelist)=id[match(names(genelist),id[,1]),3]
head(genelist,3)

geneset <- read.gmt("D:/single cell data/pathway human/human pathway/symbol/c5.go.v2023.1.Hs.symbols.gmt") 

#GSEA analysis
genelist=sort(genelist,decreasing = T)
GSEA_hallmark=GSEA(genelist,TERM2GENE = geneset,pvalueCutoff = 3)
head(GSEA_hallmark,5)
write.csv(GSEA_hallmark,'D:/wj/RNA_seq/GO/Hs578 20A 20B After treatment/GSEA_GO_MDAMB436_20B_LLY283.csv', row.names = F)
lol_hs <- read.csv("D:/wj/RNA_seq/GO/Hs578 20A 20B After treatment/GSEA_GO_MDAMB436_20B_LLY283.csv",sep = ",",stringsAsFactors = F)

lol_hs2=lol_hs[lol_hs$p.adjust<0.05,]
library(ggplot2)
lol_hs<-tmp1[order(tmpHUOD1$NES),]
ggplot(lol_hs,aes(x=NES,y=Description))+
  theme_test()+
  geom_line()+geom_segment(aes(x=0,xend=NES,y=Description,yend=Description))+
  geom_point(aes(color=-log10(pvalue)),size=5)+
  ylim(lol_hs$Description)+
  geom_vline(aes(xintercept=0))+
  scale_color_gradient(low = "blue",high = "red")+ 
  labs(y="Pathway",title="GO_Hs578T_20B_LLY283")+
  theme(title=element_text(face="bold",size=12,color="black",
                           vjust = 0.5,hjust = 0.5),
        axis.title.x = element_text(face = 'bold',size = 10,
                                    vjust = 0.5,hjust = 0.5),
        axis.title.y = element_text(face = 'bold',size = 10,
                                    angle = 90,vjust = 0.5,hjust = 0.5),
        axis.text.x = element_text(face = 'bold',size = 10),
        axis.text.y = element_text(face = 'bold',size = 10)) 

gseaplot2(GSEA_hallmark,title='GOBP_NUCLEOSOME_ASSEMBLY',
          geneSetID = 'GOBP_NUCLEOSOME_ASSEMBLY')

#####
#heatmap (20ABC aftertreatment of LLY283)
geneset1<- read.csv("D:/wj/geneset/GOCC_PROTEIN_DNA_COMPLEX.v2023.1.Hs.csv",sep = ",",stringsAsFactors = F)
##pick up significant DE genes
DE1 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO/436_20A_LLY283_all_diff.csv")
DE2 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO/436_20B_LLY283_all_diff.csv")
DE3 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO/436_20C_LLY283_all_diff.csv") 
b1=merge(DE1,DE2,by='X')
b2=merge(b1,DE3,by='X')
colnames(b2)[colnames(b2) == "X"] <- "ENSEMBL"
b2$ENSEMBL=str_split(b2$ENSEMBL,'[.]',simplify = T)[,1]
b2 <- b2[!duplicated(b2$ENSEMBL), ]
id=bitr(b2$ENSEMBL,'ENSEMBL',c('ENTREZID','SYMBOL'),'org.Hs.eg.db')
head(id,3)
#match id
b3=merge(id,b2,by='ENSEMBL')
b3 <- b3[!duplicated(b3$SYMBOL), ]
rownames(b3)<- b3$SYMBOL
print(colnames(geneset1))
colnames(geneset1)[colnames(geneset1) == "GOCC_PROTEIN_DNA_COMPLEX"] <- "SYMBOL"
b4=merge(geneset1,b3,by='SYMBOL')
selected_rows <- b4[b4$log2FoldChange.x < 0 & b4$log2FoldChange.y < 0 & b4$log2FoldChange < 0, ]

#input data
input <- read.csv("D:/wj/RNA_seq/tpm.csv",sep = ",",stringsAsFactors = F)
extract_content <- function(input_string) {
  result <- sub("^[^|]*\\|([^|]*)\\|.*$", "\\1", input_string)
  return(result)
}
# 
input$ENSEMBL <- sapply(input$target_id, extract_content)
print(input$ENSEMBL)
input$ENSEMBL=str_split(input$ENSEMBL,'[.]',simplify = T)[,1]
input <- input[!duplicated(input$ENSEMBL), ]
id=bitr(input$ENSEMBL,'ENSEMBL',c('ENTREZID','SYMBOL'),'org.Hs.eg.db')
head(id,3)
#match id
input1=merge(id,input,by='ENSEMBL')
input1 <- input1[!duplicated(input1$SYMBOL), ]
rownames(input1)<- input1$SYMBOL
selected_columns <- input1[, grepl("MDAMB436", names(input1))]
countdata <-selected_columns[, !grepl("GSK591", names(selected_columns))]
countdata <-countdata[, !grepl("Par", names(countdata))] 
heatmap_input <- countdata[rownames(countdata) %in% selected_rows$SYMBOL, ]
print(colnames(heatmap_input))
tmp <- heatmap_input[, c("Q4._MDAMB436.20A.DMSO.Rep1_S29", "Q16._MDAMB436.20A.DMSO.Rep2_S16", 
                         "Q18._MDAMB436.20A.1uM_LLY283.Rep2_S18", "Q6._MDAMB436.20A.1uM_LLY283.Rep1_S6", 
                         "Q19._MDAMB436.20B.DMSO.Rep2_S19", "Q7._MDAMB436.20B.DMSO.Rep1_S7", 
                         "Q21._MDAMB436.20B.1uM_LLY283.Rep2_S21", "Q9._MDAMB436.20B.1uM_LLY283.Rep1_S9", 
                         "Q10._MDAMB436.20C.DMSO.Rep1_S10", "Q22._MDAMB436.20C.DMSO.Rep2_S22", 
                         "Q24._MDAMB436.20C.1uM_LLY283.Rep2_S24", "Q12._MDAMB436.20C.1uM_LLY283.Rep1_S31")]


library(pheatmap)

num_cols <- ncol(tmp)
num_groups <- num_cols / 2

# 
result_df <- data.frame(matrix(0, nrow = nrow(tmp), ncol = num_groups))

# 
for (i in 1:num_groups) {
  start_col <- 2 * i - 1
  end_col <- 2 * i
  result_df[, i] <- apply(tmp[, start_col:end_col], 1, mean)
}

# 
print(result_df)
rownames(result_df)<-rownames(tmp)
colnames(result_df) <- c("MDAMB436.20A.DMSO", "MDAMB436.20A.1uM_LLY283","MDAMB436.20B.DMSO", "MDAMB436.20B.1uM_LLY283","MDAMB436.20C.DMSO", "MDAMB436.20C.1uM_LLY283")
p<-pheatmap(result_df, cluster_cols=FALSE,cluster_rows=T,fontsize = 6,cellwidth = 10,cellheight = 10,main ="GOCC_PROTEIN_DNA_COMPLEX",scale = "row")


#####
#RNA seq data 
data1 <- read.csv("D:/wj/RNA_seq/count.csv",sep = ",",stringsAsFactors = F)
extract_content <- function(input_string) {
  result <- sub("^[^|]*\\|([^|]*)\\|.*$", "\\1", input_string)
  return(result)
}
# 
data1$id <- sapply(data1$target_id, extract_content)
print(data1$id)
data1 <- data1[!duplicated(data1$id), ]
selected_columns <- data1[, grepl("Hs578T", names(data1))]
countdata <-selected_columns[, grepl("20A", names(selected_columns))]
rownames(countdata)<-data1$id
countdata <- countdata[, -2]
print(colnames(countdata))


library(edgeR)
group_list <- factor(c(rep("Contral",1),rep("Treat",1)))
exprSet <- DGEList(counts = countdata, group = group_list)
bcv = 0.1  
et <- exactTest(exprSet, dispersion=bcv^2)
write.csv(topTags(et, n = nrow(exprSet$counts)), 'D:/wj/RNA_seq/tmp', quote = FALSE)   

#GSEA 
BAF299 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO DE/DE_HS578T_20A_LLY283.csv",sep = ",",stringsAsFactors = F)
library(stringr)
library(clusterProfiler)
#BiocManager::install('msigdbr')
library('msigdbr')
library(dplyr)
library(enrichplot)
BAF299$X=str_split(BAF299$X,'[.]',simplify = T)[,1]
BAF299 <- BAF299[!duplicated(BAF299$X), ]
rownames(BAF299)=BAF299$X
genelist=BAF299$logFC

names(genelist)=row.names(BAF299)
head(genelist)
id=bitr(names(genelist),'ENSEMBL',c('ENTREZID','SYMBOL'),'org.Hs.eg.db')
head(id,3)
keytypes(org.Hs.eg.db)
#match id
genelist=genelist[names(genelist) %in% id[,1]]
names(genelist)=id[match(names(genelist),id[,1]),2]
head(genelist,3)

geneset <- read.gmt("D:/single cell data/pathway human/human pathway/c5.all.v2023.1.Hs.entrez.gmt") 

#GSEA analysis
genelist=sort(genelist,decreasing = T)
GSEA_hallmark=GSEA(genelist,TERM2GENE = geneset,pvalueCutoff = 0.05)
head(GSEA_hallmark,5)
write.csv(GSEA_hallmark,'D:/wj/RNA_seq/GO/SEA_GO_Hs578T_20A_LLY283.csv', row.names = F)

#####
#heatmap (436 ABC aftertreatment of LLY283)
geneset1<- read.csv("D:/wj/geneset/GOCC_DNA_PACKAGING_COMPLEX.v2023.1.Hs.csv",sep = ",",stringsAsFactors = F)
##pick up significant DE genes
DE1 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO DE/436_20A_LLY283_all_diff.csv")
DE2 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO DE/436_20B_LLY283_all_diff.csv")
DE3 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO DE/436_20C_LLY283_all_diff.csv") 
DE4 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO DE/DE_HS578T_20A_LLY283.csv") 
DE5 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO DE/DE_HS578T_20B_LLY283.csv") 
b1=merge(DE1,DE2,by='X')
b4=merge(b1,DE3,by='X')
b3=merge(b4,DE4,by='X')
b2=merge(b3,DE5,by='X')
library(stringr)
colnames(b2)[colnames(b2) == "X"] <- "ENSEMBL"
b2$ENSEMBL=str_split(b2$ENSEMBL,'[.]',simplify = T)[,1]
b2 <- b2[!duplicated(b2$ENSEMBL), ]
library(clusterProfiler)
library('msigdbr')
library(dplyr)
id=bitr(b2$ENSEMBL,'ENSEMBL',c('ENTREZID','SYMBOL'),'org.Hs.eg.db')
head(id,3)
#match id
b3=merge(id,b2,by='ENSEMBL')
b3 <- b3[!duplicated(b3$SYMBOL), ]
rownames(b3)<- b3$SYMBOL
print(colnames(geneset1))
colnames(geneset1)[colnames(geneset1) == "GOCC_DNA_PACKAGING_COMPLEX"] <- "SYMBOL"
b4=merge(geneset1,b3,by='SYMBOL')
selected_rows <- b4[b4$log2FoldChange.x < 0 & b4$log2FoldChange.y < 0 & b4$log2FoldChange < 0 & b4$logFC.x < 0 & b4$logFC.y < 0,]

#input data
input <- read.csv("D:/wj/RNA_seq/tpm.csv",sep = ",",stringsAsFactors = F)
extract_content <- function(input_string) {
  result <- sub("^[^|]*\\|([^|]*)\\|.*$", "\\1", input_string)
  return(result)
}
# 
input$ENSEMBL <- sapply(input$target_id, extract_content)
print(input$ENSEMBL)
input$ENSEMBL=str_split(input$ENSEMBL,'[.]',simplify = T)[,1]
input <- input[!duplicated(input$ENSEMBL), ]
id=bitr(input$ENSEMBL,'ENSEMBL',c('ENTREZID','SYMBOL'),'org.Hs.eg.db')
head(id,3)
#match id
input1=merge(id,input,by='ENSEMBL')
input1 <- input1[!duplicated(input1$SYMBOL), ]
rownames(input1)<- input1$SYMBOL
selected_columns <- input1[, grepl("MDAMB436", names(input1))]
countdata <-selected_columns[, !grepl("GSK591", names(selected_columns))]
countdata <-countdata[, !grepl("Par", names(countdata))] 
heatmap_input <- countdata[rownames(countdata) %in% selected_rows$SYMBOL, ]
print(colnames(heatmap_input))
tmp <- heatmap_input[, c("Q4._MDAMB436.20A.DMSO.Rep1_S29", "Q16._MDAMB436.20A.DMSO.Rep2_S16", 
                         "Q18._MDAMB436.20A.1uM_LLY283.Rep2_S18", "Q6._MDAMB436.20A.1uM_LLY283.Rep1_S6", 
                         "Q19._MDAMB436.20B.DMSO.Rep2_S19", "Q7._MDAMB436.20B.DMSO.Rep1_S7", 
                         "Q21._MDAMB436.20B.1uM_LLY283.Rep2_S21", "Q9._MDAMB436.20B.1uM_LLY283.Rep1_S9", 
                         "Q10._MDAMB436.20C.DMSO.Rep1_S10", "Q22._MDAMB436.20C.DMSO.Rep2_S22", 
                         "Q24._MDAMB436.20C.1uM_LLY283.Rep2_S24", "Q12._MDAMB436.20C.1uM_LLY283.Rep1_S31")]


library(pheatmap)

num_cols <- ncol(tmp)
num_groups <- num_cols / 2

result_df <- data.frame(matrix(0, nrow = nrow(tmp), ncol = num_groups))

for (i in 1:num_groups) {
  start_col <- 2 * i - 1
  end_col <- 2 * i
  result_df[, i] <- apply(tmp[, start_col:end_col], 1, mean)
}

print(result_df)
rownames(result_df)<-rownames(tmp)


#####
#MDAMB436 20ABC VS PAR bubble (add pvalue) @fig2a

tmp1 <- read.csv("D:/wj/RNA_seq/436 20ABC VS PAR/GSEA_GO_20AvsPAR.csv",sep = ",",stringsAsFactors = F)
tmp2 <- read.csv("D:/wj/RNA_seq/436 20ABC VS PAR/GSEA_GO_20BvsPAR.csv",sep = ",",stringsAsFactors = F)
tmp3 <- read.csv("D:/wj/RNA_seq/436 20ABC VS PAR/GSEA_GO_20CvsPAR.csv",sep = ",",stringsAsFactors = F)
selected_rows1 <-tmp1[tmp1$ID %in% c("GOCC_DNA_PACKAGING_COMPLEX",
                                     "GOBP_NUCLEOSOME_ASSEMBLY",
                                     "GOCC_PROTEIN_DNA_COMPLEX",
                                     "GOBP_DNA_PACKAGING",
                                     "GOBP_NUCLEOSOME_ORGANIZATION",
                                     "GOBP_DNA_CONFORMATION_CHANGE",
                                     "GOBP_NEGATIVE_REGULATION_OF_GENE_EXPRESSION_EPIGENETIC",
                                     "GOBP_CHROMATIN_ASSEMBLY_OR_DISASSEMBLY",
                                     "GOBP_MITOTIC_SISTER_CHROMATID_SEGREGATION",
                                     "GOBP_SISTER_CHROMATID_SEGREGATION",
                                     "GOBP_NUCLEAR_CHROMOSOME_SEGREGATION",
                                     "GOBP_CHROMOSOME_SEGREGATION",
                                     "GOBP_PROTEIN_DNA_COMPLEX_SUBUNIT_ORGANIZATION",
                                     "GOCC_CONDENSED_CHROMOSOME_CENTROMERIC_REGION",
                                     "GOBP_CHROMATIN_ORGANIZATION_INVOLVED_IN_REGULATION_OF_TRANSCRIPTION",
                                     "GOBP_MITOTIC_NUCLEAR_DIVISION",
                                     "GOCC_CHROMOSOME_CENTROMERIC_REGION",
                                     "GOBP_RDNA_HETEROCHROMATIN_ASSEMBLY",
                                     "GOMF_PROTEIN_HETERODIMERIZATION_ACTIVITY",
                                     "GOBP_DNA_REPLICATION_DEPENDENT_NUCLEOSOME_ORGANIZATION"), ]
selected_rows2 <-tmp2[tmp2$ID %in% c("GOCC_DNA_PACKAGING_COMPLEX",
                                     "GOBP_NUCLEOSOME_ASSEMBLY",
                                     "GOCC_PROTEIN_DNA_COMPLEX",
                                     "GOBP_DNA_PACKAGING",
                                     "GOBP_NUCLEOSOME_ORGANIZATION",
                                     "GOBP_DNA_CONFORMATION_CHANGE",
                                     "GOBP_NEGATIVE_REGULATION_OF_GENE_EXPRESSION_EPIGENETIC",
                                     "GOBP_CHROMATIN_ASSEMBLY_OR_DISASSEMBLY",
                                     "GOBP_MITOTIC_SISTER_CHROMATID_SEGREGATION",
                                     "GOBP_SISTER_CHROMATID_SEGREGATION",
                                     "GOBP_NUCLEAR_CHROMOSOME_SEGREGATION",
                                     "GOBP_CHROMOSOME_SEGREGATION",
                                     "GOBP_PROTEIN_DNA_COMPLEX_SUBUNIT_ORGANIZATION",
                                     "GOCC_CONDENSED_CHROMOSOME_CENTROMERIC_REGION",
                                     "GOBP_CHROMATIN_ORGANIZATION_INVOLVED_IN_REGULATION_OF_TRANSCRIPTION",
                                     "GOBP_MITOTIC_NUCLEAR_DIVISION",
                                     "GOCC_CHROMOSOME_CENTROMERIC_REGION",
                                     "GOBP_RDNA_HETEROCHROMATIN_ASSEMBLY",
                                     "GOMF_PROTEIN_HETERODIMERIZATION_ACTIVITY",
                                     "GOBP_DNA_REPLICATION_DEPENDENT_NUCLEOSOME_ORGANIZATION"), ]
selected_rows3 <-tmp3[tmp3$ID %in% c("GOCC_DNA_PACKAGING_COMPLEX",
                                     "GOBP_NUCLEOSOME_ASSEMBLY",
                                     "GOCC_PROTEIN_DNA_COMPLEX",
                                     "GOBP_DNA_PACKAGING",
                                     "GOBP_NUCLEOSOME_ORGANIZATION",
                                     "GOBP_DNA_CONFORMATION_CHANGE",
                                     "GOBP_NEGATIVE_REGULATION_OF_GENE_EXPRESSION_EPIGENETIC",
                                     "GOBP_CHROMATIN_ASSEMBLY_OR_DISASSEMBLY",
                                     "GOBP_MITOTIC_SISTER_CHROMATID_SEGREGATION",
                                     "GOBP_SISTER_CHROMATID_SEGREGATION",
                                     "GOBP_NUCLEAR_CHROMOSOME_SEGREGATION",
                                     "GOBP_CHROMOSOME_SEGREGATION",
                                     "GOBP_PROTEIN_DNA_COMPLEX_SUBUNIT_ORGANIZATION",
                                     "GOCC_CONDENSED_CHROMOSOME_CENTROMERIC_REGION",
                                     "GOBP_CHROMATIN_ORGANIZATION_INVOLVED_IN_REGULATION_OF_TRANSCRIPTION",
                                     "GOBP_MITOTIC_NUCLEAR_DIVISION",
                                     "GOCC_CHROMOSOME_CENTROMERIC_REGION",
                                     "GOBP_RDNA_HETEROCHROMATIN_ASSEMBLY",
                                     "GOMF_PROTEIN_HETERODIMERIZATION_ACTIVITY",
                                     "GOBP_DNA_REPLICATION_DEPENDENT_NUCLEOSOME_ORGANIZATION"), ]
selected_rows1$cell <- "20A"
selected_rows2$cell <- "20B"
selected_rows3$cell <- "20C"
merged_data <- rbind(selected_rows1,selected_rows2,selected_rows3)
write.csv(merged_data,"Fig2A.csv")
merged_data1=merged_data[merged_data$NES>0,]
library(ggplot2)
custom_order <- c("GOCC_DNA_PACKAGING_COMPLEX", 
                  "GOCC_PROTEIN_DNA_COMPLEX",
                  "GOBP_NUCLEOSOME_ORGANIZATION", 
                  "GOMF_PROTEIN_HETERODIMERIZATION_ACTIVITY",
                  "GOBP_DNA_CONFORMATION_CHANGE", 
                  "GOBP_MITOTIC_SISTER_CHROMATID_SEGREGATION", 
                  "GOBP_NUCLEAR_CHROMOSOME_SEGREGATION", 
                  "GOBP_NEGATIVE_REGULATION_OF_GENE_EXPRESSION_EPIGENETIC",
                  "GOBP_CHROMOSOME_SEGREGATION")

ggplot(merged_data, aes(x = factor(ID, levels = custom_order), y = cell)) +
  geom_point(aes(size = NES, color =cell )) +
  scale_x_discrete(limits = custom_order) + 
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  labs(x = NULL, y = NULL)
write.csv(merged_data,"D:/wj/RNA_seq/20ABC VS PAR GO/fig2a_mdamb436 20ABC VS PAR.csv")

#####---------multiple pathway gseaplot----------
library(stringr)
library(clusterProfiler)
library(org.Hs.eg.db)
library(GseaVis)
#BiocManager::install('msigdbr')
library('msigdbr')
library(dplyr)
library(enrichplot)
BAF299 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO DE/JYS/DEG_LLY283vsPAR.csv",sep = ",",stringsAsFactors = F)
BAF299$X=str_split(BAF299$X,'[.]',simplify = T)[,1]
BAF299 <- BAF299[!duplicated(BAF299$X), ]
rownames(BAF299)=BAF299$X
genelist=BAF299$log2FoldChange

names(genelist)=row.names(BAF299)
head(genelist)
id=bitr(names(genelist),'ENSEMBL',c('ENTREZID','SYMBOL'),'org.Hs.eg.db')
head(id,3)
#match id
genelist=genelist[names(genelist) %in% id[,1]]
names(genelist)=id[match(names(genelist),id[,1]),2]
class(genelist)
#GSEA analysis
genelist1=sort(genelist,decreasing = T)
genelist2=sort(genelist,decreasing = T)
genelist3=sort(genelist,decreasing = T)
genelist4=sort(genelist,decreasing = T)
head(genelist1,4)
all_glist <- list(genelist1,genelist2,genelist3,genelist4)
lapply(1:4, function(x){
  ego3 <- gseGO(geneList     = all_glist[[x]],
                OrgDb        = org.Hs.eg.db,
                ont          = "BP",
                minGSSize    = 100,
                maxGSSize    = 500,
                pvalueCutoff = 1,
                verbose      = FALSE)
}) -> m_gsea_list
df1 <- data.frame(m_gsea_list[[1]])
df2 <- data.frame(m_gsea_list[[2]])
df3 <- data.frame(m_gsea_list[[3]])
df4 <- data.frame(m_gsea_list[[4]])
GSEAmultiGP(gsea_list = m_gsea_list,
            geneSetID = "GO:0007346",
            exp_name = c("MDA_MB_436_RA","MDA_MB_436_RB","MDA_MB_436_RC","MDA_MB_436_PAR"))
#DNA repair 
#GO:0045787
#GO:0050678

#cell cycle
#GO:0007346

#IFN
#GO:0034341 (type II IFN)

#AURKB expression
selected_rows3 <-countdata[countdata$ %in% c("REACTOME_APOPTOSIS",
                                             "REACTOME_DNA_REPAIR",
                                             "REACTOME_INTERFERON_SIGNALING",
                                             "REACTOME_CELL_CYCLE",
                                             "REACTOME_G2_M_CHECKPOINTS"), ]

######-----------hS578t 20A gsea-----------------
BAF299 <- read.csv("D:/wj/RNA_seq/20ABC LLY283 VS DMSO DE/DE_HS578T_20A_LLY283.csv",sep = ",",stringsAsFactors = F)
library(stringr)
library(clusterProfiler)
#BiocManager::install('msigdbr')
library('msigdbr')
library(dplyr)
library(enrichplot)
BAF299$X=str_split(BAF299$X,'[.]',simplify = T)[,1]
BAF299 <- BAF299[!duplicated(BAF299$X), ]
rownames(BAF299)=BAF299$X
genelist=BAF299$logFC

names(genelist)=row.names(BAF299)
head(genelist)
id=bitr(names(genelist),'ENSEMBL',c('ENTREZID','SYMBOL'),'org.Hs.eg.db')
head(id,3)

#match id
genelist=genelist[names(genelist) %in% id[,1]]
names(genelist)=id[match(names(genelist),id[,1]),2]
head(genelist,3)

geneset <- read.gmt("D:/single cell data/pathway human/human pathway/c5.all.v2023.1.Hs.entrez.gmt") 

#GSEA analysis
genelist=sort(genelist,decreasing = T)
GSEA_hallmark=GSEA(genelist,TERM2GENE = geneset,pvalueCutoff = 1)
head(GSEA_hallmark,5)
write.csv(GSEA_hallmark,'D:/wj/RNA_seq/GO/Hs578 20A After treatment/GSEA_GO_Hs578T_20A_LLY283.csv', row.names = F)

#lollipop of 20A and 20B
tmp1 <- read.csv("D:/wj/RNA_seq/GO/Hs578 20A After treatment/GSEA_GO_Hs578T_20A_LLY283.csv",sep = ",",stringsAsFactors = F)

tmp1 <- tmp1[tmp1$pvalue<0.05, ]


lol_hs <-GSEA_hallmark@result
lol_hs$Description<- gsub('HALLMARK_','',lol_hs$Description)
lol_hs1=lol_hs[lol_hs$pvalue<0.05,]
lol_hs2=lol_hs[lol_hs$p.adjust<0.01,]


library(ggplot2)
lol_hs<-tmp1[order(tmp1$NES),]
ggplot(lol_hs,aes(x=NES,y=Description))+
  theme_test()+
  geom_line()+geom_segment(aes(x=0,xend=NES,y=Description,yend=Description))+
  geom_point(aes(color=-log10(pvalue)),size=5)+
  ylim(lol_hs$Description)+
  geom_vline(aes(xintercept=0))+
  scale_color_gradient(low = "blue",high = "red")+ 
  labs(y="Pathway",title="GO_Hs578T_20A_LLY283")+
  theme(title=element_text(face="bold",size=12,color="black",
                           vjust = 0.5,hjust = 0.5),
        axis.title.x = element_text(face = 'bold',size = 10,
                                    vjust = 0.5,hjust = 0.5),
        axis.title.y = element_text(face = 'bold',size = 10,
                                    angle = 90,vjust = 0.5,hjust = 0.5),
        axis.text.x = element_text(face = 'bold',size = 10),
        axis.text.y = element_text(face = 'bold',size = 10)) 
gseaplot2(GSEA_hallmark,title='Hs578T_20RA_GOBP_CHROMATIN_REMODELING',
          geneSetID = 'GOBP_CHROMATIN_REMODELING')


######-----------SynergyFinder---------------
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("synergyfinder")
library(synergyfinder)
data("mathews_screening_data")
res <- ReshapeData(
  data = mathews_screening_data,
  data_type = "viability",
  impute = TRUE,
  impute_method = NULL,
  noise = TRUE,
  seed = 1)

res <- CalculateSynergy(
  data = res,
  method = c("ZIP", "HSA", "Bliss", "Loewe"),
  Emin = NA,
  Emax = NA,
  correct_baseline = "non")

Plot2DrugHeatmap(
  data = res,
  plot_block = 1,
  drugs = c(1, 2),
  plot_value = "Bliss_synergy",
  dynamic = FALSE,
  summary_statistic = c( "quantile_25", "quantile_75")
)

colnames(res$drug_pairs)

####in house data
setwd("D:/wj/synergy/")
# Input data
library('synergyfinder')
bl <- read.csv("D:/wj/synergy/1+5(1+2).csv",header = F)
num <- (ncol(bl)-1)*(nrow(bl)-1)
block_id <- rep(1,num )
drug_row <- rep('LLY283',num)
drug_col <- rep('MS023',num)
conc_r <- as.numeric()#(numeric)
response <- as.numeric()#(numeric)
for (i in 1:c(nrow(bl)-1)) {
  conc_r <- c(conc_r,as.numeric(rep(bl[i+1,1],ncol(bl)-1)))
  response <- c(response,as.numeric(bl[i+1,2:ncol(bl)]))
}
conc_c <- as.numeric(rep(bl[1,2:ncol(bl)],nrow(bl)-1))#(numeric)
conc_r_unit <- rep("uM",num)#(character)
conc_c_unit <- rep("uM",num) #(character)

inputdata <- data.frame(block_id,drug_col,drug_row,conc_r,conc_c,response,
                        conc_c_unit,conc_r_unit)
# Reshaping and pre-processing 
dose.response.mat <- ReshapeData(inputdata,
                                 data_type = "viability",
                                 impute_method = NULL,
                                 impute = TRUE,
                                 noise = TRUE,
                                 seed = 1)


str(dose.response.mat)
PlotDoseResponse(dose.response.mat)

# Drug synergy and sensitivity scoring 
synergy.score <- CalculateSynergy(data = dose.response.mat,
                                  method = c("ZIP", "HSA", "Bliss", "Loewe"),
                                  Emin = NA,
                                  Emax = NA,
                                  correct_baseline = "non")

synergy.score$drug_pairs
str(synergy.score$synergy_scores)


# Visualization 
Plot2DrugHeatmap(data = synergy.score,
                 plot_block = 1,
                 drugs = c(1, 2),
                 plot_value = "Bliss_synergy",
                 statistic = "ci",
                 dynamic = FALSE,
                 high_value_color = "#A90217",
                 low_value_color = "#2166AC",
                 summary_statistic = c("quantile_25", "quantile_75"))
Plot2DrugHeatmap(data = synergy.score,
                 plot_block = 1,
                 drugs = c(1, 2),
                 plot_value = "Loewe_synergy",
                 statistic = "ci",
                 dynamic = FALSE,
                 high_value_color = "#A90217",
                 low_value_color = "#2166AC",
                 summary_statistic = c("quantile_25", "quantile_75"))

PlotSynergy(data = synergy.score,
            type = "3D",
            method = "Bliss",
            block_ids = c(1),
            save_file = TRUE,
            high_value_color="blue",
            low_value_color="yellow")

