# 查看数据
SELECT * FROM game LIMIT 10;

#查找所有空行
SELECT * FROM game
WHERE
    -- Rank列（注意反引号）
    `Rank` IS NULL OR `Rank` = '' OR
    TRIM(IFNULL(`Rank`, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- Name列
    OR Name IS NULL OR Name = '' OR
    TRIM(IFNULL(Name, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- Platform列
    OR Platform IS NULL OR Platform = '' OR
    TRIM(IFNULL(Platform, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- Year列（保留0值）
    OR Year IS NULL OR Year = '' OR
    TRIM(IFNULL(Year, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- Genre列
    OR Genre IS NULL OR Genre = '' OR
    TRIM(IFNULL(Genre, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- Publisher列
    OR Publisher IS NULL OR Publisher = '' OR
    TRIM(IFNULL(Publisher, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- 各销售数据列（保留0值）
    OR NA_Sales IS NULL OR
    TRIM(IFNULL(NA_Sales, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    OR EU_Sales IS NULL OR
    TRIM(IFNULL(EU_Sales, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    OR JP_Sales IS NULL OR
    TRIM(IFNULL(JP_Sales, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    OR Other_Sales IS NULL OR
    TRIM(IFNULL(Other_Sales, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    OR Global_Sales IS NULL OR
    TRIM(IFNULL(Global_Sales, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan');

# 删除查找到的空值
delete FROM game
WHERE
    -- Rank列（注意反引号）
    `Rank` IS NULL OR `Rank` = '' OR
    TRIM(IFNULL(`Rank`, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- Name列
    OR Name IS NULL OR Name = '' OR
    TRIM(IFNULL(Name, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- Platform列
    OR Platform IS NULL OR Platform = '' OR
    TRIM(IFNULL(Platform, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- Year列（保留0值）
    OR Year IS NULL OR Year = '' OR
    TRIM(IFNULL(Year, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- Genre列
    OR Genre IS NULL OR Genre = '' OR
    TRIM(IFNULL(Genre, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- Publisher列
    OR Publisher IS NULL OR Publisher = '' OR
    TRIM(IFNULL(Publisher, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    -- 各销售数据列（保留0值）
    OR NA_Sales IS NULL OR
    TRIM(IFNULL(NA_Sales, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    OR EU_Sales IS NULL OR
    TRIM(IFNULL(EU_Sales, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    OR JP_Sales IS NULL OR
    TRIM(IFNULL(JP_Sales, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    OR Other_Sales IS NULL OR
    TRIM(IFNULL(Other_Sales, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan')

    OR Global_Sales IS NULL OR
    TRIM(IFNULL(Global_Sales, '')) IN ('N/A', 'NA', 'null', 'NULL', 'NaN', 'nan');


# 找出每个游戏平台最赚钱的游戏类型组合
CREATE TABLE most_profitable_game_genres_by_platform AS
WITH platform_genre_matrix AS (
  SELECT
    Platform,
    Genre,
    SUM(Global_Sales) AS total_sales,
    -- 计算该类型在平台内的销售占比
    SUM(Global_Sales) / SUM(SUM(Global_Sales)) OVER (PARTITION BY Platform) * 100 AS genre_percentage
  FROM game
  GROUP BY Platform, Genre
)
SELECT
  Platform,
  Genre,
  total_sales,
  genre_percentage
FROM platform_genre_matrix
WHERE genre_percentage > 20  -- 筛选占比超过20%的重要组合
ORDER BY Platform, total_sales DESC;


# 识别不同地区（NA/EU/JP）偏好的游戏类型
CREATE TABLE Preferred_game_genres_by_region AS
SELECT
  Genre,
  -- 计算各地区销售额占比
  SUM(NA_Sales) / SUM(Global_Sales) * 100 AS na_ratio,
  SUM(EU_Sales) / SUM(Global_Sales) * 100 AS eu_ratio,
  SUM(JP_Sales) / SUM(Global_Sales) * 100 AS jp_ratio,
  -- 识别主导市场
  CASE
    WHEN SUM(NA_Sales) > SUM(EU_Sales) AND SUM(NA_Sales) > SUM(JP_Sales) THEN 'NA'
    WHEN SUM(EU_Sales) > SUM(JP_Sales) THEN 'EU'
    ELSE 'JP'
  END AS dominant_market
FROM game
GROUP BY Genre
ORDER BY SUM(Global_Sales) DESC;

# 评估出版商在不同平台的投入产出比
CREATE TABLE Publisher’s_return_on_investment_by_platform AS
SELECT
  Publisher,
  Platform,
  COUNT(*) AS game_count,
  SUM(Global_Sales) AS total_sales,
  -- 计算单游戏平均销售额
  SUM(Global_Sales) / COUNT(*) AS avg_sales_per_game,
  -- 计算平台内市场份额
  SUM(Global_Sales) / SUM(SUM(Global_Sales)) OVER (PARTITION BY Platform) * 100 AS platform_market_share
FROM game
GROUP BY Publisher, Platform
HAVING COUNT(*) >= 3  -- 只分析发行3款游戏以上的组合
ORDER BY avg_sales_per_game DESC;




