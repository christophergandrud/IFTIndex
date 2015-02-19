International Fiscal Transparency Index
==============

**WORK IN PROGRESS**

We are developing the International Fiscal Transparency Index (IFT). This index aims to measure how willing a country is to release minimally credible information about its central government's fiscal position through international institutions and by extension to international investors.

The index will use a Hierarchical Bayesian Item Response Theory model developed in [Gandrud, Copelovitch, and Hallerberg (2015)](https://github.com/FGCH/FRTIndex) to estimate latent fiscal transparency. The Index examines whether or not countries report at all the following items from the World Bank's Development Indicators:

| WDI Code          | Description                                              |
| ----------------- | -------------------------------------------------------- |
| GC.DOD.TOTL.GD.ZS | Central government debt, total (% of GDP)                |
| FS.AST.CGOV.GD.ZS | Claims on central government, etc. (% GDP)               |
| GC.BAL.CASH.GD.ZS | Cash surplus/deficit (% of GDP)                          |
| GC.REV.XGRT.GD.ZS | Revenue, excluding grants (% of GDP)                     |
| GC.XPN.TOTL.GD.ZS | Expense (% of GDP)                                       |
| GC.TAX.TOTL.GD.ZS | Tax revenue (% of GDP)                                   |
