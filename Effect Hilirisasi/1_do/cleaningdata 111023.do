clear

/*===============================================================*
Version		: 08 oktober 2023
Author		: Siddiq Robbani
Objective	: cleaning data susenas, 
buat data pengeluaran per rmt per tahun, data populasi per tahun, data pemberat tahun, data tahun
*===============================================================*/

clear all
set more off
version 17.0
cap log close

global do "C:\Users\siddi\Documents\Tesis\statatodo\1_do"
global dta "C:\Users\siddi\Documents\Tesis\statatodo\2_dta"
global graph "C:\Users\siddi\Documents\Tesis\statatodo\3_graph"
global log "C:\Users\siddi\Documents\Tesis\statatodo\4_log"
global xls "C:\Users\siddi\Documents\Tesis\statatodo\5_xls"
global raw "C:\Users\siddi\Documents\Tesis\statatodo\6_raw"
global susenas "C:\Users\siddi\Documents\Tesis\statatodo\7_susenas"

log using "$log/cleaning101023.log", replace

*2005*
u "$susenas/Sus_KOR_Ind 2005 SR.dta", clear
bro

gen idkab = string(b1r1, "%2.0f") + b1r2
destring idkab, replace //data idkab master data//

merge m:1 urut using  "$susenas/Sus_KOR_RT 2005 SR.dta"
bro

drop if idkab==7319
drop if idkab==7320
drop if idkab==7321
drop if idkab==7323
drop if idkab==7324

estpost tab idkab b2r3[fw=round(weind)] 
eststo pop2005
estout pop2005 using "$xls/pop.xls", replace

bys idkab: gen kapita = b8br25/b2r3
sum kapita [fw=round(wert)]

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp05
esttab exp05 using "exp.csv", cells(mean) replace

*2006*
u "$susenas/Sus_KOR_Ind 2006 SR.dta", clear
bro
gen idkab = b1r1*100 + b1r2 //data idkab master data//

merge m:1 urut using "$susenas/Sus_KOR_RT 2006 SR.dta"

estpost tab idkab b2r2[fw=round(weind)] 
eststo pop2006
estout pop2006 using "$xls/pop.xls", append

bys idkab: gen kapita = b7r25/b2r2
sum kapita [fw=round(wert)]

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp06
esttab exp06 using "exp.csv", cells(mean) append


*2007*
u "$susenas/Sus_KOR_Ind 2007 SR.dta", clear
bro
gen idkab = b1r1*100 + b1r2 //data idkab master data//

merge m:1 urut using "$susenas/Sus_KOR_RT 2007 SR.dta"

estpost tab idkab jart[fw=round(weind)] 
eststo pop2007
estout pop2007 using "$xls/pop.xls", append

bys idkab: gen kapita = b7r25/jart
sum kapita [fw=round(wert)]

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp07
esttab exp07 using "exp.csv", cells(mean) append

*2008*
u "$susenas/Sus_KOR_Ind 2008 SR.dta", clear
bro
gen idkab = b1r1*100 + b1r2 //data idkab master data//

merge m:1 urut using "$susenas/Sus_KOR_RT 2008 SR.dta"

estpost tab idkab jart[fw=round(weind)] 
eststo pop2008
estout pop2008 using "$xls/pop.xls", append

bys idkab: gen kapita = b9r25/jart
sum kapita [fw=round(wert)]

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp08
esttab exp08 using "exp.csv", cells(mean) append

*2009*
u "$susenas/Sus_KOR_Ind 2009 SR.dta", clear
bro
gen idkab = b1r1*100 + b1r2 //data idkab master data//

merge m:1 id using "$susenas/Sus_KOR_RT 2009 SR.dta"

estpost tab idkab b2r1[fw=round(weind)] 
eststo pop2009
estout pop2009 using "$xls/pop.xls", append

bys idkab: gen kapita = b7r25/b2r1
sum kapita [fw=round(wert)]

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp09
esttab exp09 using "exp.csv", cells(mean) append

*2010*
u "$susenas/Sus_KOR_Ind 2010 SR.dta", clear
bro
gen idkab = b1r1*100 + b1r2 //data idkab master data//

merge m:1 urut using "$susenas/Sus_KOR_RT 2010 SR.dta"

estpost tab idkab b2r1[fw=round(weind)] 
eststo pop2010
estout pop2010 using "$xls/pop.xls", append

bys idkab: gen kapita = b7r25/b2r1
sum kapita [fw=round(wert)]

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp10
esttab exp10 using "exp.csv", cells(mean) append

*2011*
u "$susenas/Sus_KOR_Ind 2011 SR.dta", clear
bro
gen idkab = b1r1*100 + b1r2 //data idkab master data//

merge m:1 series using "$susenas/Sus_KOR_RT 2011 SR edit.dta"

sum fwt
return list
ren fwt wert

estpost tab idkab b2r1[fw=round(weind)] 
eststo pop2011
estout pop2011 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp11
esttab exp11 using "exp.csv", cells(mean) append

*2012*
u "$susenas/Sus_KOR_Ind 2012 SR.dta", clear
bro
gen idkab = b1r1*100 + b1r2 //data idkab master data//

merge m:1 urut using "$susenas/Sus_KOR_RT 2012 SR.dta"
bro

drop weind wert

merge m:1 urut using "$susenas/Sus_Kons_M43 2012 SR.dta", gen (gh)

estpost tab idkab b2r1[fw=round(weind)] 
eststo pop2012
estout pop2012 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp12
esttab exp12 using "exp.csv", cells(mean) append

*2013*
u "$susenas/Sus_KOR_Ind 2013 SR.dta", clear
bro
gen idkab = b1r1*100 + b1r2 //data idkab master data//
gen tahun = 2013 //data tahun//

merge m:1 urut using "$susenas/Sus_KOR_RT 2013 SR.dta"
bro

merge m:1 urut using "$susenas/Sus_Kons_M43 2013 SR.dta", gen (gh)
bro

estpost tab idkab b2r1[fw=round(weind)] 
eststo pop2013
estout pop2013 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp13
esttab exp13 using "exp.csv", cells(mean) append


*2014*
u "$susenas/Sus_KOR_Ind 2014 SR.dta", clear
bro
gen idkab = b1r1*100 + b1r2 //data idkab master data//
gen tahun = 2014 //data tahun//

merge m:1 urut using "$susenas/Sus_KOR_RT 2014 SR.dta"
bro

merge m:1 urut using "$susenas/Sus_Kons_M43 2014 SR.dta", gen (gh)
bro

estpost tab idkab b2r1[fw=round(weind)] 
eststo pop2014
estout pop2014 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp14
esttab exp14 using "exp.csv", cells(mean) append

*2015*
u "$susenas/Sus_KOR_Ind 2015 SR.dta", clear
bro
gen idkab = r101*100 + r102 //data idkab master data//
gen tahun = 2015 //data tahun//

merge m:1 urut using "$susenas/Sus_KOR_RT 2015 SR.dta"
bro

merge m:1 urut using "$susenas/Sus_Kons_M43 2015 SR.dta", gen (gh)
bro

estpost tab idkab r301[fw=round(weind)] 
eststo pop2015
estout pop2015 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp15
esttab exp15 using "exp.csv", cells(mean) append

*2016*
u "$susenas/Sus_KOR_Ind 2016 SR.dta", clear
bro
gen idkab = r101*100 + r102 //data idkab master data//
gen tahun = 2016 //data tahun//

merge m:1 urut using "$susenas/Sus_KOR_RT 2016 SR.dta"
bro

merge m:1 urut using "$susenas/Sus_Kons_M43 2016 SR.dta", gen (gh)
bro

estpost tab idkab r301[fw=round(weind)] 
eststo pop2016
estout pop2016 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp16
esttab exp16 using "exp.csv", cells(mean) append

*2017*
u "$susenas/Sus_KOR_Ind 2017 SR.dta", clear
bro
gen idkab = r101*100 + r102 //data idkab master data//

merge m:1 id using "$susenas/Sus_KOR_RT 2017 SR.dta"
bro

merge m:1 id using "$susenas/Sus_Kons_M43 2017 SR.dta", gen (gh)
bro

estpost tab idkab r301[fw=round(weind)] 
eststo pop2017
estout pop2017 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp17
esttab exp17 using "exp.csv", cells(mean) append

*2018*
u "$susenas/Sus_KOR_Ind 2018 SR.dta", clear
bro
gen idkab = r101*100 + r102 //data idkab master data//
gen tahun = 2018 //data tahun//

merge m:1 urut using "$susenas/Sus_KOR_RT 2018 SR.dta"
bro

merge m:1 urut using "$susenas/Sus_Kons_M43 2018 SR.dta", gen (gh)
bro

estpost tab idkab r301[fw=round(weind)] 
eststo pop2018
estout pop2018 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp18
esttab exp18 using "exp.csv", cells(mean) append


*2019*
u "$susenas/Sus_KOR_Ind 2019 SR.dta", clear
bro
gen idkab = r101*100 + r102 //data idkab master data//
gen tahun = 2019 //data tahun//

merge m:1 renum using "$susenas/Sus_KOR_RT 2019 SR.dta"
bro

merge m:1 renum using "$susenas/Sus_Kons_M43 2019 SR.dta", gen (gh)
bro

estpost tab idkab r301[fw=round(weind)] 
eststo pop2019
estout pop2019 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp19
esttab exp19 using "exp.csv", cells(mean) append


*2020*
u "$susenas/Sus_KOR_Ind 2020 SR.dta", clear
bro
gen idkab = r101*100 + r102 //data idkab master data//
gen tahun = 2020 //data tahun//

merge m:1 renum using "$susenas/Sus_KOR_RT 2020 SR.dta"
bro

merge m:1 renum using "$susenas/Sus_Kons_M43 2020 SR.dta", gen (gh)
bro

estpost tab idkab r301[fw=round(weind)] 
eststo pop2020
estout pop2020 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp20
esttab exp20 using "exp.csv", cells(mean) append

*2021*
u "$susenas/Sus_KOR_Ind 2021 SR.dta", clear
bro
gen idkab = r101*100 + r102 //data idkab master data//
gen tahun = 2021 //data tahun//

merge m:1 renum using "$susenas/Sus_KOR_RT 2021 SR.dta"
bro

merge m:1 renum using "$susenas/Sus_Kons_M43 2021 SR.dta", gen (gh)
bro

estpost tab idkab r301[fw=round(weind)] 
eststo pop2021
estout pop2021 using "$xls/pop.xls", append

estpost tabstat kapita[fw=round(wert)], by(idkab) statistics(mean sum)
eststo exp21
esttab exp21 using "exp.csv", cells(mean) append
