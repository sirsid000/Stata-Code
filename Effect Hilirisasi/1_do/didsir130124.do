clear

/*===============================================================*
Version		: 13 Januari 2024
Author		: Siddiq Robbani
Objective	: Analisis DiD hilirisasi nikel dan Analisis Spasial
*===============================================================*/

clear all
set more off
version 17.0
cap log close

cd "C:\Users\siddi\Documents\Tesis\statatodo"
global do "C:\Users\siddi\Documents\Tesis\statatodo\1_do"
global dta "C:\Users\siddi\Documents\Tesis\statatodo\2_dta"
global graph "C:\Users\siddi\Documents\Tesis\statatodo\3_graph"
global log "C:\Users\siddi\Documents\Tesis\statatodo\4_log"
global xls "C:\Users\siddi\Documents\Tesis\statatodo\5_xls"
global raw "C:\Users\siddi\Documents\Tesis\statatodo\6_raw"
global susenas "C:\Users\siddi\Documents\Tesis\statatodo\7_susenas"
global shp "C:\Users\siddi\Documents\Tesis\statatodo\8_shp"


log using "$log/didsir130124.log", replace


/***************panel set***************/
u "$dta/setbanexp.dta", clear
bro

xtset idkab tahun, yearly

xtdescribe

tab idkab tahun if didbanexp == 1


/***************summary*****************/

*larangan ekspor
asdoc sum, replace stat (mean sd) by(didbanexp) save(expban.doc) dec(2) 

/**************************************
grafik paralel trend 
***************************************/

*paralel model 1
binscatter lnpdrbcap tahun, discrete by(aktnikel) line(connect) ///
legend(label(1 "Control") label(2 "Treated")) ///
xline(2014, lcolor(red)) xline(2017, lcolor(green)) xline(2020, lcolor(red)) name(m1, replace)
graph export "$graph/model1.png", replace


*paralel model 2
binscatter lnexpcap tahun, discrete by(aktnikel) line(connect) ///
legend(label(1 "Control") label(2 "Treated")) ///
xline(2014, lcolor(red)) xline(2017, lcolor(green)) xline(2020, lcolor(red)) name(m2, replace)
graph export "$graph/model2.png", replace


//Paralleltrend//
*model1
xtreg lnpdrbcap i.aktnikel##c.tahun smel tam lngovexp lnagri if tahun < 2014, fe
margins aktnikel, dydx(tahun)
outreg2 using "$xls/paralel011123.xls", label replace bdec(3) sdec(2)  ctitle(model1)

*model2
xtreg lnexpcap i.aktnikel##c.tahun smel tam lngovexp lnagri if tahun < 2014, fe 
margins aktnikel, dydx(tahun)
outreg2 using "$xls/paralel011123.xls", label append bdec(3) sdec(2)  ctitle(model2)


*non inferios model1
xtreg lnpdrbcap aktnikel##ibn.tahun smel tam lngovexp lnagri if tahun < 2015, fe cl(idkab) 
outreg2 using "$xls/paralelreg011123.xls", label replace bdec(3) sdec(2)  ctitle(model1)


*non inferios model2
xtreg lnexpcap aktnikel##ibn.tahun smel tam lngovexp lnagri if tahun < 2015, fe cl(idkab) 
outreg2 using "$xls/paralelreg011123.xls", label append bdec(3) sdec(2)  ctitle(model2)


/***********************DID*******************************/

/*model A dampak larangan ekspor terhadap pdrb per kapita*/

*M1 = fix effect
xtreg lnpdrbcap aktnikel timeban didbanexp, fe cl(idkab)
eststo ma1
outreg2 using "$xls/model1.xls",  replace bdec(3) sdec(2)  ctitle(FE) addtext(Daerah FE, YES, Covar, NO, Time FE, NO)

*M2 = M1 + time fix effect
xtreg lnpdrbcap aktnikel timeban didbanexp i.tahun, fe cl(idkab)
eststo ma2
outreg2 using "$xls/model1.xls",  append bdec(3) sdec(2)  ctitle(M1+timeFE) addtext(Daerah FE, YES, Covar, NO, Time FE, YES)

*M3 = M2 + j. smelter
xtreg lnpdrbcap aktnikel timeban didbanexp smel i.tahun, fe cl(idkab)
eststo ma3
outreg2 using "$xls/model1.xls",  append bdec(3) sdec(2)  ctitle(M2+jsmel) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M4 = M3 + belanja pemerintah
xtreg lnpdrbcap aktnikel timeban didbanexp smel lngovexp i.tahun, fe cl(idkab)
eststo ma4
outreg2 using "$xls/model1.xls",  append bdec(3) sdec(2)  ctitle(M3+goxexp) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M5 = M4 + PDRB pertanian
xtreg lnpdrbcap aktnikel timeban didbanexp smel lngovexp lnagri i.tahun, fe cl(idkab)
eststo ma5
outreg2 using "$xls/model1.xls",  append bdec(3) sdec(2)  ctitle(M4+lnagri) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M6 = M5 + jumlah tambang
xtreg lnpdrbcap aktnikel timeban didbanexp smel lngovexp lnagri tam i.tahun, fe cl(idkab)
eststo ma6
outreg2 using "$xls/model1.xls",  append bdec(3) sdec(2)  ctitle(M5+tam) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

esttab ma1 ma2 ma3 ma4 ma5 ma6, title("depent variable ln (pdrb)") star(* 0.1 ** 0.05 *** 0.01) stats(N r2) indicate( "time fe = *.tahun")


/*model B dampak larangan ekspor terhadap konsumsi rt per kapita*/

*M1 = fix effect
xtreg lnexpcap aktnikel timeban didbanexp, fe cl(idkab)
eststo mb1
outreg2 using "$xls/model2.xls",  replace bdec(3) sdec(2)  ctitle(FE) addtext(Daerah FE, YES, Covar, NO, Time FE, NO)

*M2 = M1 + time fix effect
xtreg lnexpcap aktnikel timeban didbanexp i.tahun, fe cl(idkab)
eststo mb2
outreg2 using "$xls/model2.xls",  append bdec(3) sdec(2)  ctitle(M1+timeFE) addtext(Daerah FE, YES, Covar, NO, Time FE, YES)

*M3 = M2 + j. smelter
xtreg lnexpcap aktnikel timeban didbanexp smel i.tahun, fe cl(idkab)
eststo mb3
outreg2 using "$xls/model2.xls",  append bdec(3) sdec(2)  ctitle(M2+jsmel) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M4 = M3 + belanja pemerintah
xtreg lnexpcap aktnikel timeban didbanexp smel lngovexp i.tahun, fe cl(idkab)
eststo mb4
outreg2 using "$xls/model2.xls",  append bdec(3) sdec(2)  ctitle(M3+goxexp) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M5 = M4 + PDRB pertanian
xtreg lnexpcap aktnikel timeban didbanexp smel lngovexp lnagri i.tahun, fe cl(idkab)
eststo mb5
outreg2 using "$xls/model2.xls",  append bdec(3) sdec(2)  ctitle(M4+lnagri) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M6 = M5 + jumlah tambang
xtreg lnexpcap aktnikel timeban didbanexp smel lngovexp lnagri tam i.tahun, fe cl(idkab)
eststo mb6
outreg2 using "$xls/model2.xls",  append bdec(3) sdec(2)  ctitle(M5+tam) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)


esttab mb1 mb2 mb3 mb4 mb5 mb6, title("depent variable ln (expcap)") star(* 0.1 ** 0.05 *** 0.01) stats(N r2) indicate( "time fe = *.tahun")

**********************************************************************

/***************panel set***************/
u "$dta/setsmelter.dta", clear
bro

xtset idkab tahun, yearly

xtdescribe

tab idkab tahun if didsmel == 1

tab idkab tahun if nondsmel == 1

/***************summary*****************/

*smelter
asdoc sum, replace stat (mean sd) by(didsmel) save(smelter.doc) dec(2)


/**************************************
grafik paralel trend 
***************************************/

*paralel model 3
binscatter lnpdrbcap tahun, discrete by(smelpretend) line(connect) ///
legend(label(1 "Control") label(2 "Treated")) ///
xline(2009, lcolor(green)) xline(2014, lcolor(red)) xline(2017, lcolor(green)) xline(2020, lcolor(red)) name(m3, replace)
graph export "$graph/model3.png", replace


*paralel model 4
binscatter lnexpcap tahun, discrete by(smelpretend) line(connect) ///
legend(label(1 "Control") label(2 "Treated")) ///
xline(2009, lcolor(green)) xline(2014, lcolor(red)) xline(2017, lcolor(green)) xline(2020, lcolor(red)) name(m4, replace)
graph export "$graph/model4.png", replace


//Paralleltrend//

*model3
xtreg lnpdrbcap i.smelpretend##c.tahun tam lngovexp lnagri if tahun < 2009, fe
outreg2 using "$xls/paralel021123.xls", label replace bdec(3) sdec(2)  ctitle(model3)


*model4
xtreg lnexpcap i.smelpretend##c.tahun tam lngovexp lnagri if tahun < 2009, fe 
outreg2 using "$xls/paralel021123.xls", label append bdec(3) sdec(2)  ctitle(model4)


*model C dampak smelter terhadap pdrb per kapita

*M1 = fix effect
xtreg lnpdrbcap didsmel, fe cl(idkab)
eststo mc1
outreg2 using "$xls/model3.xls",  replace bdec(3) sdec(2)  ctitle(FE) addtext(Daerah FE, YES, Covar, NO, Time FE, NO)

*M2 = M1 + time fix effect
xtreg lnpdrbcap didsmel i.tahun, fe cl(idkab)
eststo mc2
outreg2 using "$xls/model3.xls",  append bdec(3) sdec(2)  ctitle(M1+timeFE) addtext(Daerah FE, YES, Covar, NO, Time FE, YES)

*M3 = M2 + j. smelter
xtreg lnpdrbcap didsmel smel i.tahun, fe cl(idkab)
eststo mc3
outreg2 using "$xls/model3.xls",  append bdec(3) sdec(2)  ctitle(M2+jsmel) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M4 = M3 + j. tambang
xtreg lnpdrbcap didsmel smel tam i.tahun, fe cl(idkab)
eststo mc4
outreg2 using "$xls/model3.xls",  append bdec(3) sdec(2)  ctitle(M3+jtam) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M5 = M4 + belanja pemerintah
xtreg lnpdrbcap didsmel smel tam lngovexp i.tahun, fe cl(idkab)
eststo mc5
outreg2 using "$xls/model3.xls",  append bdec(3) sdec(2)  ctitle(M4+goxexp) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M6 = M5 + PDRB pertanian
xtreg lnpdrbcap didsmel smel tam lngovexp lnagri i.tahun, fe cl(idkab)
eststo mc6
outreg2 using "$xls/model3.xls",  append bdec(3) sdec(2)  ctitle(M5+lnagri) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

esttab mc1 mc2 mc3 mc4 mc5 mc6, title("depent variable ln (pdrb)") star(* 0.1 ** 0.05 *** 0.01) stats(N r2) indicate( "time fe = *.tahun")

**************************************************************************************************************************************************

*model D dampak smelter terhadap konsumsi per kapita

*M1 = fix effect
xtreg lnexpcap didsmel, fe cl(idkab)
eststo md1
outreg2 using "$xls/model4.xls",  replace bdec(3) sdec(2)  ctitle(FE) addtext(Daerah FE, YES, Covar, NO, Time FE, NO)

*M2 = M1 + time fix effect
xtreg lnexpcap didsmel i.tahun, fe cl(idkab)
eststo md2
outreg2 using "$xls/model4.xls",  append bdec(3) sdec(2)  ctitle(M1+timeFE) addtext(Daerah FE, YES, Covar, NO, Time FE, YES)

*M3 = M2 + j. smelter
xtreg lnexpcap didsmel smel i.tahun, fe cl(idkab)
eststo md3
outreg2 using "$xls/model4.xls",  append bdec(3) sdec(2)  ctitle(M2+jsmel) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M4 = M3 + j. tambang
xtreg lnexpcap didsmel smel tam i.tahun, fe cl(idkab)
eststo md4
outreg2 using "$xls/model4.xls",  append bdec(3) sdec(2)  ctitle(M3+jtam) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M5 = M4 + belanja pemerintah
xtreg lnexpcap didsmel smel tam lngovexp i.tahun, fe cl(idkab)
eststo md5
outreg2 using "$xls/model4.xls",  append bdec(3) sdec(2)  ctitle(M4+goxexp) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

*M6 = M5 + PDRB pertanian
xtreg lnexpcap didsmel smel tam lngovexp lnagri i.tahun, fe cl(idkab)
eststo md6
outreg2 using "$xls/model4.xls",  append bdec(3) sdec(2)  ctitle(M5+lnagri) addtext(Daerah FE, YES, Covar, YES, Time FE, YES)

esttab md1 md2 md3 md4 md5 md6, title("depent variable ln (expcap)") star(* 0.1 ** 0.05 *** 0.01) stats(N r2) indicate( "time fe = *.tahun")

***************spasial******************

//......................................................//
clear all

use spasial ,replace

//matrix pembobot inverse
spmatrix create idistance Wi
spmatrix summarize Wi

spmatrix dir

//gabung dengan utam
merge 1:m idkab using "$dta/setsmelter.dta"
bro

//set panel
xtset _ID tahun, yearly

//Aktivasi Map
grmap, activate

//Deteksi Gambar (.png)

*pdrb per kapita
grmap lnpdrbcap, clnumber(9) fcolor(Greens2) mosize(vvthin) t(2006) title("PDRB per kapita di tahun 2006")  name(x0, replace)
graph export "$graph/prdbcap_2006.png", replace

grmap lnpdrbcap, clnumber(9) fcolor(Greens2) mosize(vvthin) t(2016) title("PDRB per kapita di tahun 2016")  name(x1, replace)
graph export "$graph/prdbcap_2016.png", replace

grmap lnpdrbcap, clnumber(9) fcolor(Greens2) mosize(vvthin) t(2018) title("PDRB per kapita di tahun 2018")  name(x2, replace)
graph export "$graph/prdbcap_2018.png", replace

grmap lnpdrbcap, clnumber(9) fcolor(Greens2) mosize(vvthin) t(2021) title("PDRB per kapita di tahun 2021")  name(x3, replace)
graph export "$graph/prdbcap_2021.png", replace 

graph combine x0 x1 x2 x3
graph export "$graph/prdbcap.png", replace

*konsumi per kapita
grmap lnexpcap, clnumber(9) fcolor(Blues) mosize(vvthin) t(2006) title("Konsumsi RT per kapita di tahun 2006")  name(v0, replace)
graph export "$graph/expcap_2006.png", replace

grmap lnexpcap, clnumber(9) fcolor(Blues) mosize(vvthin) t(2016) title("Konsumsi RT per kapita di tahun 2016")  name(v1, replace)
graph export "$graph/expcap_2016.png", replace

grmap lnexpcap, clnumber(9) fcolor(Blues) mosize(vvthin) t(2018) title("Konsumsi RT per kapita di tahun 2018")  name(v2, replace)
graph export "$graph/expcap_2018.png", replace

grmap lnexpcap, clnumber(9) fcolor(Blues) mosize(vvthin) t(2021) title("Konsumsi RT per kapita di tahun 2021")  name(v3, replace)
graph export "$graph/expcap_2021.png", replace 

graph combine v0 v1 v2 v3
graph export "$graph/expcap.png", replace

*tambang nikel
grmap tam, clnumber(9) fcolor(Reds) mosize(vvthin) t(2016) title("tambang nikel beroperasi 2016")  name(ni2, replace)
graph export "$graph/tamnikel_2016.png", replace

grmap tam, clnumber(9) fcolor(Reds) mosize(vvthin) t(2021) title("tambang nikel beroperasi 2021")  name(ni3, replace)
graph export "$graph/tamnikel_2021.png", replace

graph combine ni2 ni3
graph export "$graph/tamnik.png", replace

*smeter
grmap smel, clnumber(9) fcolor(Oranges) mosize(vvthin) t(2016) title("smelter nikel beroperasi di tahun 2016")  name(sm2, replace)
graph export "$graph/smel_2016.png", replace

grmap smel, clnumber(9) fcolor(Oranges) mosize(vvthin) t(2021) title("smelter nikel beroperasi di tahun 2021")  name(sm3, replace)
graph export "$graph/smel_2021.png", replace

graph combine sm2 sm3
graph export "$graph/smel.png", replace


*bandingkan peta 2016
graph combine x1 v1 ni2 sm2
graph export "$graph/2016map.png", replace


*bandingkan peta 2021
graph combine x3 v3 ni3 sm3
graph export "$graph/2021map.png", replace

//Deteksi spatial depedency - uji pesaren's test

*Model C
xtreg lnpdrbcap i.nondsmel smel tam lngovexp lnagri, fe
xtcsd, pes abs

*Model D
xtreg lnexpcap i.nondsmel smel tam lngovexp lnagri, fe
xtcsd, pes abs

//Dampak spilover, spasial durbin model

*Model 3
spxtregress lnpdrbcap i.nondsmel smel tam lngovexp lnagri, fe dvarlag(Wi) ivarlag(Wi: smel tam lngovexp lnagri)
estat impact

*Model 4
spxtregress lnexpcap i.nondsmel smel tam lngovexp lnagri, fe dvarlag(Wi) ivarlag(Wi: smel tam lngovexp lnagri)
estat impact


/********************/

cap log close
clear