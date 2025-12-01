# 📉 World Layoffs Analysis (2020–2025)

A complete data analysis project exploring global layoff trends using SQL and Exploratory Data Analysis.

This repository provides an end-to-end pipeline including data cleaning, analysis, and key findings across industries, countries, and time periods.

## 🧩 1. Project Overview

From 2020 to 2025, the world experienced massive workforce shifts due to the pandemic, inflation, recession fears, rapid automation, and restructuring across major industries.

This project analyzes a global layoffs dataset to identify patterns, understand which sectors were impacted the most, and uncover insights into the economic landscape across five years.

## 🎯 2. Problem Statement

To perform a comprehensive data-driven analysis of worldwide layoffs from 2020–2025 by answering questions across various dimensions, including:

1. Global Trends
2. Country-Level Insights
3. Industry Insights
4. Company-Level Insights
5. Funding & Startup Stage Insights

## 📁 3. Dataset Description

The raw dataset includes global layoff data obtained from [Kaggle](https://www.kaggle.com/datasets/swaptr/layoffs-2022).

Key columns in the raw dataset:
| Column | Data Type |
| --- | --- |
| company | Text |
| location | Text |
| total_laid_off | Text |
| date | Text |
| percentage_laid_off | Text |
| industry | Text |
| stage | Text |
| funds_raised_millions | Integer |
| country | Text |

## 📊 4. Key Findings & Insights

1. Layoff Peaks

The highest layoffs occurred in 2022 and 2023, driven by economic tightening and over-recruitment during the pandemic.

2. Most Affected Industries

Retail and Consumer Services (including Technology) were the hardest hit.

3. Country-Level Impact

The United States and India recorded the highest number of layoffs globally.

4. Spike Patterns

Large spikes align with funding shortages, recession fears, and restructuring.

5. Company-Level Observations

Major tech giants (Meta, Google, Amazon, Salesforce, etc.) had multiple waves of layoffs.

6. Funding Stage Effect

Early-stage companies laid off significantly fewer employees compared to growth-stage and late-stage (IPO-ready) companies.

## 🗂️ 5. Folder Structure

```
world-layoffs-analysis-2020-2025/
│
├── dataset/
│   ├── layoffs.csv
|
├── world_layoffs_data_cleaning.sql
|
├── world_layoffs_eda.sql
|
└── README.md
```

## 🚀 6. Future Work

- Add predictive modeling to forecast layoffs

- Add visualizations

- Build a Power BI dashboard

- Add external datasets (inflation, GDP, stock prices) to determine their quantifiable degree of impact on layoff patterns
