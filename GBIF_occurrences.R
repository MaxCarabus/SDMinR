### получаем данные из главного репозитория данных о биоразннобразии GBIF
# GBIF - Global Biodiversity Information Facility https://www.gbif.org
# есть русскоязычный интерфейс https://www.gbif.org/ru/ 
# API GBIF программный интерфейс https://www.gbif.org/developer/summary 
# пакет rgbif https://www.gbif.org/tool/81747/rgbif 

install.packages('rgbif')
library(rgbif)
# подробное руководство от авторов: https://cran.r-project.org/web/packages/rgbif/rgbif.pdf

# для начала надо найти вид в таксономической базе GBIF и получить его идентификатор
# GBIF Backbone Taxonomy https://www.gbif.org/dataset/d7dddbf4-2cf0-4f39-9b2a-bb099caae36c
# для примера возьмем массовый вид дождевого червя - Aporrectodea caliginosa
sp = name_backbone('Aporrectodea caliginosa', rank = 'species')
str(sp)

spKey = sp$usageKey
# зная идентификатор может посмотреть страницу этого вида в GBIF: https://www.gbif.org/species/2307759

occurs = occ_search(taxonKey = spKey, fields = 'minimal')$data
head(occurs)
colnames(occurs)
str(occurs)

# Darwin Core. Quick Reference Guide https://dwc.tdwg.org/terms 

terms = c('key','scientificName','decimalLatitude','decimalLongitude','country','countryCode')
occurs = occ_search(taxonKey = spKey, fields = terms, limit = 3500)$data

# число полученных записей из GBIF (находок)
length(occurs$key)
nrow(occurs)

occurs = occurs[!is.na(occurs[,3]),]
occurs = occurs[!is.na(occurs[,4]),]

occurs = subset(occurs, !is.na(decimalLatitude) & !is.na(decimalLongitude))

install.packages('maptools')
library(maptools)
data("wrld_simpl")

latMin = min(occurs$decimalLatitude)
latMax = max(occurs$decimalLatitude)
lonMin = min(occurs$decimalLongitude)
lonMax = max(occurs$decimalLongitude)

plot(wrld_simpl, xlim = c(lonMin,lonMax), ylim = c(latMin,latMax), axes = T, col = 'darkseagreen1')
points(occurs$decimalLongitude, occurs$decimalLatitude, pch = 20, col = 'red', cex = 0.7)

# зададим охват схемы "вручную"
latMin = 40
latMax = 80
lonMin = 30
lonMax = 50

# находим дубликаты по координатам
dubs = duplicated(occurs[,3:4])

occursDistinct = occurs[!dubs,]
nrow(occursDistinct)

acEur = occursDistinct[occursDistinct$decimalLatitude > 44.75 & occursDistinct$decimalLatitude & occursDistinct$decimalLongitude > 27 & occursDistinct$decimalLongitude < 67,]
plot(wrld_simpl, axes = T, xlim = c(25,70), ylim = c(43,72), col = 'light yellow')
points(acEur$decimalLongitude, acEur$decimalLatitude, col = 'red', pch = 20, cex = 0.7)

# сохраняем точки находок для дальнейшей работы
write.csv(acEur, 'ac_gbif.csv')
