// TODO: Set to local repo path
local the_folder "[]/stata/"

cd "`the_folder'"
global base "`the_folder'"

// Install needed packages
ssc install cleanplots, replace
net install grc1leg, replace from(http://www.stata.com/users/vwiggins/)
ssc install reghdfe
ssc install ftools
ssc install estout
ssc install confirmdir, replace
set scheme cleanplots
set varabbrev on

// Create CPI index from FRED data
import fred CPALTT01USA661S, clear
generate year = yofd(daten)
keep if year >= 1960 & year <= 2020
summarize CPALTT01USA661S if year == 2018
generate double cpi_annual = CPALTT01USA661S / `r(mean)'
keep year cpi_annual
save "cpi_annual_fred.dta", replace

******



clear all
infile using NLSY.dct

run NLSY-value-labels.do

rename R0000100 id



rename R0000500 yob
rename R0000300 mob


gen months = mob - R0329200
replace months = 0 if R0329200 == - 5
gen age = 1980 - (1900 + yob) + months/12
replace age = floor(age)
*AFQT correction

gen agex = age
replace agex = 16 if age == 15
foreach j in afqt  {
	if "`j'" == "afqt" {
		local s R0618301
		local w R0405201
	}

	rename  `s' `j'
	replace `j' = . if `j' < 0
	*compute percentile of weighted people
	gen afqt_rel = .

	forval t = 16 / 23 {
		display `t'
		xtile hola = `j' if agex == `t' [weight = `w'],  nq(100)
		replace `j'_rel = hola if agex == `t' & R0405201 > 0
		drop hola
	}


}



drop age agex
gen age = 1980 - (1900 + yob) + months/12
gen age2 = age*age
gen age3 = age*age*age





*drop hispanics
drop if R7093000 == 1
drop if R0150000 == 1

*drop immigrants
keep if R0000700 == 1
drop if R0900900 == 0





drop R4829000-R4848200

*drop women
keep if R0214800 == 1
drop R0214800

gen black = 0 if R0172700 == 1
replace black = 1 if R0172700 == 2

drop if black == .



gen been_prison = 0 if R0311100 <= 0
replace been_prison = 1 if R0311100 >= 1 & R0311100 != .


local y 2008
foreach j in T2075300 T3043900 T3976100 T4914400 {
	gen incarc`y' = 0 if `j' == 0
	replace incarc`y' = 1 if `j' == 1
	drop `j'
	local y = `y' + 2
}


local y 1979
foreach j in R0015600 R0228500 R0416800 R0663900 R0905300 R1205200 R1604500 R1905000 R2305900 R2508400 R2907500 R3109600 R3509600 R3709600 R4137400 R4526000 R5221300 R5821300 R6540000 R7103200 R7810100 T0014000 T1213900 T2272400 T3212500 T4200600 T5175600 {
	gen school`y' = 0
	replace school`y' = 1 if `j' == 1
	drop `j'
	if `y' < 1994 {
		local y = `y' + 1
	}
	else {
		local y = `y' + 2
	}
}


local y 1979
foreach j in R0188000  {
	gen jail`y' = 0 if `j' > 0
	replace jail`y' = 1 if `j' == 3
	drop `j'
	local y = `y' + 1
}


foreach j in  R0402800 R0612100 R0828400 R1075700 R1451400 R1798600 R2160200 R2369100 R2500000 R2900000 R3100000 R3500000 R3700000 R4100300 R4500300 R5200300 R5800200 R6530300 R7090700 R7800600 T0001000 T1200800 T2260700 T3195700 T4181500 T5152100 {

	gen jail`y' = 0 if `j' > 0
	replace jail`y' = 1 if `j' == 5
	*display `y'
	*display "`j'"

	cap replace jail`y' = 0 if incarc`y' == 0 & jail`y' != 1
	cap replace jail`y' = 1 if incarc`y' == 1

	cap drop incarc`y'
	*drop `j'
	if `y' < 1994 {
		local y = `y' + 1
	}
	else {
		local y = `y' + 2
	}


}



local y 1979
foreach j in R0155400 R0312300 R0482600 R0782101 R1024001 R1410701 R1778501 R2141601 R2350301 R2722501 R2971401 R3279401 R3559001 R3897101 R4295101 R4982801 R5626201 R6364601 R6909701 R7607800 R8316300 T0912400 T2076700 T3045300 T3977400 T4915800 T5619500 T8115400 {
	local y1 = `y' - 1
	gen inc`y1' = `j' if `j' > 0
	drop `j'
	if `y' < 1994 {
		local y = `y' + 1
	}
	else {
		local y = `y' + 2
	}
}



local y 1979
foreach j in R0216101 R0405201 R0614601 R0896701 R1144401 R1519601 R1890201 R2257301 R2444501 R2870001 R3073801 R3400201 R3655801 R4006301 R4417401 R5080401 R5165701 R6466301 R7006201 R7703401 R8495800 T0987400 T2209700 T3107500 T4112000 T5022200 T5770500 T8218400 {
	gen cross`y' = `j' if `j' > 0
	drop `j'
	if `y' < 1994 {
		local y = `y' + 1
	}
	else {
		local y = `y' + 2
	}
}


local y 1979
foreach j in R0216100 R0405200 R0614600 R0896700 R1144400 R1519600 R1890200 R2257300 R2444500 R2870000 R3073800 R3400200 R3655800 R4006300 R4417400 R5080400 R5165700 R6466300 R7006200 R7703400 R8495700 T0987300 T2209600 T3107400 T4111900 T5022100 T5770400 T8218300 {
	gen samp`y' = `j' if `j' > 0
	drop `j'
	if `y' < 1994 {
		local y = `y' + 1
	}
	else {
		local y = `y' + 2
	}
}


local y 1979
foreach j in R0215710 R0407300 R0646600 R0896800 R1145200 R1520400 R1891100 R2258200 R2445600 R2871400 R3075100 R3401800 R3657200 R4007700 R4418800 R5081800 R5167100 R6479900 R7007600 R7704900 R8497300 T0989100 T2210900 T3108800 T4113300 T5024700 T5772700 T8219900 {
	local y1 = `y' - 1
	gen hours`y1' = `j' if `j' > 0
	drop `j'
	if `y' < 1994 {
		local y = `y' + 1
	}
	else {
		local y = `y' + 2
	}
}

local y 1979
foreach j in R0216400 R0405700 R0602810 R0897910 R1144800 R1520000 R1890700 R2257800 R2445200 R2870800 R3074500 R3401200 R3656600 R4007100 R4418200 R5081200 R5166500 R6479100 R7006800 R7704100 R8496500 T0988300 T2210300 T3108200 T4112700 T5023100 T5771000 T8219100 {
	gen region`y' = `j' if `j' > 0
	drop `j'
	if `y' < 1994 {
		local y = `y' + 1
	}
	else {
		local y = `y' + 2
	}
}

gen educ = .
gen comp = .
local y 1979
foreach j in R0017300 R0229200 R0417400 R0664500 R0905900 R1205800 R1605100 R1905600 R2306500 R2509000 R2908100 R3110200 R3510200 R3710200 R4137900 R4526500 R5221800 R5821800 R6540400 R7103600 R7810500 T0014400 T1214300 T2272800 T3212900 T4201100 T5176100 {
	replace comp = max(comp, `y') if `j' < 50 & `j' > educ & `j' <= 16
	replace educ = max(educ, `j') if `j' < 50
	gen degree`y' = `j' if `j' > 0 & `j' < 50
	drop `j'
	if `y' < 1994 {
		local y = `y' + 1
	}
	else {
		local y = `y' + 2
	}

}




save temp, replace

clear
use temp
keep id afqt_rel cross1980
collapse (max) afqt_rel cross1980, by(id)
sort id
save id_afqt_rel, replace

local D 10
clear
use id_afqt_rel
cap drop decile
xtile decile = afqt_rel [weight = cross1980], nq(`D')
sort id
save id_afqt_rel, replace

clear
use temp
rename R0614700 asvab_weight
foreach j in R0615000 R0615100 R0615200 R0615300 R0615400 R0615500 R0615600 R0615700 R0615800 R0615900 {
	reg `j' age [weight = asvab_weight]
	predict hola , res
	replace `j' = hola
	drop hola
}


collapse (max)asvab_weight  yob comp educ age black R0615000 R0615100 R0615200 R0615300 R0615400 R0615500 R0615600 R0615700 R0615800 R0615900 , by(id)



keep id black yob comp educ asvab_weight
sort id
save id_info, replace



clear
use temp

keep inc* hours* school* jail*   id black region*  yob comp educ degree* been_prison samp*

reshape long inc hours school jail region degree samp, i(id) j(year)

sort year

merge m:1 year using cpi_annual_fred
keep if _merge == 3
drop _merge


replace inc = inc/cpi_annual
drop cpi




keep id year school region degree inc hours jail samp




sort id year
by id: gen cum_hours=sum(hours)
by id: gen cum_inc=sum(inc)
by id: gen cum_jail=sum(jail)

sort id year
save id_year, replace







******




clear
use temp
*erase temp.dta

drop degree*

local w 2000
forval t = 1/2185 {

	*display `w'

	if `w' == 12600 {
		local w 74400
	}

	if `w' == 71800 {
		local w 106500
	}

	if `w' == 79600 {
		local w 114300
	}

	if `w' == 119500 {
		local w 154200
	}

	if `w' == 159400 {
		local w 194100
	}




	if `w' <= 9999 {
		local wx 000`w'
	}
	else if `w' <= 99999 {
		local wx 00`w'
	}

	else if `w' <= 999999 {
		local wx 0`w'
	}

	else if `w' > 999999 {
		local wx `w'
	}

	display `w'
	rename W`wx' hw`t'


	local q = `t' -1
	capture confirm variable hw`q'
	if !_rc {
		   *di in red "weight exists"
	}
	else {
		   di in red "hw`q' does not exist"
	}

	sum  hw`t'
	if `r(max)' > 250 {
		display `w'
		display `t'

		stop
	}


	if `w' == 199200 {
		local w = 234000 - 100
	}


	if `w' == 239200 {
		local w = 274500 - 100
	}

	if `w' == 279600 {
		local w = 314400 - 100
	}

	if `w' == 319500 {
		local w = 354300 - 100
	}

	if `w' == 359400 {
		local w = 394200 - 100
	}

	if `w' == 399300 {
		local w = 434100 - 100
	}

	if `w' == 439300 {
		local w = 474600 - 100
	}

	if `w' == 479700 {
		local w = 514500 - 100
	}

	if `w' == 519600 {
		local w = 554400 - 100
	}

	if `w' == 559500 {
		local w = 594300 - 100
	}

	if `w' == 599400 {
		local w = 634200 - 100
	}

	if `w' == 639300 {
		local w = 674100 - 100
	}

	if `w' == 684500 {
		local w = 745800 - 100
	}

	if `w' == 756100 {
		local w = 816900 - 100
	}

	if `w' == 827200 {
		local w = 888100 - 100
	}

	if `w' == 898400 {
		local w = 948600 - 100
	}


	if `w' == 960700 {
		local w = 1016700 - 100
	}

	if `w' == 1027000 {
		local w = 1076700 - 100
	}

	if `w' == 1087100 {
		local w = 1135900 - 100
	}

	if `w' == 1146300 {
		local w = 1196600 - 100
	}

	if `w' == 1210400 {
		local w = 1272000 - 100
	}

	if `w' == 1282300 {
		local w = 1357600 - 100

	}

	if `w' == 1367400 {
		local w = 1415800 - 100

	}






	local w = `w' + 100




}


local w 61200
forval t = 1/2185 {

	if `w' == 71800 {
		local w 106500
	}

	if `w' == 111700 {
		local w 146400
	}

	if `w' == 151600  {
		local w 186300
	}

	if `w' == 191500  {
		local w 226200
	}

	if `w' == 231400  {
		local w 266600
	}

	if `w' == 271900  {
		local w 306600
	}


	if `w' == 311800  {
		local w 346500
	}


	if `w' == 351700  {
		local w 386400
	}


	if `w' == 391600  {
		local w 426300
	}

	if `w' == 431500  {
		local w 466700
	}

	if `w' == 472000  {
		local w 506700
	}

	if `w' == 511900  {
		local w 546600
	}

	if `w' == 551800  {
		local w 586500
	}

	if `w' == 591700  {
		local w 626400
	}

	if `w' == 631600  {
		local w 666300
	}

	if `w' == 671500  {
		local w 732700
	}

	if `w' == 743200  {
		local w 803900
	}

	if `w' == 814300  {
		local w 875000
	}

	if `w' == 885400  {
		local w 932100
	}

	if `w' == 942500  {
		local w 997600
	}

	if `w' == 1009800  {
		local w 1059600
	}


	if `w' == 1070000  {
		local w 1116000
	}

	if `w' == 1126500  {
		local w 1174000
	}

	if `w' == 1184500  {
		local w 1249700
	}




	if `w' == 1263600  {
		local w 1282400
	}


	if `w' == 1292800  {
		local w 1367500
	}


	if `w' == 1377400   {
		local w 1426000
	}







	if `w' <= 99999 {
		local wx 00`w'
	}
	else if `w' <= 999999 {
		local wx 0`w'
	}

	if `w' > 999999 {
		local wx `w'
	}

	display `w'
	display `t'
	rename W`wx' emp`t'

	local q = `t' -1
	capture confirm variable emp`q'
	if !_rc {
		   *di in red "weight exists"
	}
	else {
		   di in red "hw`q' does not exist"
	}

	local w = `w' + 100
}




replace yob = yob + 1900
gen date=ym(yob, mob)

keep id emp* hw*  date

save temp, replace



local l = 2185



local w = 0
forval x = 1(100)`l' {

	local w = 1 + `w'
	local b = `x' + 99
	local these
	forval t = `x'/`b' {
		if `t' <= `l' {
			local these `these' emp`t' hw`t'
		}
	}
	clear
	use temp
	keep id `these'  date

	reshape long emp hw, i(id) j(t)
	keep id t emp hw date
	sort id t

	sum emp* hw*
	save temp`w', replace


}

*foreach k in emp hw {
clear
local w 22
forval x = 1/`w' {
	append using temp`x'
	erase temp`x'.dta
}
save id_emp, replace


clear
use id_emp

gen date2 = mdy(1,1,1978) - 14
gen date3 = date2 + t*7

replace hw = . if hw < 0
replace hw = min(hw, 7 * 16)


gen e = 0 if emp > 0 & emp != .
replace e = 1 if emp > 5 & emp != .
replace e = 1 if emp == 3 & emp != .
gen n = 0 if emp > 0 & emp != .
replace n = 1 if emp == 2 & emp != .
replace n = 1 if emp == 4 & emp != .
replace n = 1 if emp == 5 & emp != .
gen u = 0 if emp > 0 & emp != .
replace u = 1 if emp == 4


gen year = year(date3)



drop if emp == 0

gen obs = 1

collapse (sum) hw e n u obs, by(id year)
drop if obs < 51

sort id year

save id_emp_year, replace




****compute experience at each year
clear
use id_emp

gen date2 = mdy(1,1,1978) - 14
gen date3 = date2 + t*7

gen year = year(date3)
gen month = month(date3)

sort id year date3
merge id year using id_year




gen e = 0 if emp > 0
replace e = 1 if emp > 5
gen n = 0 if emp > 0
replace n = 1 if emp > 3 & emp <= 5
gen u = 0 if emp > 5
replace u = 1 if emp == 4
gen o = 0 if emp > 3
replace o = 1 if emp == 5


xtset id t

foreach j in e n u o hw {
	replace `j' = . if emp == 7

}



by id: gen cum_exp=sum(e)
by id: gen cum_hw=sum(hw)

collapse (max) cum_exp cum_hw, by(id year) fast
drop if id == .
sort id year
save id_exp, replace




*******Prepare data for model
clear all
use id_emp_year
sort id
merge m:1 id using id_info
drop _merge
sort id year
merge 1:1 id year using id_year
keep if _merge == 3



gen E = 1 if e >= 25 & e != .
replace E = 0 if e < 25
replace E = 0 if hours < 20*25
replace E = 0 if jail == 1 & e == .
gen N = -E + 1

foreach j in inc hours {
	replace `j' = . if E == 0


}

gen age = year - (1900 + yob)

replace hours = . if hours > (52 * 7 * 16)


gen inc_original = inc




gen loginc = log(inc)
gen loghours = log(hours)
gen inch = inc/hours
gen loginch = log(inc/hours)




keep if age >= 23


tsset id year

save super, replace


clear all
use super

xtset id age

forval v = 0 / 5 {
	replace samp = F1.samp if samp == .
}

save super, replace

******the dataset

clear all
use super
drop _merge loginc inch loginch
cap drop decile

merge id using  id_afqt_rel
drop _merge



keep if decile != .
keep if black != .

xtset id age


keep if age <= 54



order age inc_original samp

replace hours = . if E == 0
drop if samp == .
replace hours = . if hours == 0


gen inch = inc/hours
replace inch = . if E != 1

gen log_inch = log(inch)

sum inch [weight = samp]
gen inch_norm = inch / `r(mean)'
global mean_inch = `r(mean)'



replace hours = hours / 52

gen hours_norm = hours / 112


keep id age hours_norm E decile black samp inc inch_norm log_inch year


save the_data, replace



****for model
confirmdir "../nlsy_data"
if `r(confirmdir)' mkdir "../nlsy_data"
forval d = 1 / 10 {
	clear
	use the_data
	rename samp weight
	keep id age hours_norm weight E decile black inch_norm
	keep if decile == `d'
	drop decile


	tab age [weight = weight], sum(E)

	reshape wide hours weight E inch_norm, i(id) j(age )

	outsheet using "../nlsy_data/afqt_decile_`d'.csv", comma replace
}

*Figure 1 & B1
clear all
use "super.dta"



local these inc hours  E loginc loginch


replace hours = . if hours > (100*52)
drop inc
rename inc_original inc



replace inc = . if E == 0
replace hours = . if E == 0
replace loginc = . if E == 0
replace loginch = . if E == 0
replace inch = . if E == 0


replace inch = inc/hours

replace inc = inc/1000
replace hours = hours/52

foreach j in `these' {
	gen `j'_sd = `j'
}

drop obs
gen obs = 1 if E != .

keep if age >= 23 & age <= 54

collapse `these' (sum) obs  (semean) *_sd [weight = samp], by(black age)


foreach j in E  {
	gen `j'_u = `j' + 1.96 * ((`j' * (1 - `j'))/obs)^0.5
	gen `j'_d = `j' - 1.96 * ((`j' * (1 - `j'))/obs)^0.5
}


foreach j in inc  hours loginc loginch {
	gen `j'_u = `j' + `j'_sd * 1.96
	gen `j'_d = `j' - `j'_sd * 1.96
}

graph drop _all
foreach j in inc E hours loginc loginch {

	local x
	if "`j'" == "inc" {
		local t Annual earnings cond. on working
		local ylab ylabel( 20 "20k" 40 "40k" 60 "60k" 80 "80k" 100 "100k" 120 "120k")
	}

	if "`j'" == "loginc" {
		local t Log(earnings)
		local ylab ylabel(#4)
	}

	if "`j'" == "loginch" {
		local t Log(hourly earnings)
		local ylab ylabel(#4)
	}

	if "`j'" == "hours" {
		local t Hours worked per week cond. on working
		local ylab ylabel(#4)
	}

	if "`j'" == "E" {
		local t Employment
		local ylab ylabel(#4)
	}

	twoway (line `j' `j'_u `j'_d age if black == 1  , lcolor(black black black) lpattern(dash dash dash) lwidth(thick thin thin)) ///
		(line `j' `j'_u `j'_d age if black == 0  , lcolor(gs10 gs10 gs10) lpattern( solid dash  dash) lwidth(thick thin thin)), ///
		name(`j') subtitle("`t'", lcolor(black))  `ylab' ///
		legend(order(1 "Black" 4 "White" ) pos(6) rows(1)) xtitle("Age") ytitle("") plotregion(fcolor(white)) graphregion(fcolor(white)) xlabel(23 30 35 40 45 50 54)
}


grc1leg  loginc loginch, legendfrom(loginc)   plotregion(fcolor(white)) graphregion(fcolor(white))
graph export "../figures/d_logearnings.png", replace



clear

use id_year
sort id year
merge m:1 id using id_info
drop _merge
sort id year
merge 1:1 id year using id_exp
drop _merge

xtset id year

local them cum_exp cum_hw
foreach j in `them' {
	gen uff = L1.`j'
	replace `j' = uff
	replace `j' = 0 if `j' == . & year == 1979
	drop uff
}

replace cum_exp = cum_exp / 52

gen age = year - 1900 - yob


gen inch = inc/hours
gen loginc = log(inc)
gen loginch = log(inch)



replace cum_hw = cum_hw/1000


foreach j in `them' {
	gen `j'_sd = `j'
}

keep if age >= 23 & age <= 54

collapse `them'  (semean) *_sd [weight = samp], by(age black) fast

foreach j in `them' {
	gen `j'_u = `j' + `j'_sd * 1.96
	gen `j'_d = `j' - `j'_sd * 1.96
}


foreach j in `them' {



	if "`j'" == "cum_exp" {
		local t "Years of work experience"
		local ylab ylabel(#4)
	}
	if "`j'" == "cum_hw" {
		local t "Cumulative hours of work experience"
		local ylab ylabel(0 "0" 20 "20k" 40 "40k" 60 "60k" 80 "80k")
	}


	twoway (line `j' `j'_u `j'_d age if black == 1  , lcolor(black black black) lpattern(dash dash dash) lwidth(thick thin thin)) ///
		(line `j' `j'_u `j'_d age if black == 0  , lcolor(gs10 gs10 gs10) lpattern(solid dash  dash) lwidth(thick thin thin)), ///
		name(`j') subtitle("`t'", lcolor(black)) `ylab' ///
		legend(order(1 "Black" 4 "White" ) pos(6) rows(1)) xtitle("Age") ytitle("") plotregion(fcolor(white)) graphregion(fcolor(white)) xlabel(23 30 35 40 45 50 54)
}



grc1leg  E hours cum_hw inc, legendfrom(cum_hw)   plotregion(fcolor(white)) graphregion(fcolor(white))
graph export "../figures/d_employed_hours_exp_earnings.png", replace




*Figure 2


******
****check out men that always work


clear all
use "super.dta"

keep if age >= 23 & age <= 54

drop if school == 1
bysort id: egen always_work = min(E)
drop if always_work == 0



gen inc_sd = inc_original


collapse inc_original (semean) inc_sd [weight = samp], by( black age)
keep if age >= 23 & age <= 54



gen inc_u = inc_original + 1.96 * inc_sd
gen inc_d = inc_original - 1.96 * inc_sd

sort black age
save always_work_data, replace


twoway (line inc_original inc_u inc_d age if black == 1  , lcolor(black black black) lpattern(dash dash dash) lwidth(thick normal normal)) ///
	(line inc_original inc_u inc_d age if black == 0  , lcolor(gray gray gray) lpattern(solid dash dash) lwidth(thick normal normal)), ///
     ///
 legend(order(1 "Black" 4 "White" ) pos(6) rows(1)) ytitle("Annual earnings") xtitle("Age") plotregion(fcolor(white)) graphregion(fcolor(white)) ///
 xlabel(23 30 35 40 45 50 54) subtitle("By age") name(age)

****check out men that always work by hours worked
clear
use "super.dta"

tsset id age

keep if age >= 23 & age <= 54

drop if school == 1
bysort id: egen always_work = min(E)
drop if always_work == 0



gen inc_sd = inc_original

drop if hw == 0
keep if age >= 23 & age <= 54

gen cum_hw = hw
replace cum_hw = cum_hw + L1.cum_hw if L1.cum_hw != .

xtile htile = cum_hw, nq(10)


collapse inc_original (semean) inc_sd [weight = samp], by( black htile)




gen inc_u = inc_original + 1.96 * inc_sd
gen inc_d = inc_original - 1.96 * inc_sd

sort black htile

save always_work_hour_data, replace

twoway (line inc_original inc_u inc_d htile if black == 1  , lcolor(black black black) lpattern(dash dash dash) lwidth(thick normal normal)) ///
(line inc_original inc_u inc_d htile if black == 0  , lcolor(gray gray gray) lpattern(solid dash dash) lwidth(thick normal normal)), ///
   ///
legend(order(1 "Black" 4 "White" ) pos(6) rows(1)) ytitle("Annual earnings") xtitle("Decile of cumulative hours worked") plotregion(fcolor(white)) graphregion(fcolor(white)) ///
xlabel(1(1)10) subtitle("By cumulative hours worked") name(hw, replace)


grc1leg  age hw, legendfrom(age)   plotregion(fcolor(white)) graphregion(fcolor(white))
graph export "../figures/d_earnings_byage_byhours.png", replace



***Figure 3

clear all
use id_afqt_rel
merge id using id_info
gen obs = 1
collapse (sum) obs [weight = cross1980], by(black decile)
keep if black != .
keep if decile != .
bysort black: egen ach = sum(obs)
replace obs = obs/ach
save able_distrib_within, replace

twoway (bar obs decile if black == 0,  fcolor(cyan) lcolor(cyan)) ///
(bar obs decile if black == 1,  fcolor(none) lcolor(black)) ///
  , ///
  xlabel(1 2 3 4 5 6 7 8 9 10) ///
 legend(order(2 "Black" 1 "White") ) plotregion(fcolor(white)) graphregion(fcolor(white)) ///
 xtitle("AFQT decile") ytitle("Share of population by race") name(fig1)

clear
use id_afqt_rel
merge id using id_info
gen obs = 1
collapse (sum) obs [weight = cross1980], by(black decile)
keep if black != .
keep if decile != .
gen ei = 1
bysort decile: egen ach = sum(obs)
replace obs = obs/ach
replace obs = 1 if black == 0

twoway (bar obs decile if black == 0,  fcolor(cyan) lcolor(cyan)) ///
 (bar obs decile if black == 1,  fcolor(black) lcolor(black)) ///
 , ///
   xlabel(1 2 3 4 5 6 7 8 9 10) ///
 legend(order(2 "Black" 1 "White") ) plotregion(fcolor(white)) graphregion(fcolor(white)) ///
 xtitle("AFQT decile") ytitle("Share of population within decile") name(fig2)

graph combine fig1 fig2, plotregion(fcolor(white)) graphregion(fcolor(white))
graph export "../figures/d_afqt_distribution.png", replace







*****Figure 4, 5, B2



******earnings per decile_black
clear
use the_data

gen inch = inch_norm * $mean_inch
gen hours = hours_norm * 112

gen hours_sd = hours

keep if age >= 23 & age <= 54

gen inch_sd = inch

replace decile = 5 if decile >= 5 & decile != .

gen age_cat = .
forval x = 1 / 4	{
	replace age_cat = `x' if age >= 23 + (`x' - 1) * 8  & age < 23 + `x' * 8
}


gen obs = 1 if E != .

collapse inch E hours (semean) inch_sd hours_sd (sum) obs [weight = samp], by(age_cat black decile)


foreach j in E  {
	gen `j'_u = `j' + 1.96 * ((`j' * (1 - `j'))/obs)^0.5
	gen `j'_d = `j' - 1.96 * ((`j' * (1 - `j'))/obs)^0.5
}

foreach j in inch hours {
	gen `j'_u = `j' + `j'_sd * 1.96
	gen `j'_d = `j' - `j'_sd * 1.96
}



replace age = age - 0.05 if black == 1
replace age = age + 0.05 if black == 0

local lbl_inch = "hearnings"
local lbl_E = "employed"
local lbl_hours = "hours"
foreach j in inch E hours {
	local these
	graph drop _all
	forval d = 1 / 5 {
		local dd " `d'"
		local l legend(off)
		if `d' == 5 {
			local dd "s 5-10"
		}
		if `d' == 10 {
			local l legend(order(1 "Black" 4 "White") pos(6) rows(1) )
		}
		twoway (scatter `j'  age if black == 1 & decile == `d' , mcolor(black ) msize(large) msymbol(D)  ) ///
			(scatter `j' age if black == 0 & decile == `d' , mcolor(gs10 )   msize(large) msymbol(O)  ) ///
			(rcap  `j'_u `j'_d age if black == 1 & decile == `d' , lcolor(black )  ) ///
			(rcap `j'_u `j'_d age if black == 0 & decile == `d' , lcolor(gs10 ) ), ///
			xlabel(1 "23-30" 2 "31-38" 3 "39-46" 4 "47-54")  ///
			ytitle("") name(fig`d') xtitle("Age") subtitle("AFQT decile`dd'") `l'

		local these `these' fig`d'

	}



	graph combine `these', xsize(10) ysize(4) rows(1)  ycommon
	graph export "../figures/d_`lbl_`j''_byagroups.png", replace

}


*Figure B3

***** targets
clear all
use "super.dta"

keep if age >= 23 & age <= 54

drop if school == 1
bysort id: egen always_work = min(E)
drop if always_work == 0

local these inc

replace hours = . if hours > (100*52)
drop inc
rename inc_original inc


replace inc = . if E == 0
replace hours = . if E == 0
replace loginc = . if E == 0
replace loginch = . if E == 0
replace inch = . if E == 0


replace inch = inc/hours

replace hours = hours/52

foreach j in `these' {
	gen `j'_sd = `j'
}

drop obs
gen obs = 1 if E != .

bysort id: egen max_ed = max(degree)
drop degree
rename max_ed degree
gen deg = 0 if degree < 12
replace deg = 1 if degree == 12
replace deg = 2 if degree > 12 & degree < 16
replace deg = 3 if degree >= 16 & degree < 50

gen age_cat = .
forval x = 1 / 4	{
	replace age_cat = `x' if age >= 23 + (`x' - 1) * 8  & age < 23 + `x' * 8
}



collapse `these' (sum) obs  (semean) *_sd [weight = samp], by(black age_cat deg)




foreach j in inc   {
	gen `j'_u = `j' + `j'_sd * 1.96
	gen `j'_d = `j' - `j'_sd * 1.96
}


replace age = age - 0.05 if black == 1
replace age = age + 0.05 if black == 0

local lbl_inc = "earnings"
foreach j in inc  {
	graph drop _all
	forval d = 0 / 3 {
		local ylab ylabel(#4)
		if `d' == 0 {
			local dd Less than high school
			*local ylab ylabel( 20 "20k" 60 "60k"  100 "100k" 140 "140k"  180 "180k")
		}
		if `d' == 1 {
			local dd High school
			*local ylab ylabel( 20 "20k" 60 "60k"  100 "100k" 140 "140k"  180 "180k")
		}
		if `d' == 2 {
			local dd Some college
			*local ylab ylabel( 20 "20k" 60 "60k"  100 "100k" 140 "140k"  180 "180k")
		}
		if `d' == 3 {
			local dd College
			*local ylab ylabel( 20 "20k" 60 "60k"  100 "100k" 140 "140k"  180 "180k")
		}

		local x
		if "`j'" == "inc" {
			local t Annual earnings cond. on working

		}

		if "`j'" == "hours" {
			local t Hours worked per week cond. on working
			local ylab ylabel(#4)
		}

		if "`j'" == "E" {
			local t Employment
			local ylab ylabel(#4)
		}

		twoway (scatter `j'  age if black == 1 & deg == `d' , mcolor(black )  msymbol(D)  ) ///
			(scatter `j' age if black == 0 & deg == `d' , mcolor(gs10 )   msymbol(O)  ) ///
			(rcap  `j'_u `j'_d age if black == 1 & deg == `d' , lcolor(black )  ) ///
			(rcap `j'_u `j'_d age if black == 0 & deg == `d' , lcolor(gs10 ) ), ///
			name(fig`d') subtitle("`dd'", lcolor(black))  `ylab' ///
			legend(order(1 "Black" 2 "White" ) pos(6) rows(1)) xtitle("Age") ytitle("") plotregion(fcolor(white)) graphregion(fcolor(white)) xlabel(1 "23-30" 2 "31-38" 3 "39-46" 4 "47-54")




	}

	grc1leg  fig0 fig1 fig2 fig3, legendfrom(fig0)
	graph export "../figures/d_`lbl_`j''_byedu.png", replace
}



*Figure B4


***** by hours worked
clear all
use "super.dta"

keep if age >= 23 & age <= 54

drop if school == 1
bysort id: egen always_work = min(E)
drop if always_work == 0

local these inc


replace hours = . if hours > (100*52)
drop inc
rename inc_original inc



replace inc = . if E == 0
replace hours = . if E == 0
replace loginc = . if E == 0
replace loginch = . if E == 0
replace inch = . if E == 0


replace inch = inc/hours


replace hours = hours/52

foreach j in `these' {
	gen `j'_sd = `j'
}

drop obs
gen obs = 1 if E != .

bysort id: egen max_ed = max(degree)
drop degree
rename max_ed degree
gen deg = 0 if degree < 12
replace deg = 1 if degree == 12
replace deg = 2 if degree > 12 & degree < 16
replace deg = 3 if degree >= 16 & degree < 50

tsset id age
gen cum_hw = hw
replace cum_hw = cum_hw + L1.cum_hw if L1.cum_hw != .

xtile htile = cum_hw, nq(5)


collapse `these' (sum) obs  (semean) *_sd [weight = samp], by(black htile deg)


rename htile age

foreach j in inc   {
	gen `j'_u = `j' + `j'_sd * 1.96
	gen `j'_d = `j' - `j'_sd * 1.96
}


replace age = age - 0.05 if black == 1
replace age = age + 0.05 if black == 0

local lbl_j = "earnings"
foreach j in inc  {
	graph drop _all
	forval d = 0 / 3 {
		local ylab ylabel(#4)
		if `d' == 0 {
			local dd Less than high school
			*local ylab ylabel( 20 "20k" 60 "60k"  100 "100k" 140 "140k"  180 "180k")
		}
		if `d' == 1 {
			local dd High school
			*local ylab ylabel( 20 "20k" 60 "60k"  100 "100k" 140 "140k"  180 "180k")
		}
		if `d' == 2 {
			local dd Some college
			*local ylab ylabel( 20 "20k" 60 "60k"  100 "100k" 140 "140k"  180 "180k")
		}
		if `d' == 3 {
			local dd College
			*local ylab ylabel( 20 "20k" 60 "60k"  100 "100k" 140 "140k"  180 "180k")
		}

		local x
		if "`j'" == "inc" {
			local t Annual earnings cond. on working

		}

		if "`j'" == "hours" {
			local t Hours worked per week cond. on working
			local ylab ylabel(#4)
		}

		if "`j'" == "E" {
			local t Employment
			local ylab ylabel(#4)
		}

		twoway (scatter `j'  age if black == 1 & deg == `d' , mcolor(black )  msymbol(D)  ) ///
			(scatter `j' age if black == 0 & deg == `d' , mcolor(gs10 )   msymbol(O)  ) ///
			(rcap  `j'_u `j'_d age if black == 1 & deg == `d' , lcolor(black )  ) ///
			(rcap `j'_u `j'_d age if black == 0 & deg == `d' , lcolor(gs10 ) ), ///
			name(fig`d') subtitle("`dd'", lcolor(black))  `ylab' ///
			legend(order(1 "Black" 2 "White" ) pos(6) rows(1)) xtitle("Quintile of cumulative hours worked") ytitle("") plotregion(fcolor(white)) graphregion(fcolor(white)) xlabel(1 2 3 4 5)




	}

	grc1leg  fig0 fig1 fig2 fig3, legendfrom(fig0)
	graph export "../figures/d_`lbl_`j''_byedu_byhours.png", replace
}




*Figure B5


*****

clear all
use id_afqt_rel
merge id using id_info

gen degree = educ

gen deg = 0 if degree < 12
replace deg = 1 if degree == 12
replace deg = 2 if degree > 12 & degree < 16
replace deg = 3 if degree >= 16 & degree < 50
drop if deg == .
keep if black != .
keep if decile != .
gen obs = 1
collapse (sum) obs [weight = cross1980], by(black decile deg)

bysort black deg: egen ach = sum(obs)
replace obs = obs/ach

forval d = 0 / 3 {
	if `d' == 0 {
		local t "Less than high school"
	}
	if `d' == 1 {
		local t "High school"
	}
	if `d' == 2 {
		local t "Some college"
	}
	if `d' == 3 {
		local t "College"
	}
	twoway (bar obs decile if black == 0 & deg == `d',  fcolor(cyan) lcolor(cyan)) ///
	(bar obs decile if black == 1 & deg == `d',  fcolor(none) lcolor(black)) ///
	  , subtitle(`t', color(black)) yscale(r(0 0.6)) ylabel(0(0.1)0.6) ///
	    xlabel(1 2 3 4 5 6 7 8 9 10) ///
	 legend(order(2 "Black" 1 "White") ) plotregion(fcolor(white)) graphregion(fcolor(white)) ///
	 xtitle("AFQT decile") ytitle("Share of population by race") name(fig`d')
}

grc1leg fig0 fig1 fig2 fig3, legendfrom(fig1)  plotregion(fcolor(white)) graphregion(fcolor(white))
graph export "../figures/d_afqt_distribution_byedu_abs.png", replace


*Figure B6

clear all
use id_afqt_rel
merge id using id_info

gen degree = educ

gen deg = 0 if degree < 12
replace deg = 1 if degree == 12
replace deg = 2 if degree > 12 & degree < 16
replace deg = 3 if degree >= 16 & degree < 50
drop if deg == .
keep if black != .
keep if decile != .
gen obs = 1
collapse (sum) obs [weight = cross1980], by(black decile deg)
keep if black != .
keep if decile != .
gen ei = 1
bysort decile deg: egen ach = sum(obs)
replace obs = obs/ach
replace obs = 1 if black == 0

forval d = 0 / 3 {
	if `d' == 0 {
		local t "Less than high school"
	}
	if `d' == 1 {
		local t "High school"
	}
	if `d' == 2 {
		local t "Some college"
	}
	if `d' == 3 {
		local t "College"
	}
	twoway (bar obs decile if black == 0 & deg == `d',  fcolor(cyan) lcolor(cyan)) ///
	 (bar obs decile if black == 1 & deg == `d',  fcolor(black) lcolor(black)) ///
	 ,subtitle(`t', color(black))  ///
	   xlabel(1 2 3 4 5 6 7 8 9 10) ///
	 legend(order(2 "Black" 1 "White") ) plotregion(fcolor(white)) graphregion(fcolor(white)) ///
	 xtitle("AFQT decile") ytitle("Share of population within decile") name(fig`d')
}
grc1leg fig0 fig1 fig2 fig3, legendfrom(fig1)  plotregion(fcolor(white)) graphregion(fcolor(white))
graph export "../figures/d_afqt_distribution_byedu_rel.png", replace





*Figure B7


******earnings per decile_black always work
clear
use super

keep if age >= 23 & age <= 54

drop if school == 1
bysort id: egen always_work = min(E)
drop if always_work == 0


drop _merge
merge m:1 id using  id_afqt_rel




keep if decile != .
keep if black != .

xtset id age

drop if school == 1
keep if age >= 23 & age <= 54

gen inch_sd = inch

replace decile = 5 if decile >= 5 & decile != .

gen age_cat = .
forval x = 1 / 4	{
	replace age_cat = `x' if age >= 23 + (`x' - 1) * 8  & age < 23 + `x' * 8
}

collapse inch (semean) inch_sd [weight = samp], by(age_cat black decile)



foreach j in inch {
	gen `j'_u = `j' + `j'_sd * 1.96
	gen `j'_d = `j' - `j'_sd * 1.96
}


replace age = age - 0.05 if black == 1
replace age = age + 0.05 if black == 0

graph drop _all

local these
local j inch
forval d = 1 / 5 {
	local dd " `d'"
	local l legend(off)
	if `d' == 5 {
		local dd "s 5-10"
	}
	if `d' == 10 {
		local l legend(order(1 "Black" 4 "White") pos(6) rows(1) )
	}
	twoway (scatter `j'  age if black == 1 & decile == `d' , mcolor(black ) msize(large) msymbol(D)  ) ///
			(scatter `j' age if black == 0 & decile == `d' , mcolor(gs10 )   msize(large) msymbol(O)  ) ///
			(rcap  `j'_u `j'_d age if black == 1 & decile == `d' , lcolor(black )  ) ///
			(rcap `j'_u `j'_d age if black == 0 & decile == `d' , lcolor(gs10 ) ), ///
		xlabel(1 "23-30" 2 "31-38" 3 "39-46" 4 "47-54")  ///
		ytitle("") name(fig`d') xtitle("Age") subtitle("AFQT decile`dd'") `l'

	local these `these' fig`d'

}



graph combine `these', xsize(10) ysize(4) rows(1)  ycommon
graph export "../figures/d_hearnings_byagroups_alwaysE.png", replace




*Figure B8


*******************


****individual FE

******earnings per decile_black
clear
use the_data

gen inch = inch_norm * $mean_inch
gen hours = hours_norm * 112

gen hours_sd = hours

keep if age >= 23 & age <= 54

merge 1:1 id year using  id_exp




replace cum_exp = cum_exp / 52


reghdfe inch cum_exp [weight = samp], absorb(id, savefe)

collapse __hdfe1__ samp (max) black decile, by(id)

save temp, replace

rename __hdfe1__ level

keep id level black decile

save id_level, replace

clear
use temp
erase temp.dta

replace decile = decile - 0.125 if black == 1
replace decile = decile + 0.125 if black == 0



rename __hdfe1__ bla

gen sd_bla = bla



collapse bla (semean) sd_bla [weight = samp], by(decile black)

sum bla

replace bla = bla - `r(min)'

gen bla_u = bla + 1.96 * sd_bla
gen bla_d = bla - 1.96 * sd_bla

twoway (scatter bla decile if black == 1, mcolor(black ) msize(*1) msymbol(D)) ///
	(rcap bla_u bla_d decile if black == 1, lcolor(black )) ///
	(scatter bla decile if black == 0,  mcolor(gs10 )   msize(*1) msymbol(O)) ///
	(rcap bla_u bla_d decile if black == 0, lcolor(gs10 )), ///
	legend(off) xlabel(1(1)10) xtitle("AFQT decile") subtitle("Mean individual fixed effect") name(level, replace)




clear
use the_data

gen inch = inch_norm * $mean_inch
gen hours = hours_norm * 112

gen hours_sd = hours

keep if age >= 23 & age <= 54

merge 1:1 id year using  id_exp




replace cum_exp = cum_exp / 52

sum id
local x = `r(min)'
local y = `r(max)'

gen bla = .
forval z = `x'/`y' {
	sum inch if id == `z'
	if `r(N)' > 5 {
		reg inch cum_exp if id == `z'
		replace bla = _b[cum_exp] if id == `z'
	}
}
collapse bla samp (max) decile black, by(id)

save temp, replace

keep id bla black decile
rename bla growth

save id_growth, replace

clear
use temp
erase temp.dta


replace decile = decile - 0.125 if black == 1
replace decile = decile + 0.125 if black == 0


gen sd_bla = bla



collapse bla (semean) sd_bla [weight = samp], by(decile black)

gen bla_u = bla + 1.96 * sd_bla
gen bla_d = bla - 1.96 * sd_bla

twoway (scatter bla decile if black == 1, mcolor(black ) msize(*1) msymbol(D)) ///
	(rcap bla_u bla_d decile if black == 1, lcolor(black )) ///
	(scatter bla decile if black == 0,  mcolor(gs10 )   msize(*1) msymbol(O)) ///
	(rcap bla_u bla_d decile if black == 0, lcolor(gs10 )), ///
	legend(off) xlabel(1(1)10) xtitle("AFQT decile") subtitle("Mean growth coefficient") name(growth, replace)

graph combine level growth, xsize(7)
graph export "../figures/d_hearnings_FE.png", replace


*Figure B9

graph drop _all
clear

use id_level
merge 1:1 id using id_growth



sum level

replace level = level - `r(min)'

local these
forval d = 0/10 {
	local these `these' (scatter  growth level if decile == `d', mcolor(gs`d'))
}
twoway `these'

twoway (scatter  growth level)



forval b = 0/1 {
	local these
	if `b' == 0 {
		local s White men
	}
	if `b' == 1 {
		local s Black men
	}
	forval d = 0/10 {
		local these `these' (scatter  growth level if decile == `d' & black == `b', mcolor(gs`d') msize(small) mfcolor(%30) )
	}
	twoway `these', legend(order(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" ) pos(6) rows(1)) name(fig`b', replace) xtitle("Individual fixed effect") ytitle("Individual growth effect") subtitle("`s'")
}

graph combine fig1 fig0 , xcommon ycommon
graph export "../figures/d_hearnings_FE_distribution.png", replace


*Figure B10, B11
*and files for calibration

local D 10
forval g = 0/3 {


	clear
	use the_data

	gen obs_inc = 1 if inch_norm != .
	gen obs_E = 1 if E != .



	if `g' >= 1 {


		if `g' == 2 {
			local these  inch_norm log_inch
		}

		if `g' == 3 {
			local these  inch_norm
		}

		if `g' == 1 {
			local these  hours_norm
		}


		foreach j in `these' {
			gen se_`j' = `j'
		}

	}
	if `g' == 0 {

		local these E
	}

	keep if age <= 54

	if `g' >= 2 {
		gen age_cat = 0 if age == 23
		forval x = 1 / 4	{
			replace age_cat = `x' if age >= 24 + (`x' - 1) * 8  & age < 24 + `x' * 8
		}
	}


	if `g' < 2 {
		gen age_cat = .
		forval x = 1 / 4	{
			replace age_cat = `x' if age >= 23 + (`x' - 1) * 8  & age < 23 + `x' * 8
		}

	}


	if `g' == 2 {
		local what  decile
		local H = `D'

	}
	if `g' < 2 {
		local what black decile
		local H 5
		replace decile = 5 if decile > 5
	}
	if `g' == 3 {
		local what black decile
		local H 10

	}

	if `g' >= 1 & `g' < 3 {
		keep if E == 1
		collapse `these' (semean) se_* [weight = samp], by(`what' age_cat)
		keep age_cat `what' `these' se_*
		if `g' == 2 {
			gen inch_d = inch_norm - 1.96 * se_inch_norm
			gen inch_u = inch_norm + 1.96 * se_inch_norm
			keep if age_cat == 0
			keep decile inch_norm inch_d inch_u

			foreach b in inch_norm inch_d inch_u {
				replace `b' = `b' * $mean_inch
			}

			twoway (scatter inch_norm decile, mcolor(black) msize(large) msymbol(dot) ) (rcap inch_u inch_d decile, lcolor(gray) ), ///
			legend(off)  xlabel(1(1)10) xtitle("AFQT decile") ytitle("Mean hourly wage at age 23") ///
			ylabel(0(10)20)

			graph export "../figures/d_hearnings0_bydeciles.png", replace


		}
	}


	if `g' == 3 {
		keep if E == 1
		collapse `these' (semean) se_* [weight = samp], by(`what' age_cat)
		keep age_cat `what' `these' se_*


		gen inch_d = inch_norm - 1.96 * se_inch_norm
		gen inch_u = inch_norm + 1.96 * se_inch_norm
		keep if age_cat == 0
		keep black decile inch_norm inch_d inch_u

		foreach b in inch_norm inch_d inch_u {
			replace `b' = `b' * $mean_inch
		}

		replace decile = decile - 0.1 if black == 1
		replace decile = decile + 0.1 if black == 0

		twoway (scatter inch_norm decile if black == 1, mcolor(black) msize(large) msymbol(dot) ) (scatter inch_norm decile if black == 0, mcolor(gray) msize(large) msymbol(diamond) ) (rcap inch_u inch_d decile if black == 1, lcolor(black) )  (rcap inch_u inch_d decile if black == 0, lcolor(gray) ), ///
		 xlabel(1(1)10) xtitle("AFQT decile") ytitle("Mean hourly wage at age 23") legend(order(1 "Black" 2 "White") pos(6) rows(1)) ///
		ylabel(0(5)30)

		graph export "../figures/d_hearnings0_bydeciles_byrace.png", replace



	}


	if `g' == 0 {

		collapse `these' (sum) obs_E  [weight = samp], by(`what' age_cat)
		gen se_E = (E*(1-E)/obs_E)^0.5
		keep age_cat `what' `these' se_*

	}
}






************











****TABLES







****parallel test


*******check for parallel of experience levels black vs white

clear all
use super

keep if age >= 23 & age <= 54

drop if samp == .


sort id year
drop _merge
merge 1:1 id year using id_exp

replace cum_exp = cum_exp / 52



mkspline agesp = age, cubic knots(20 30 40 50 )
reg inc_original  agesp*

replace hours = hours * 112 * 52



reg inch  agesp*



drop if samp == .

drop if cum_exp == .
drop if inch == .


local N = _N
foreach k in 10 20 30 {
	gen s = (cum_exp - `k') / 5
	gen K`k' = 0
	replace K`k' = (15/16)*(s^2 - 1)^2 if abs(s) < 1
	drop s
}

local N = _N
foreach k in 10 20 30  {
	local Kj2 = 0
	local Kj = 0
	forval j = 1 / `N' {
		local Kj2 = `Kj2' + K`k'[`j']^2
		local Kj = `Kj' + K`k'[`j']
	}


	gen W`k' = (K`k' * `Kj2' - K`k' * `Kj') /  (`Kj' * `Kj2' -  `Kj'^2)
}

local N = _N
foreach k in 10 20 30  {
	local m`k' = 0
	forval j = 1 / `N' {
		local m`k' = `m`k'' + inch[`j'] * W`k'[`j']
	}
	display `m`k''
}
/*
*21.900533
*30.340805
*37.276851
*/


*by RACE

foreach k in 10 20 30 {
	drop K`k' // NOTE: Added
	gen s = (cum_exp - `k') / 5
	gen K`k' = 0
	replace K`k' = (15/16)*(s^2 - 1)^2 if abs(s) < 1
	drop s
}

foreach p in inch inc_original {

	forval b = 0 / 1 {
		npregress kernel `p' cum_exp  if black == `b', kernel(biweight) meanbwidth(5, copy)

		predict y`b'
	}

	gen `p'_yhat = .
	forval b = 0 / 1 {
		replace `p'_yhat = y`b' if black == `b'
		drop y`b'
	}


	cap drop W* eps*

	local N = _N

	foreach k in 10 20 30  {
		// NOTE added confirmation
		capture confirm variable W`k'
		if !_rc {
			drop W`k'
		}
		gen W`k' = .
		gen epsW`k' = .
		gen eps`k' = .
	}

	forval b = 0 / 1 {
		foreach k in 10 20 30 {
			local Kj2 = 0
			local Kj = 0
			forval j = 1 / `N' {
				local Kj2 = `Kj2' +  ///
				`b' * K`k'[`j']^2 * black[`j'] + ///
				(1 - `b')  * K`k'[`j']^2 * (1 - black[`j'])

				local Kj = `Kj' + ///
				`b' * K`k'[`j'] * black[`j'] + ///
				(1 - `b') * K`k'[`j'] * (1 - black[`j'])
			}


			replace W`k' = (K`k' * `Kj2' - K`k' * `Kj') /  (`Kj' * `Kj2' -  `Kj'^2) if black == `b'
		}
	}

	forval b = 0 / 1 {
		foreach k in 10 20 30  {
			local m`k'`b' = 0
			forval j = 1 / `N' {

				local m`k'`b' = `m`k'`b'' ///
				+ `b' * `p'[`j'] * W`k'[`j'] * black[`j'] ///
				+ (1 - `b') * `p'[`j'] * W`k'[`j'] * (1 - black[`j'])

			}
			display `m`k'`b''
		}
	}



	forval b = 0 / 1 {
		foreach k in 10 20 30  {

			replace eps`k' = (`p' - `p'_yhat)  if black == `b' & W`k'^2 > 0
			replace epsW`k' = (`p' - `p'_yhat)^2 * W`k'^2 if black == `b'

		}
	}

	foreach k in 20 30 {

		local x = `k' - 10
		forval b = 0 / 1 {
			foreach c in `k' `x' {
				local V`c'_`b' = 0
				forval j = 1 / `N' {
					local V`c'_`b' = `V`c'_`b'' + ///
					`b' * epsW`c'[`j'] * black[`j'] + ///
					(1 - `b') * epsW`c'[`j'] * (1 - black[`j'])
				}
				display `V`c'_`b''
			}
		}
		local what = ((`m`k'0' - `m`k'1') - (`m`x'0' - `m`x'1')) * ///
			(`V`k'_1' + `V`x'_1' + `V`k'_0' + `V`x'_0')^(-1) * ///
			((`m`k'0' - `m`k'1') - (`m`x'0' - `m`x'1'))

		display "parts"
		display ((`m`k'0' - `m`k'1') - (`m`x'0' - `m`x'1'))
		display (`V`k'_1' + `V`x'_1' + `V`k'_0' + `V`x'_0')^(-1)

		display "final"
		display `what'
	}
}





/*
stop





23.375553
33.476482
40.446863
18.179317
23.235134
27.552952
(18,939 real changes made)
(36,523 real changes made)
(7,758 real changes made)
(36,523 real changes made)
(5,268 real changes made)
(36,523 real changes made)
(7,644 real changes made)
(15,182 real changes made)
(3,408 real changes made)
(15,182 real changes made)
(1,744 real changes made)
(15,182 real changes made)
.13698875
.01315261
.16004855
.0225861
parts
5.0451123
3.0050243
final
76.487358
.36077418
.13698875
.38549308
.16004855
parts
2.6525627
.95849289
final
6.7440414

Computing mean function

Computing optimal derivative bandwidth

Iteration 0:   Cross-validation criterion =  199814.86
Iteration 1:   Cross-validation criterion =  176648.51
Iteration 2:   Cross-validation criterion =  174398.85
Iteration 3:   Cross-validation criterion =  174398.85
Iteration 4:   Cross-validation criterion =  174309.71
Iteration 5:   Cross-validation criterion =  174309.71
Iteration 6:   Cross-validation criterion =  174309.71

Bandwidth
------------------------------------
             |      Mean     Effect
-------------+----------------------
     cum_exp |         5   11.16411
------------------------------------

Local-linear regression                    Number of obs      =         36,523
Kernel   : biweight                        E(Kernel obs)      =         36,523
Bandwidth: cross-validation                R-squared          =         0.1407
------------------------------------------------------------------------------
inc_original |   Estimate
-------------+----------------------------------------------------------------
Mean         |
inc_original |   62630.29
-------------+----------------------------------------------------------------
Effect       |
     cum_exp |   2648.958
------------------------------------------------------------------------------
Note: Effect estimates are averages of derivatives.
Note: You may compute standard errors using vce(bootstrap) or reps().
Warning: Convergence not achieved.
(option mean assumed; mean function)
(15,182 missing values generated)

Computing mean function

Computing optimal derivative bandwidth

Iteration 0:   Cross-validation criterion =  540413.09
Iteration 1:   Cross-validation criterion =  481364.75
Iteration 2:   Cross-validation criterion =  446966.13
Iteration 3:   Cross-validation criterion =  444216.88
Iteration 4:   Cross-validation criterion =  444216.88
Iteration 5:   Cross-validation criterion =  444170.03
Iteration 6:   Cross-validation criterion =   444141.2
Iteration 7:   Cross-validation criterion =   444141.2

Bandwidth
------------------------------------
             |      Mean     Effect
-------------+----------------------
     cum_exp |         5   11.21382
------------------------------------

Local-linear regression                    Number of obs      =         15,182
Kernel   : biweight                        E(Kernel obs)      =         15,182
Bandwidth: cross-validation                R-squared          =         0.1184
------------------------------------------------------------------------------
inc_original |   Estimate
-------------+----------------------------------------------------------------
Mean         |
inc_original |   43033.17
-------------+----------------------------------------------------------------
Effect       |
     cum_exp |    1718.47
------------------------------------------------------------------------------
Note: Effect estimates are averages of derivatives.
Note: You may compute standard errors using vce(bootstrap) or reps().
Warning: Convergence not achieved.
(option mean assumed; mean function)
(36,523 missing values generated)
(51,705 missing values generated)
(36,523 real changes made)
(15,182 real changes made)
(51,705 missing values generated)
(51,705 missing values generated)
(51,705 missing values generated)
(51,705 missing values generated)
(51,705 missing values generated)
(51,705 missing values generated)
(51,705 missing values generated)
(51,705 missing values generated)
(51,705 missing values generated)
(36,523 real changes made)
(36,523 real changes made)
(36,523 real changes made)
(15,182 real changes made)
(15,182 real changes made)
(15,182 real changes made)
53562.238
80592.921
96446.107
39679.722
53584.504
64759.885
(18,939 real changes made)
(36,523 real changes made)
(7,758 real changes made)
(36,523 real changes made)
(5,268 real changes made)
(36,523 real changes made)
(7,644 real changes made)
(15,182 real changes made)
(3,408 real changes made)
(15,182 real changes made)
(1,744 real changes made)
(15,182 real changes made)
844337.48
79247.024
920749.92
114046.34
parts
13125.901
5.106e-07
final
87.97537
2048091.9
844337.48
2344452.2
920749.92
parts
4677.8056
1.624e-07
final
3.5536173
*/




**Table 2, B1


******descriptive regressions

clear all
use super

xtset id age


forval v = 0 / 5 {
	replace region = F1.region if region == .
}


bysort id: egen max_ed = max(degree)
drop degree
rename max_ed degree
gen deg = 0 if degree < 12
replace deg = 1 if degree == 12
replace deg = 2 if degree > 12 & degree < 16
replace deg = 3 if degree >= 16 & degree < 50

keep id year black region *inc* deg samp

merge 1:1 id year using  id_exp



cap drop decile
drop _merge
merge m:1 id using  id_afqt_rel





replace cum_exp = cum_exp / 52


gen cum_exp2 = cum_exp/10 * cum_exp/10

label var cum_exp "Work experience (years)"
label var cum_exp2 "Work experience squared (years/10)"
label var black "Black dummy"

gen decile_black = decile * black
gen cum_exp_black = cum_exp * black
gen cum_exp2_black = cum_exp2 * black

label var cum_exp_black "Work experience x Black"

confirmdir "../tables"
if `r(confirmdir)' mkdir "../tables"

gen log_inch = log(inch)
local lbl_inch = "hearnings"
estimates drop _all
foreach j in inch   {
	local x = 1
	forval d = 1 / 10 {



		reg `j' black   cum_exp  cum_exp_black  i.region if decile == `d' [weight = samp], r



		su `j' [weight = samp] if e(sample)
		estadd scalar ymean =`r(mean)'

		su black [weight = samp] if e(sample)
		estadd scalar blackmen =`r(mean)'

		eststo reg`d'

		if `d' == 5 | `d' == 10 {
			esttab  * using ///
						"../tables/reg_`lbl_`j''_`x'.tex" ,  keep(black   cum_exp  cum_exp_black _cons ) ///
							noobs fragment nomtitles nonumbers  nowrap booktabs  nogaps  nolines eqlabels("") style(tex) wide label  replace   stats(ymean blackmen N r2, labels("\addlinespace Mean" "Share Black"  "Observations" "R-squared") fmt(2 3 0 2 0 0)) starlevels(* 0.10 ** 0.05 *** 0.01) collabels(none)  cells(b(star fmt(%9.4f)) se(par))  substitute("\_ _")

			local x = `x' + 1

			estimates drop _all
		}



	}


}






****number in intro
clear all
use super


drop if school == 1
sum inc_original [weight = samp] if black == 0 & age == 25
local y = `r(mean)'
sum inc_original [weight = samp] if black == 1 & age == 25
local x = `r(mean)'

display `x' - `y'
display `x'/`y' - 1

sum inc_original [weight = samp] if black == 0 & age == 45
local y = `r(mean)'
sum inc_original [weight = samp] if black == 1 & age == 45
local x = `r(mean)'

display `x' - `y'
display `x'/`y' - 1


sum E [weight = samp] if black == 0 & age == 25
local y = `r(mean)'
sum E [weight = samp] if black == 1 & age == 25
local x = `r(mean)'

display `x' - `y'
display `x'/`y' - 1

sum E [weight = samp] if black == 0 & age == 45
local y = `r(mean)'
sum E [weight = samp] if black == 1 & age == 45
local x = `r(mean)'

display `x' - `y'
display `x'/`y' - 1

replace hours = hours / 52
sum hours [weight = samp] if black == 0 & age == 25
local y = `r(mean)'
sum hours [weight = samp] if black == 1 & age == 25
local x = `r(mean)'

display `x' - `y'
display `x'/`y' - 1

sum hours [weight = samp] if black == 0 & age == 45
local y = `r(mean)'
sum hours [weight = samp] if black == 1 & age == 45
local x = `r(mean)'

display `x' - `y'
display `x'/`y' - 1

// Delete auxiliary files
rm "able_distrib_within.dta"
rm "always_work_data.dta"
rm "always_work_hour_data.dta"
rm "cpi_annual_fred.dta"
rm "id_afqt_rel.dta"
rm "id_emp_year.dta"
rm "id_emp.dta"
rm "id_exp.dta"
rm "id_growth.dta"
rm "id_info.dta"
rm "id_level.dta"
rm "id_year.dta"
rm "super.dta"
rm "the_data.dta"
