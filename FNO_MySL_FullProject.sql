-- Basic Queries
-- Q1.Understand Data
SELECT * FROM FNO_Trading_Data LIMIT 10;

-- Q2.Total Trades
SELECT COUNT(*) AS Total_Trades
FROM FNO_Trading_Data;

-- Q3.Total Profit/Loss
SELECT SUM(pnl) AS Net_pnl
FROM FNO_Trading_Data;

-- Q4.Winning VS Losing Trades
SELECT
SUM(CASE WHEN pnl>0 THEN 1 ELSE 0 END) AS Winning_Trqades, 
SUM(CASE WHEN PNL<0 THEN 1 ELSE 0 END) AS Losing_Trades
FROM FNO_Trading_Data;

-- Q5.Win Rate
SELECT 
ROUND (SUM(CASE WHEN pnl>0 THEN 1 ELSE 0 END)*100/COUNT(*),2) AS Winning_Rate
FROM FNO_Trading_Data;

-- Q6.Average Profit and Loss
SELECT 
AVG(CASE WHEN pnl>0 THEN pnl END) AS Average_Profit,
AVG(CASE WHEN pnl<0 THEN pnl END) AS Average_Loss
FROM FNO_Trading_Data;

-- Q7.Biggest Progfit and Biggest Loss
SELECT MAX(pnl) AS Biggest_Profit,
MIN(pnl) AS Biggest_Loss
FROM FNO_Trading_Data;

-- Q8.TOP 10 Best Trades
SELECT Entry_Date,Quantity,Entry_Price,Exit_Price,pnl
FROM FNO_Trading_Data
ORDER BY pnl DESC LIMIT 10;

-- Q9.TOP 10 Worst Trades
SELECT Entry_Date,Quantity,Entry_Price,Exit_Price,pnl
FROM FNO_Trading_Data
ORDER BY pnl  LIMIT 10;

-- Advanced queries
-- 1)Total Trading Performance (KPIs) Insight: Total trades, net profit/loss, average P&L, biggest profit and loss.
SELECT
    COUNT(*) AS total_trades,
    ROUND(SUM(pnl),2) AS total_pnl,
    ROUND(AVG(pnl),2) AS avg_pnl,
    ROUND(MAX(pnl),2) AS highest_profit,
    ROUND(MIN(pnl),2) AS biggest_loss
FROM fno_trading_data;

-- 2)Winning vs Losing Trades Interview Insight: Win/Loss ratio.
SELECT
    CASE
        WHEN pnl > 0 THEN 'Winning Trade'
        WHEN pnl < 0 THEN 'Losing Trade'
        ELSE 'No Profit No Loss'
    END AS trade_result,
    COUNT(*) AS total_trades,
    ROUND(SUM(pnl),2) AS total_pnl
FROM fno_trading_data
GROUP BY trade_result;

-- 3)Profit by Day of Week Insight: noticed Monday and Tuesday losses — this query proves it.
SELECT
    DAYNAME(entry_date) AS weekday,
    COUNT(*) AS trades,
    ROUND(SUM(pnl),2) AS total_pnl
FROM fno_trading_data
GROUP BY weekday
ORDER BY FIELD(
    weekday,
    'Monday','Tuesday','Wednesday','Thursday','Friday'
);
-- 4)Daily Net P&L -This is useful for a Power BI line chart.
SELECT
    entry_date,
    COUNT(*) AS trades,
    ROUND(SUM(pnl),2) AS daily_pnl
FROM fno_trading_data
GROUP BY entry_date
ORDER BY entry_date;

-- 5)Best 5 Trading Days
SELECT
    entry_date,
    ROUND(SUM(pnl),2) AS daily_profit
FROM fno_trading_data
GROUP BY entry_date
ORDER BY daily_profit DESC
LIMIT 5;

-- 6)Worst 5 Trading Days
SELECT
    entry_date,
    ROUND(SUM(pnl),2) AS daily_loss
FROM fno_trading_data
GROUP BY entry_date
ORDER BY daily_loss ASC
LIMIT 5;

-- 7)Average Profit vs Average Loss -Insight: Risk vs Reward.
SELECT
    ROUND(AVG(CASE WHEN pnl > 0 THEN pnl END),2) AS avg_profit,
    ROUND(AVG(CASE WHEN pnl < 0 THEN pnl END),2) AS avg_loss
FROM fno_trading_data;

-- 8)Trading Performance by Symbol
SELECT
    symbol,
    COUNT(*) AS trades,
    ROUND(SUM(pnl),2) AS total_pnl,
    ROUND(AVG(pnl),2) AS avg_pnl
FROM fno_trading_data
GROUP BY symbol
ORDER BY total_pnl DESC;

-- 9)Top 10 Most Profitable Trades
SELECT
    entry_order_id,
    symbol,
    entry_date,
    pnl
FROM fno_trading_data
ORDER BY pnl DESC
LIMIT 10;

-- 1. Running Cumulative P&L (Portfolio Growth) 
/*Insight Running total of profits/losses.
Useful for a cumulative P&L chart in Power BI.*/
SELECT
    entry_date,
    entry_order_id,
    pnl,
    ROUND(
        SUM(pnl) OVER(
            ORDER BY entry_date, entry_order_id
        ),2
    ) AS cumulative_pnl
FROM fno_trading_data
ORDER BY entry_date, entry_order_id
-- 2. Rank the Most Profitable Trades 
-- Insight : Ranks trades from highest profit to lowest.
SELECT
    entry_order_id,
    symbol,
    pnl,
    RANK() OVER(
        ORDER BY pnl DESC
    ) AS profit_rank
FROM fno_trading_data;
-- 3. Dense Rank (No Missing Rank Numbers) **
SELECT
    entry_order_id,
    pnl,
    DENSE_RANK() OVER(
        ORDER BY pnl DESC
    ) AS dense_rank
FROM fno_trading_data;
-- 4. Previous Trade P&L using LAG() Insight Useful for identifying improvement or deterioration.
SELECT
    entry_date,
    entry_order_id,
    pnl,
    LAG(pnl) OVER(
        ORDER BY entry_date, entry_order_id
    ) AS previous_trade_pnl
FROM fno_trading_data;

-- 5. Difference from Previous Trade Insight : Shows whether current trade performed better or worse.
SELECT
    entry_date,
    entry_order_id,
    pnl,
    LAG(pnl) OVER(
        ORDER BY entry_date, entry_order_id
    ) AS previous_trade,
    ROUND(
        pnl -
        LAG(pnl) OVER(
            ORDER BY entry_date, entry_order_id
        ),2
    ) AS pnl_difference
FROM fno_trading_data;

-- 6. Next Trade P&L using LEAD() : Useful for sequential trade analysis.
SELECT
    entry_date,
    entry_order_id,
    pnl,
    LEAD(pnl) OVER(
        ORDER BY entry_date, entry_order_id
    ) AS next_trade_pnl
FROM fno_trading_data;

-- 7. 5-Trade Moving Average of P&L ⭐Insight : Smooths volatility.Very common analytics query.
SELECT
    entry_date,
    entry_order_id,
    pnl,
    ROUND(
        AVG(pnl) OVER(
            ORDER BY entry_date, entry_order_id
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ),2
    ) AS moving_avg_5_trades
FROM fno_trading_data;

-- 8. Running Win Count Insight : Total winning trades till each trade.
SELECT
    entry_date,
    entry_order_id,
    pnl,
    SUM(
        CASE
            WHEN pnl > 0 THEN 1
            ELSE 0
        END
    ) OVER(
        ORDER BY entry_date, entry_order_id
    ) AS running_wins
FROM fno_trading_data;

-- 9. Running Loss Count
SELECT
    entry_date,
    entry_order_id,
    pnl,
    SUM(
        CASE
            WHEN pnl < 0 THEN 1
            ELSE 0
        END
    ) OVER(
        ORDER BY entry_date, entry_order_id
    ) AS running_losses
FROM fno_trading_data;

-- 10. Maximum Drawdown (Portfolio Risk) ⭐ Portfolio-Level Query
WITH cumulative AS (
    SELECT
        entry_date,
        entry_order_id,
        pnl,
        SUM(pnl) OVER(
            ORDER BY entry_date, entry_order_id
        ) AS cumulative_pnl
    FROM fno_trading_data
)

SELECT
    entry_date,
    entry_order_id,
    pnl,
    cumulative_pnl,
    MAX(cumulative_pnl) OVER(
        ORDER BY entry_date, entry_order_id
    ) AS running_peak,
    cumulative_pnl -
    MAX(cumulative_pnl) OVER(
        ORDER BY entry_date, entry_order_id
    ) AS drawdown
FROM cumulative;

/*F&O Trading Project – Advanced SQL Part 3 (Business Insights + Interview Queries)
12 Advanced Interview Queries
Window Functions
CTEs
Business Insights
1. Longest Winning Streak ⭐ (Very Common Interview Question)
Find consecutive winning trades.*/
WITH trade_result AS (
    SELECT *,
        CASE WHEN pnl > 0 THEN 1 ELSE 0 END AS is_win
    FROM fno_trading_data
),
streak AS (
    SELECT *,
        ROW_NUMBER() OVER(ORDER BY entry_date, entry_order_id)
        -
        ROW_NUMBER() OVER(PARTITION BY is_win ORDER BY entry_date, entry_order_id)
        AS grp
    FROM trade_result
)

SELECT
    COUNT(*) AS winning_streak
FROM streak
WHERE is_win = 1
GROUP BY grp
ORDER BY winning_streak DESC
LIMIT 1;
-- Business Insight: "My longest winning streak was 7 trades in a row."

-- 2. Longest Losing Streak
WITH trade_result AS (
    SELECT *,
        CASE WHEN pnl < 0 THEN 1 ELSE 0 END AS is_loss
    FROM fno_trading_data
),
streak AS (
    SELECT *,
        ROW_NUMBER() OVER(ORDER BY entry_date, entry_order_id)
        -
        ROW_NUMBER() OVER(PARTITION BY is_loss ORDER BY entry_date, entry_order_id)
        AS grp
    FROM trade_result
)

SELECT
    COUNT(*) AS losing_streak
FROM streak
WHERE is_loss = 1
GROUP BY grp
ORDER BY losing_streak DESC
LIMIT 1;
-- Business Insight : Shows emotional/risk management periods.

/*3. Profit Factor ⭐
Very important trading metric. Interpretation
Profit Factor Meaning
> 2	Excellent strategy.
1.5 – 2	Good strategy.
1 – 1.5	Average.
< 1	Losing strategy.
Formula

Total Profit/Total Loss */
SELECT
    ROUND(
        SUM(CASE WHEN pnl > 0 THEN pnl ELSE 0 END)
        /
        ABS(SUM(CASE WHEN pnl < 0 THEN pnl ELSE 0 END))
    ,2) AS profit_factor
FROM fno_trading_data;

-- 4. Risk–Reward Ratio Interview Insight : Average winning trade vs average losing trade.
SELECT
    ROUND(AVG(CASE WHEN pnl > 0 THEN pnl END),2) AS avg_profit,
    ROUND(ABS(AVG(CASE WHEN pnl < 0 THEN pnl END)),2) AS avg_loss,
    ROUND(
        AVG(CASE WHEN pnl > 0 THEN pnl END)
        /
        ABS(AVG(CASE WHEN pnl < 0 THEN pnl END))
    ,2) AS risk_reward_ratio
FROM fno_trading_data;

-- 5. Monthly Trading Performance - Business Insight : Find best and worst months.
SELECT
    DATE_FORMAT(entry_date,'%Y-%m') AS month,
    COUNT(*) AS trades,
    ROUND(SUM(pnl),2) AS total_pnl,
    ROUND(AVG(pnl),2) AS average_trade
FROM fno_trading_data
GROUP BY month
ORDER BY month;

-- 6. Best Trading Weekday (You Observed Monday Losses) Business Insight : Which weekday gives highest profitability?
SELECT
    DAYNAME(entry_date) AS weekday,
    COUNT(*) AS trades,
    ROUND(SUM(pnl),2) AS total_pnl,
    ROUND(AVG(pnl),2) AS avg_pnl,
    ROUND(
        SUM(CASE WHEN pnl>0 THEN 1 ELSE 0 END)
        *100/COUNT(*),2
    ) AS win_rate
FROM fno_trading_data
GROUP BY weekday
ORDER BY total_pnl DESC;

-- 7. Consecutive Losing Trades with Dates *Business Insight : Identifies dangerous trading periods.
WITH losses AS (
    SELECT *,
           CASE WHEN pnl < 0 THEN 1 ELSE 0 END AS is_loss
    FROM fno_trading_data
),
grp_loss AS (
    SELECT *,
        ROW_NUMBER() OVER(ORDER BY entry_date, entry_order_id)
        -
        ROW_NUMBER() OVER(PARTITION BY is_loss ORDER BY entry_date, entry_order_id)
        AS grp
    FROM losses
)

SELECT
    MIN(entry_date) AS streak_start,
    MAX(entry_date) AS streak_end,
    COUNT(*) AS total_losses,
    ROUND(SUM(pnl),2) AS loss_amount
FROM grp_loss
WHERE is_loss = 1
GROUP BY grp
HAVING COUNT(*) >= 2
ORDER BY total_losses DESC;

-- 8. Top 5 Highest Loss Trades Insight : Analyze mistakes.
SELECT
    entry_date,
    entry_order_id,
    symbol,
    pnl
FROM fno_trading_data
ORDER BY pnl ASC
LIMIT 5;

-- 9. Top 5 Highest Profit Trades *Insight : Analyze successful setups.
SELECT
    entry_date,
    entry_order_id,
    symbol,
    pnl
FROM fno_trading_data
ORDER BY pnl DESC
LIMIT 5;

-- 10. Cumulative Profit by Month *Insight : Portfolio growth month by month.
WITH monthly AS (
    SELECT
        DATE_FORMAT(entry_date,'%Y-%m') AS month,
        SUM(pnl) AS monthly_profit
    FROM fno_trading_data
    GROUP BY month
)

SELECT
    month,
    monthly_profit,
    SUM(monthly_profit)
        OVER(ORDER BY month) AS cumulative_profit
FROM monthly;

-- 11. Win Rate by Symbol *Business Insight : Which option contract performs better?
SELECT
    symbol,
    COUNT(*) AS trades,
    ROUND(SUM(pnl),2) AS total_pnl,
    ROUND(
        SUM(CASE WHEN pnl>0 THEN 1 ELSE 0 END)
        *100/COUNT(*),2
    ) AS win_rate
FROM fno_trading_data
GROUP BY symbol
ORDER BY win_rate DESC;

/* 12. Maximum Drawdown Summary ⭐
Find the biggest portfolio drawdown.
Business Insight
Largest fall from portfolio peak.*/
WITH cumulative AS (
    SELECT
        entry_date,
        entry_order_id,
        SUM(pnl) OVER(
            ORDER BY entry_date, entry_order_id
        ) AS cumulative_pnl
    FROM fno_trading_data
),
drawdown AS (
    SELECT *,
        MAX(cumulative_pnl)
            OVER(ORDER BY entry_date, entry_order_id) AS running_peak
    FROM cumulative
)

SELECT
    ROUND(MIN(cumulative_pnl-running_peak),2)
        AS maximum_drawdown
FROM drawdown;

/* 1. Create a VIEW for Dashboard (Very Important)
Why it's useful: Power BI can connect directly to this view instead of the raw table.
A view keeps dashboard-ready data in one place.*/

CREATE VIEW vw_trading_dashboard AS
SELECT
    entry_date,
    symbol,
    pnl,
    CASE
        WHEN pnl > 0 THEN 'Profit'
        WHEN pnl < 0 THEN 'Loss'
        ELSE 'Breakeven'
    END AS trade_result,
    DAYNAME(entry_date) AS weekday,
    MONTHNAME(entry_date) AS month_name,
    YEAR(entry_date) AS trade_year
FROM fno_trading_data;
-- Use the view
SELECT * FROM vw_trading_dashboard;

/* 2. Monthly Performance Report (Business Dashboard Query)
Interview Insight: Monthly KPI report for management.*/
SELECT
    month_name,
    COUNT(*) AS total_trades,
    ROUND(SUM(pnl),2) AS total_profit_loss,
    ROUND(AVG(pnl),2) AS avg_trade,
    ROUND(MAX(pnl),2) AS best_trade,
    ROUND(MIN(pnl),2) AS worst_trade
FROM vw_trading_dashboard
GROUP BY month_name
ORDER BY MONTH(STR_TO_DATE(month_name,'%M'));

/* 3. Create a Stored Procedure (Interview Favorite)
Generate a report for any month.
Now you can change April to May, June, etc.*/
DELIMITER $$

CREATE PROCEDURE Monthly_Report(IN report_month VARCHAR(20))
BEGIN
    SELECT
        entry_date,
        symbol,
        pnl
    FROM vw_trading_dashboard
    WHERE month_name = report_month;
END $$

DELIMITER ;
-- Run it
CALL Monthly_Report('April');
CALL Monthly_Report('May');
CALL Monthly_Report('June');

-- 4. Create a FUNCTION for Trade Category , Interview Topic: User Defined Functions
DELIMITER $$

CREATE FUNCTION TradeCategory(pnl_value DECIMAL(10,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE category VARCHAR(20);

    IF pnl_value > 1000 THEN
        SET category='High Profit';
    ELSEIF pnl_value > 0 THEN
        SET category='Profit';
    ELSEIF pnl_value = 0 THEN
        SET category='Breakeven';
    ELSE
        SET category='Loss';
    END IF;

    RETURN category;
END $$

DELIMITER ;
-- Use it
SELECT
    entry_order_id,
    pnl,
    TradeCategory(pnl) AS trade_category
FROM fno_trading_data;

-- 5. CASE-Based Performance Classification , Useful for charts.
SELECT
    entry_order_id,
    pnl,
    CASE
        WHEN pnl >= 1500 THEN 'Excellent'
        WHEN pnl BETWEEN 500 AND 1499 THEN 'Good'
        WHEN pnl BETWEEN 1 AND 499 THEN 'Small Profit'
        WHEN pnl = 0 THEN 'Breakeven'
        ELSE 'Loss'
    END AS performance_level
FROM fno_trading_data;

-- 6. CTE for Best Trading Weekday , Business Insight: Best weekday for strategy.
WITH weekday_summary AS
(
SELECT
    DAYNAME(entry_date) AS weekday,
    SUM(pnl) total_pnl,
    COUNT(*) trades
FROM fno_trading_data
GROUP BY weekday
)

SELECT *
FROM weekday_summary
ORDER BY total_pnl DESC;

-- 7. Create an INDEX (Performance Optimization) , Interview Question: Why indexes improve query performance.
CREATE INDEX idx_entry_date
ON fno_trading_data(entry_date);
-- Check Indexes
SHOW INDEX FROM fno_trading_data;

-- 8. Rolling 10 Trade Performance Report , Shows profit over every 10 consecutive trades.
SELECT
    entry_date,
    pnl,
    ROUND(
        SUM(pnl) OVER(
            ORDER BY entry_date, entry_order_id
            ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
        ),2
    ) AS rolling_10_trade_profit
FROM fno_trading_data;

-- 9. Portfolio KPI Summary (Single Query Dashboard) , This query returns almost every KPI card needed in Power BI.
SELECT
    COUNT(*) AS total_trades,
    ROUND(SUM(pnl),2) AS net_pnl,
    ROUND(AVG(pnl),2) AS average_trade,
    ROUND(MAX(pnl),2) AS best_trade,
    ROUND(MIN(pnl),2) AS worst_trade,
    ROUND(
        SUM(CASE WHEN pnl>0 THEN 1 ELSE 0 END)*100/COUNT(*),2
    ) AS win_rate,
    ROUND(
        SUM(CASE WHEN pnl>0 THEN pnl ELSE 0 END)
        /
        ABS(SUM(CASE WHEN pnl<0 THEN pnl ELSE 0 END))
    ,2) AS profit_factor
FROM fno_trading_data;

-- 10. Create a Final Portfolio View for Power BI , Power BI imports this view directly.
CREATE VIEW vw_powerbi_report AS
SELECT
    entry_order_id,
    entry_date,
    symbol,
    pnl,
    DAYNAME(entry_date) AS weekday,
    MONTHNAME(entry_date) AS month_name,
    CASE
        WHEN pnl>0 THEN 'Winning Trade'
        ELSE 'Losing Trade'
    END AS trade_status
FROM fno_trading_data;







