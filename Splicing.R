#####
#RNA splicing data 
#pick up of sig pathways after treatment of GSK591 or LLY283
data1 <- read.csv("D:/wj/MDAMB436-20A-1uM_GSK591.vs.MDAMB436-20A-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data2 <- read.csv("D:/wj/MDAMB436-20B-1uM_GSK591.vs.MDAMB436-20B-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data3 <- read.csv("D:/wj/MDAMB436-20C-1uM_GSK591.vs.MDAMB436-20C-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data4 <- read.csv("D:/wj/MDAMB436-20A-1uM_LLY283.vs.MDAMB436-20A-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data5 <- read.csv("D:/wj/MDAMB436-20B-1uM_LLY283.vs.MDAMB436-20B-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data6 <- read.csv("D:/wj/MDAMB436-20C-1uM_LLY283.vs.MDAMB436-20C-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)

install.packages("VennDiagram")
install.packages("limma")
library(VennDiagram)
library(limma)

file1 <- read.csv("D:/wj/MDAMB436-20A-1uM_GSK591.vs.MDAMB436-20A-DMSO.SIG.only.annot.csv", header = TRUE, colClasses = "character")$Term
file2 <- read.csv("D:/wj/MDAMB436-20B-1uM_GSK591.vs.MDAMB436-20B-DMSO.SIG.only.annot.csv", header = TRUE, colClasses = "character")$Term
file3 <- read.csv("D:/wj/MDAMB436-20C-1uM_GSK591.vs.MDAMB436-20C-DMSO.SIG.only.annot.csv", header = TRUE, colClasses = "character")$Term

venn_data <- list(Set1 = file1, Set2 = file2, Set3 = file3)
venn_result <- venn.diagram(venn_data, filename = NULL)

grid.newpage()
grid.draw(venn_result)

file1 <- read.csv("D:/wj/MDAMB436-20A-1uM_LLY283.vs.MDAMB436-20A-DMSO.SIG.only.annot.csv", header = TRUE, colClasses = "character")$Term
file2 <- read.csv("D:/wj/MDAMB436-20B-1uM_LLY283.vs.MDAMB436-20B-DMSO.SIG.only.annot.csv", header = TRUE, colClasses = "character")$Term
file3 <- read.csv("D:/wj/MDAMB436-20C-1uM_LLY283.vs.MDAMB436-20C-DMSO.SIG.only.annot.csv", header = TRUE, colClasses = "character")$Term

venn_data <- list(Set1 = file1, Set2 = file2, Set3 = file3)
venn_result <- venn.diagram(venn_data, filename = NULL)

grid.newpage()
grid.draw(venn_result)


common_samples_GSK591<- intersect(intersect(data1$Term, data2$Term), data3$Term)
common_samples_LLY283<- intersect(intersect(data4$Term, data5$Term), data6$Term)


venn_data <- list(Set1 =common_samples_GSK591, Set2 =common_samples_LLY283)
venn_result <- venn.diagram(venn_data, filename = NULL)

grid.newpage()
grid.draw(venn_result)


commonSamples_GL <- intersect(common_samples_GSK591,common_samples_LLY283)
common_values <- data.frame(Term = commonSamples_GL)

b=merge(common_values,data1,by='Term',all.x=T)
b1=merge(b,data2,by='Term',all.x=T)
b2=merge(b1,data3,by='Term',all.x=T)
b3=merge(b2,data4,by='Term',all.x=T)
b4=merge(b3,data5,by='Term',all.x=T)
b5=merge(b4,data6,by='Term',all.x=T)
write.csv(b5,'Commonsamples.csv')


library(pheatmap)
heatmap <- read.csv("D:/wj/-logp.csv", 
                    header=T, 
                    row.names=1,
                    check.names = F)

p<-pheatmap(heatmap, cluster_cols=FALSE,cluster_rows=FALSE,fontsize = 6,cellwidth = 10,cellheight = 10)

## pick up pathways which pval less than 0.01
data1 <- data1[data1$PValue < 0.00001, ]
data2 <- data2[data2$PValue < 0.00001, ]
data3 <- data3[data3$PValue < 0.00001, ]
data4 <- data4[data4$PValue < 0.00001, ]
data5 <- data5[data5$PValue < 0.00001, ]
data6 <- data6[data6$PValue < 0.00001, ]

file1 <- data1$Term
file2 <- data2$Term
file3 <- data3$Term
file4 <- data4$Term
file5 <- data5$Term
file6 <- data6$Term
venn_data <- list(Set1 = file1, Set2 = file2, Set3 = file3)
venn_result <- venn.diagram(venn_data, filename = NULL)

grid.newpage()
grid.draw(venn_result)


common_samples_GSK591<- intersect(intersect(data1$Term, data2$Term), data3$Term)
common_samples_LLY283<- intersect(intersect(data4$Term, data5$Term), data6$Term)


venn_data <- list(Set1 =common_samples_GSK591, Set2 =common_samples_LLY283)
venn_result <- venn.diagram(venn_data, filename = NULL)

grid.newpage()
grid.draw(venn_result)


commonSamples_GL <- intersect(common_samples_GSK591,common_samples_LLY283)
common_values <- data.frame(Term = commonSamples_GL)

b=merge(common_values,data1,by='Term',all.x=T)
b1=merge(b,data2,by='Term',all.x=T)
b2=merge(b1,data3,by='Term',all.x=T)
b3=merge(b2,data4,by='Term',all.x=T)
b4=merge(b3,data5,by='Term',all.x=T)
b5=merge(b4,data6,by='Term',all.x=T)
write.csv(b5,'Commonsamples.csv')
getwd()

library(pheatmap)
heatmap <- read.csv("D:/wj/-logp.csv", 
                    header=T, 
                    row.names=1,
                    check.names = F)

p<-pheatmap(heatmap, cluster_cols=FALSE,cluster_rows=FALSE,fontsize = 6,cellwidth = 10,cellheight = 10)

#####
###heatmap of sig splicing genes
tmp <- read.csv("D:/wj/Commonsamples.csv",sep = ",",stringsAsFactors = F)

selected_rows <- tmp[tmp$X %in% c("GO:0005829~cytosol", "GO:0005654~nucleoplasm", "GO:0005515~protein binding", "GO:0005737~cytoplasm"), ]

selected_cells <- c(selected_rows[4, 4],selected_rows[4, 7], selected_rows[4, 10], selected_rows[4, 13],selected_rows[4, 16],selected_rows[4, 19])
merged_content <- unlist(selected_cells)

print(merged_content)

split_cells <- lapply(strsplit(merged_content, ","), sort)  
common_elements <- Reduce(intersect, split_cells)
common_values <- data.frame(GENE = common_elements)
common_values$GENE<- sub("^\\s+", "", common_values$GENE)

#input data
data1 <- read.csv("D:/wj/heatmap/MDAMB436-20A-1uM_GSK591.vs.MDAMB436-20A-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data2 <- read.csv("D:/wj/heatmap/MDAMB436-20A-1uM_LLY283.vs.MDAMB436-20A-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data3 <- read.csv("D:/wj/heatmap/MDAMB436-20B-1uM_GSK591.vs.MDAMB436-20B-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data4 <- read.csv("D:/wj/heatmap/MDAMB436-20B-1uM_LLY283.vs.MDAMB436-20B-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data5 <- read.csv("D:/wj/heatmap/MDAMB436-20C-1uM_GSK591.vs.MDAMB436-20C-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data6 <- read.csv("D:/wj/heatmap/MDAMB436-20C-1uM_LLY283.vs.MDAMB436-20C-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data1<-data1[!duplicated(data1$GENE),]
data2<-data2[!duplicated(data2$GENE),]
data3<-data3[!duplicated(data3$GENE),]
data4<-data4[!duplicated(data4$GENE),]
data5<-data5[!duplicated(data5$GENE),]
data6<-data6[!duplicated(data6$GENE),]

b1=merge(data1,data2,by='GENE',all.x=T)
b2=merge(b1,data3,by='GENE',all.x=T)
b3=merge(b2,data4,by='GENE',all.x=T)
b4=merge(b3,data5,by='GENE',all.x=T)
b5=merge(b4,data6,by='GENE',all.x=T)
clean_data <- na.omit(b5)
tmp <- clean_data[clean_data$GENE %in% common_values$GENE, ]
rownames(tmp) <- tmp[,1]
tmp <- tmp[,-1]
library(pheatmap)
print(colnames(tmp))

columns_to_swap <- c()
for (i in 1:6) {
  col1 <- 4 * i - 3
  col2 <- 4 * i - 2
  col3 <- 4 * i - 1
  col4 <- 4 * i
  columns_to_swap <- c(columns_to_swap, col3, col4, col1, col2)
}

tmp <- tmp[, columns_to_swap]
print(colnames(tmp))

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
colnames(result_df) <- c("MDAMB436.20A.DMSO","MDAMB436.20A.1uM_GSK591", "MDAMB436.20A.DMSO", "MDAMB436.20A.1uM_LLY283","MDAMB436.20B.DMSO","MDAMB436.20B.1uM_GSK591", "MDAMB436.20B.DMSO","MDAMB436.20B.1uM_LLY283",  "MDAMB436.20C.DMSO","MDAMB436.20C.1uM_GSK591", "MDAMB436.20C.DMSO","MDAMB436.20C.1uM_LLY283")
p<-pheatmap(result_df, cluster_cols=FALSE,cluster_rows=T,fontsize = 6,cellwidth = 10,cellheight = 10,main ="cytosol",scale = "row")

##### 
#IR
#sig 
data1 <- read.csv("D:/wj/splicing data/csv/MDAMB436-20A-1uM_LLY283.vs.MDAMB436-20A-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data2 <- read.csv("D:/wj/splicing data/csv/MDAMB436-20B-1uM_LLY283.vs.MDAMB436-20B-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data3 <- read.csv("D:/wj/splicing data/csv/MDAMB436-20C-1uM_LLY283.vs.MDAMB436-20C-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)
data4 <- read.csv("D:/wj/splicing data/csv/MDAMB436-Par-1uM_LLY283.vs.MDAMB436-Par-DMSO.SIG.only.annot.csv",sep = ",",stringsAsFactors = F)

#IR
data11 <- data1[data1$EV_LABEL == "Intron Inclusion", ]
data12 <- data2[data2$EV_LABEL == "Intron Inclusion", ]
data13 <- data3[data3$EV_LABEL == "Intron Inclusion", ]
table(unique(data12$GENE))
length(unique(data14$GENE))

data14 <- data4[data4$EV_LABEL == "Intron Inclusion", ]

#overlap 20ABC
common_genes <- intersect(intersect(data11$GENE, data12$GENE), data13$GENE)
library(VennDiagram)
library(limma)
venn_data <- list("20A" =data11$GENE, "20B" =data12$GENE,"20C" =data13$GENE)
venn_result <- venn.diagram(venn_data, filename = NULL)

grid.newpage()
grid.draw(venn_result)


#overlap 20ABC !Par
venn_data <- list("20ABC" =common_genes, "Par" =data14$GENE)
venn_result <- venn.diagram(venn_data, filename = NULL)

grid.newpage()
grid.draw(venn_result)

inter <- get.venn.partitions(venn_data)
for (i in 1:nrow(inter)) inter[i,'values'] <- paste(inter[[i,'..values..']], collapse = ', ')
write.table(inter[-c(3, 4)], 'D:/wj/splicing data/venn4_inter.txt', row.names = FALSE, sep = '\t', quote = FALSE)


class(inter[3, 6])


original_string <- "ZNF692, POMGNT1, MSTO1, MRPS21, OGDHL, NFKB2, LTBP3, POP5, AURKB, RND3, ABCB6, RPS27A, WBP1, PLCG1, CHKB, CSNK1E, MRPS25, SMPD2, TAF6, C9orf72, JPX"

element_vector <- strsplit(original_string, ", ")[[1]]

print(element_vector)
"AURKB" %in% element_vector

tmp1 <- data11[data11$GENE %in% element_vector, ]
tmp2 <- data12[data12$GENE %in% element_vector, ]
tmp3 <- data13[data13$GENE %in% element_vector, ]

tmp1$cell <- "20A"
tmp2$cell <- "20B"
tmp3$cell <- "20C"

names(tmp1) <- gsub("20A.", "", names(tmp1))
names(tmp2) <- gsub("20B.", "", names(tmp2))
names(tmp3<- gsub("20C.", "", names(tmp3))
      
merged_data <- rbind(tmp1,tmp2,tmp3)
AURKB <- merged_data[merged_data$GENE == "AURKB", ]
write.csv(merged_data,"D:/wj/splicing data/result/21 genelist.csv")
write.csv(AURKB,"D:/wj/splicing data/AURKB.csv")
library(dplyr)
data <- read.csv("D:/wj/splicing data/result/21 genelist.csv",sep = ",",stringsAsFactors = F)
data1<- data %>% select("EVENT","E.dPsi.") %>% group_by(EVENT) %>% summarise(mean_value = mean(`E.dPsi.`))  %>% left_join(data %>% select("EVENT", "GENE"), by = "EVENT") %>% distinct() %>% arrange(desc(mean_value))
which(data1$GENE== "AURKB")
      
data1<- data %>% select("EVENT","MV.dPsi._at_0.95") %>% group_by(EVENT) %>% summarise(mean_value = mean(`MV.dPsi._at_0.95`))  %>% left_join(data %>% select("EVENT", "GENE"), by = "EVENT") %>% distinct() %>% arrange(desc(mean_value))
which(data1$GENE== "AURKB")
      
colnames(data)
      
gene5<- data[data$GENE %in% c("AURKB","NFKB2", "RPS27A","CSNK1E","TAF6"),]
gene5<- gene5[order(gene5$GENE),]
gene<- gene5 %>% select(c= "GENE",  "EVENT" ,"E.dPsi." ,"MV.dPsi._at_0.95" ,"COORD" , "ONTO", "ONTO_SHORT", "cell" )
      
      
