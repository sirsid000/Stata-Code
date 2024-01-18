clear

/*===============================================================*
Version		: 13 Januari 2024
Author		: Siddiq Robbani
Objective	: cleaning data core
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

log using "$log/datacore.log", replace

/*dataset ihk*/

import excel "$raw/clean.xlsx", sheet("ihk") firstrow clear
bro

keeporder provid tahun ihk

save "$dta/ihk.dta", replace //data ihk clear

/*dataset larangan ekspor*/

import excel "$raw/clean.xlsx", sheet("core") firstrow clear
bro

destring pdrb expcap pop govexp agri provid, replace

//gabung dengan ihk
merge m:1 provid tahun using "$dta/ihk.dta"
bro

*drop tahun
drop if tahun >2016
drop if tahun <2006
bro

/*konversi ke nilai rupiah*/

*pdrb miliar ke rupiah
bys idkab tahun: gen pdrb1 = pdrb*10^9
drop pdrb
ren pdrb1 pdrb 

*govexp miliar ke rupiah
bys idkab tahun: gen govexp1 = govexp*10^9
drop govexp
ren govexp1 govexp

*agri miliar ke rupiah
bys idkab tahun: gen agri1 = agri*10^9
drop agri
ren agri1 agri

/*membuat jadi konstan*/

*pengeluaran rt per kapita
bys idkab tahun: gen expcap1 = (expcap/ihk)*100
drop expcap
ren expcap1 expcap

*belanja pemerintah
bys idkab tahun: gen govexp1 = (govexp/ihk)*100
drop govexp
ren govexp1 govexp

*PDRB agri
bys idkab tahun: gen agri1 = (agri/ihk)*100
drop agri
ren agri1 agri


/*konversi menjadi log natural*/

*ln pdrb kapita"
bys idkab tahun: gen lnpdrbcap = ln(pdrb/pop)
label var lnpdrbcap "ln pdrb berlaku per kapita rupiah"
hist lnpdrbcap, frequency normal

*ln pengeluaran rumah tangga kapita"
bys idkab tahun: gen lnexpcap = ln(expcap*12)
label var lnexpcap "ln pengeluaran rumah tangga setahun rupiah"
hist lnexpcap, frequency normal

*ln govexp"
bys idkab tahun: gen lngovexp = ln(govexp/pop)
label var lngovexp "ln total pengeluaran pemerintah rupiah per kapita"
hist lngovexp, frequency normal

*ln agri"
bys idkab tahun: gen lnagri = ln(agri/pop)
label var lnagri "ln pdrb berlaku sektor pertanian per kapita rupiah"
hist lnagri, frequency normal

/*pembuatan dummy*/
	
*Membuat dummy after larangan nikel / after policy
gen timeban = 0
replace timeban = 1 if tahun >= 2014
tab timeban tahun
lab var timeban "1 larangan berlaku"
	
*Membuat dummy treated, daerah memiliki tambang nikel
gen aktnikel = 0
replace aktnikel = 1 if tam >= 1
tab aktnikel  tahun
lab var aktnikel  "1 daerah aktivitas nikel"

*membuat DiD larangan eksport
gen didbanexp = timeban*aktnikel 
lab var didbanexp "diff in diff larangan eksport"
tab didbanexp tahun

/*variabel label*/

lab var idkab "id kabupaten/kota"
lab var tahun "tahun observasi"
lab var smel "jumlah smelter nikel beroperasi"
lab var tam "jumlah tambang nikel beroperasi"

/*save data set*/

keeporder kabu idkab tahun lnpdrbcap lnexpcap aktnikel timeban didbanexp smel tam lngovexp lnagri
bro

save "$dta/setbanexp.dta", replace //data DiD clear


*****************************************************
*****************************************************

/*dataset smelter nikel*/

import excel "$raw/clean.xlsx", sheet("core") firstrow clear
bro

destring pdrb expcap pop govexp agri provid, replace

//gabung dengan ihk
merge m:1 provid tahun using "$dta/ihk.dta"
bro

*drop tahun
drop if tahun <2006

/*konversi ke nilai rupiah*/
*pdrb miliar ke rupiah
bys idkab tahun: gen pdrb1 = pdrb*10^9
drop pdrb
ren pdrb1 pdrb 

*govexp miliar ke rupiah
bys idkab tahun: gen govexp1 = govexp*10^9
drop govexp
ren govexp1 govexp

*agri miliar ke rupiah
bys idkab tahun: gen agri1 = agri*10^9
drop agri
ren agri1 agri

/*membuat jadi konstan*/
*pengeluaran rt per kapita
bys idkab tahun: gen expcap1 = (expcap/ihk)*100
drop expcap
ren expcap1 expcap

*belanja pemerintah
bys idkab tahun: gen govexp1 = (govexp/ihk)*100
drop govexp
ren govexp1 govexp

*PDRB agri
bys idkab tahun: gen agri1 = (agri/ihk)*100
drop agri
ren agri1 agri

/*konversi menjadi log natural*/
*ln pdrb kapita"
bys idkab tahun: gen lnpdrbcap = ln(pdrb/pop)
label var lnpdrbcap "ln pdrb berlaku per kapita rupiah"
hist lnpdrbcap, frequency normal

*ln pengeluaran rumah tangga kapita"
bys idkab tahun: gen lnexpcap = ln(expcap*12)
label var lnexpcap "ln pengeluaran rumah tangga setahun rupiah"
hist lnexpcap, frequency normal

*ln govexp"
bys idkab tahun: gen lngovexp = ln(govexp/pop)
label var lngovexp "ln total pengeluaran pemerintah rupiah"
hist lngovexp, frequency normal

*ln agri"
bys idkab tahun: gen lnagri = ln(agri/pop)
label var lnagri "ln pdrb berlaku sektor pertanian per kapita rupiah"
hist lnagri, frequency normal

/*pembuatan dummy*/

*Membuat dummy pretend smelter nikel
tab idkab tahun if smel>=1

gen smelpretend = 0
replace smelpretend = 1 if idkab == 7404 
replace smelpretend = 1 if idkab == 7203
replace smelpretend = 1 if idkab == 7212 
replace smelpretend = 1 if idkab == 7325 
replace smelpretend = 1 if idkab == 7303 
replace smelpretend = 1 if idkab == 7403 
replace smelpretend = 1 if idkab == 7408 

lab var smelpretend "1 daerah smelter nikel pretend"

*Membuat dummy daerah memiliki smelter nikel
gen didsmel = 0
replace didsmel = 1 if smel >= 1
tab didsmel tahun
lab var didsmel "1 daerah smelter nikel"

*Membuat dummy daerah non smelter nikel for spatial 
gen nondsmel = 0
replace nondsmel = 1 if smel < 1
tab nondsmel tahun 
lab var nondsmel "1 daerah smelter tidak beroperasi"

/*variabel label*/

lab var idkab "id kabupaten/kota"
lab var tahun "tahun observasi"
lab var smel "jumlah smelter nikel beroperasi"
lab var tam "jumlah tambang nikel beroperasi"

/*save data set*/

keeporder kabu idkab tahun lnpdrbcap lnexpcap didsmel smel tam lngovexp lnagri nondsmel smelpretend
bro

save "$dta/setsmelter.dta", replace //data DiD clear

*done*
cap log close