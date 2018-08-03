
# 모든 나무들의 이름 얻기
library(readxl)
dirpath <-  'D:/18git/'
treedb <- read_excel(paste(input_dirpath, 'treedb_h.xlsx', sep=''), sheet=3)
tree_names <- treedb$scientific_name

# 모든 나라 이름들 구하기.
# countries 는 모든 나라 이름들의 벡터. 단 중복 없는 형태로.
occurrence_dirpath <-'D:/18git/180803/data/'
countries <- c()
for (tree in tree_names) {
  # 해당 tree의 occurrence 데이터 읽기
  filepath <- paste(occurrence_dirpath, sprintf('%s.csv', tree), sep='')
  treedf <- read.csv(filepath, stringsAsFactors=FALSE)
  
  # 해당 tree가 존재하는 모든 국가들을 추가함
  # 이 때, unique 함수를 사용하여 국가들을 중복없이 보관함
  countries <- unique(c(countries, unique(treedf$country)))
}

# 모든 국가들의 geocode를 구함
geocodes <- geocode(countries)
geocodes <- geocodes[, 2:8]
geocodes <- unique(geocodes)
geocodes <- na.omit(geocodes)
colnames(geocodes) <- c('country', 'lon', 'lat', 'xmin', 'xmax', 'ymin', 'ymax')


#################################################################
# 모든 종에 대한 data를 얻어 cleaning 하기!!!
#################################################################

# all_tree_df 에 모든 종에 대한 occurrence 데이터를 보관할 것임.
# 이 때, 모든 데이터는 cleaning 되어야 한다.
all_tree_df <- data.frame()

# 데이터가 없는 tree들이 있을 수 있다.
tree_no_data <- c()

# 모든 tree에 대해
for (tree in tree_names) {
  tryCatch(
    {
      # 해당 tree의 occurrence 정보를 읽는다.
      filepath <- paste(occurrence_dirpath, sprintf('%s.csv', tree), sep='')
      treedf <- read.csv(filepath)
      
      # occurrence 중복을 제거한다.
      # 여러 행에 같은 lon, lat 이 중복되어 나타나는 경우가 있어서 이를 제거한다.
      treedf <- unique(treedf)
      
      # 해당 tree가 존재하고 있는 모든 국가들을 얻는다.
      country_of_tree <- unique(treedf$country)
      
      # 해당 tree의 각 occurrence의 lon과 lat이 적절한 범위에 있는지 확인하고
      # 적절한 것들만 tree_valid에 보관한다.
      tree_valid <- data.frame()
      
      for (c in country_of_tree) {
        if (!(c %in% geocodes$country)) {
          # 만약 country 이름이 geocode에 검색되지 않았다면
          # 신경쓰지 않고 무시.
          # 간혹 이상한 이름의 국가가 기입된 것들이 있다. (예: <U+00C5>land)
          next
          
          # cf) 국가 이름이 이상하더라도 그냥 lon, lat을 쓰고 싶으면
          # next를 지우고 tree_valid에 해당 정보를 rbind 하면 된다.
          
        } else {
          # 만약 country 이름이 geocode에 잘 검색되었다면
          # 적절한 lon(혹은 x), lat(혹은 y) 범위의 것들만 얻어낸다.
          
          # 해당 국가 c의 xmin, xmax, ymin, ymax 를 구한다.
          xmin_c <- geocodes[geocodes$country==c,]$xmin
          xmax_c <- geocodes[geocodes$country==c,]$xmax
          ymin_c <- geocodes[geocodes$country==c,]$ymin
          ymax_c <- geocodes[geocodes$country==c,]$ymax
          
          # tree_valid_c 에 해당 국가 c에 존재하는 위치 중, 
          # 적절한 범위의 것들만 남긴다.
          tree_valid_c <- treedf[(treedf$country == c) & (xmin_c < treedf$lon), ]
          tree_valid_c <- tree_valid_c[(tree_valid_c$country == c) & (xmax_c > tree_valid_c$lon), ]
          tree_valid_c <- tree_valid_c[(tree_valid_c$country == c) & (ymin_c < tree_valid_c$lat), ]
          tree_valid_c <- tree_valid_c[(tree_valid_c$country == c) & (ymax_c > tree_valid_c$lat), ]
          
          # tree_valid에 tree_valid_c를 더한다.
          tree_valid <- rbind(tree_valid, tree_valid_c)
        }
      }
      
      # tree_valid의 컬럼을 수정한다.
      # kind, country, lon, lat 을 가지도록.
      # all_tree_df가 kind, country, lon, lat 을 가지도록 만들 것이기 때문.
      tree_valid <- tree_valid[, c('country', 'lon', 'lat')]
      tree_valid <- cbind(kind=rep(tree, nrow(tree_valid)), tree_valid)
      
      # all_tree_df에 해당 tree의 tree_valid를 추가한다.
      all_tree_df <- rbind(all_tree_df, tree_valid)
    }
    
    write.csv(all_tree_df, paste(occurrence_dirpath, 'all_tree.csv'), row.names=FALSE)
    