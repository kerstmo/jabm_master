
library("stringr")
library("stringi")
library("plyr")
library("zoo")
library("ggplot2")
library("gridExtra")
library("grid")
library("reshape2")
library("extrafont")
library("filesstrings")
library("ff")
library("lubridate")
library("lattice")

setwd("/media/mk/McDrive/my_abm/output/")





data <- read.csv2("output_2022-10-04_0930", sep = ",")
data_vacc <- read.csv2("output_2022-10-05_1140/infections", sep = ",")
data_vacc$Run <- as.numeric(data_vacc$Run)
data_vacc$Iteration <- as.numeric(data_vacc$Iteration)
data_vacc$Seed <- as.numeric(data_vacc$Seed)
data_vacc$Sus <- as.numeric(data_vacc$Sus)
data_vacc$Inf. <- as.numeric(data_vacc$Inf.)
data_vacc$cumInf <- as.numeric(data_vacc$cumInf)
data_vacc$Rec <- as.numeric(data_vacc$Rec)
data_vacc$Iso <- as.numeric(data_vacc$Iso)
data_vacc$Vac <- as.numeric(data_vacc$Vac)
data_vacc$VacShare <- as.numeric(data_vacc$VacShare)
data_vacc$ProbaLess1000[data_vacc$ProbaLess1000=="NaN"] <- 0
data_vacc$ProbaLess1000 <- as.numeric(data_vacc$ProbaLess1000)


xxx<-ggplot() +
  ggtitle("Infected/Recovered")+
  geom_point(data=data, aes(x=Iteration, y =Inf., colour = Seed), size =1, color="orange") +
  geom_point(data=data, aes(x=Iteration, y =Rec, colour = Seed), size =1, color="forestgreen") +
  scale_y_continuous(name="Count"
  )+
  theme(panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color= "grey"),
        panel.grid.minor.y = element_blank(),
        legend.key.size = unit(1.5, 'lines'),
        panel.background = element_rect(fill = "white", colour = "black",
                                        size = 1, linetype = "solid"),
        panel.border = element_rect(colour = "black", fill=NA, size=1))+
  theme(axis.text.x = element_text(color = "darkgrey", 
                                   size = 12, angle = 45, hjust = 1),
        axis.text.y = element_text(color = "darkgrey", 
                                   size = 12, angle = 45, hjust = 1),
        plot.title = element_text(size = 12, hjust=0.5,face = "italic"))


cairo_pdf(paste0("/home/mk/Desktop/infrecov_matsim.pdf"),width=6,height=4)
  grid.arrange(xxx, 
               ncol=1)
dev.off()



yyy1<- ggplot() +
  ggtitle("Infected (orange)  vs. Recovered (green)  vs. Isolated (purple)")+
  geom_point(data=data_vacc, aes(x=Iteration, y =Inf., colour = Seed), size =1, color="red") +
  geom_point(data=data_vacc, aes(x=Iteration, y =Rec, colour = Seed), size =1, color="green") +
  geom_point(data=data_vacc, aes(x=Iteration, y =Iso, colour = Seed), size =1, color="purple") +
  scale_y_continuous(name="Count"
  )+
  theme(panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color= "grey"),
        panel.grid.minor.y = element_blank(),
        legend.key.size = unit(1.5, 'lines'),
        panel.background = element_rect(fill = "white", colour = "black",
                                        size = 1, linetype = "solid"),
        panel.border = element_rect(colour = "black", fill=NA, size=1))+
  theme(axis.text.x = element_text(color = "darkgrey", 
                                   size = 12, angle = 45, hjust = 1),
        axis.text.y = element_text(color = "darkgrey", 
                                   size = 12, angle = 45, hjust = 1),
        plot.title = element_text(size = 12, hjust=0.5,face = "italic"))


 yyy2 <- ggplot() +
  ggtitle("Vacc. Share (blue)  vs.  Proba<1000 Infected (red)")+
  geom_line(data=data_vacc, aes(x=Run, y =VacShare, colour = Seed), size =1, color="blue") +
  geom_point(data=data_vacc, aes(x=Run, y =VacShare, colour = Seed), size =2, color="blue") +
  geom_boxplot(data=data_vacc, aes(x=Run, y =ProbaLess1000, group = Run,), outlier.shape=16, outlier.size=0.5,color="red") +
  scale_y_continuous(name="Count"
  )+
  theme(panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color= "grey"),
        panel.grid.minor.y = element_blank(),
        legend.key.size = unit(1.5, 'lines'),
        panel.background = element_rect(fill = "white", colour = "black",
                                        size = 1, linetype = "solid"),
        panel.border = element_rect(colour = "black", fill=NA, size=1))+
  theme(axis.text.x = element_text(color = "darkgrey", 
                                   size = 12, angle = 45, hjust = 1),
        axis.text.y = element_text(color = "darkgrey", 
                                   size = 12, angle = 45, hjust = 1),
        plot.title = element_text(size = 12, hjust=0.5,face = "italic"))

 
 BP_data <-as.data.frame(cbind(data_vacc$Run, data_vacc$cumInf))
colnames(BP_data) <- c("Run", "cumInf")
 
 
 
 yyy3 <- ggplot(BP_data, aes(x=Run, y=cumInf, group = Run)) +
   ggtitle("Proba<1000  per Run")+
   geom_boxplot(outlier.colour="black", outlier.shape=16, outlier.size=0.5, notch=FALSE) +
   scale_y_continuous(name="Count"
   )+
   theme(panel.grid.minor.x = element_blank(),
         panel.grid.major.x = element_blank(),
         panel.grid.major.y = element_line(color= "grey"),
         panel.grid.minor.y = element_blank(),
         legend.key.size = unit(1.5, 'lines'),
         panel.background = element_rect(fill = "white", colour = "black",
                                         size = 1, linetype = "solid"),
         panel.border = element_rect(colour = "black", fill=NA, size=1))+
   theme(axis.text.x = element_text(color = "darkgrey", 
                                    size = 12, angle = 45, hjust = 1),
         axis.text.y = element_text(color = "darkgrey", 
                                    size = 12, angle = 45, hjust = 1),
         plot.title = element_text(size = 12, hjust=0.5,face = "italic"))
 
 
 
 
 
 




cairo_pdf(paste0("/home/mk/Desktop/infrecov_vacc.pdf"),width=16,height=5)
grid.arrange(yyy1,yyy2, yyy3,
             ncol=3)
dev.off()



