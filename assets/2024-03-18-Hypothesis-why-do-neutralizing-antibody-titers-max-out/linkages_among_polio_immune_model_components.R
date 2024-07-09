# scratch script for 2024-03-18-Hypothesis-why-do-neutralizing-antibody-titers-max-out.md

library(tidyverse)

# polio dose response model
alpha=0.44
beta=2.3
gamma=0.46

rbar = function(NAb=1,b=beta,a=alpha,g=gamma){
  1/(1+b/a*NAb^g)
}

p = function(NAb=1,dose=1,a=alpha,b=beta,g=gamma){
  1-(1+dose/b)^(-(a/NAb^g))
}

dens = function(x,NAb=1){
  dbeta(x,shape1=alpha/(NAb^gamma),shape2=beta)
}

rand = function(dose,NAb=1){
  rbeta(dose,shape1=alpha/(NAb^gamma),shape2=beta)
}

900*rbar(NAb=2^14 )

900*rbar(NAb=2^14,b=14 )
900*rbar(NAb=2^14,b=8 )
900*rbar(NAb=2^14,b=18 )


plot(seq(0,14),1/rbar(NAb=2^(0:14)))

plot(0:14,p(dose=1000,NAb=2^(0:14)))



x=seq(0,1,by=1e-4)
plot(x,dens(x,NAb=2^14))


p(NAb=2^14,dose=1e6)


# median from the shedding duration model
log(30.3)-log(1.16)*log2(2^14)



## LOL did I misremember 2^14 for the polio model?!

temp_file <- tempfile(fileext = ".xlsx")
download.file(url = 'https://github.com/famulare/cessationStability/raw/master/data/Louisiana1957/householdSeroconversion.xlsx', destfile = temp_file, mode = "wb", quiet = TRUE)

df=readxl::read_xlsx(temp_file,sheet='prePostAntibodyLineList')[,1:2] |>
  mutate(seroconverted = (postExposureTiter/preExposureTiter)>=4)
df

ggplot(df)+
  geom_jitter(aes(x=preExposureTiter,y=postExposureTiter/preExposureTiter,color=seroconverted)) +
  scale_x_continuous(trans='log2',breaks=2^(3*(0:5)))+
  scale_y_continuous(trans='log2',breaks=2^(3*(0:5)))

responseModelLik = function(params=c(4.8,3.3,-0.31/4.4,-0.09,0.36),data=df){
  Msamp=params[4]
  Ssamp=params[5]
  
  logL=0
  
  for(k in 1:nrow(data)){

    x=log2(data$postExposureTiter[k])-log2(data$preExposureTiter[k])
    
    if(df$seroconverted[k]==TRUE){
      
      Msc=params[1]*(1+params[3]*log2(data$preExposureTiter[k])) + Msamp
      Ssc=sqrt( (params[2]*(1+params[3]*log2(data$preExposureTiter[k])))^2 + Ssamp)
      
      # df$logL[k]=dnorm(x=x,mean=Msc,sd=Ssc,log=TRUE)
      
      logL = logL + dnorm(x=x,mean=Msc,sd=Ssc,log=TRUE)
      
    } else {
      logL = logL + dnorm(x=x,mean=Msamp,sd=Ssamp,log=TRUE)
      
      # df$logL[k]=dnorm(x=x,mean=Msamp,sd=Ssamp,log=TRUE)

    }
    
  }
  return(logL)
  # return(df)
}


res=stats4::mle(function(x=c(4.8,3.3,-0.31/4.4,-0.09,0.36)){responseModelLik(params=x,data=df)},
          method='L-BFGS-B',
          lower=c(0,0,-1/12.34,-Inf,0.01),
          upper=c(Inf,Inf,0,Inf,Inf),
          control=list(fnscale=-1,trace=0))

res
-1/res@coef[3]
# profile likelihood
# res_ci=stats4::confint(res)

-res@coef[1]*res@coef[3]
gamma


C=2^(res@coef[1])/900*beta/alpha
C

1/C


# index of dispersion, not unlike Poisson process...
res@coef[2]^2/res@coef[1]




# matthew reference 
# table 5 https://www.ijidonline.com/action/showFullTableHTML?isHtml=true&tableId=tbl0025&pii=S1201-9712%2813%2900297-X 
# mean of max titers = 13.5
mean(c(11.1,11.2,15.3,12.9,15.5,15.2))


pred=data.frame(preExposureTiter=2^seq(0,-1/res@coef[3],by=0.01)) |>
  mutate(median=2^(res@coef[1]*(1+res@coef[3]*log2(preExposureTiter)))) |>
  mutate(lower=2^(res@coef[1]*(1+res@coef[3]*log2(preExposureTiter))-(res@coef[2]*(1+res@coef[3]*log2(preExposureTiter))))) |>
  mutate(upper=2^(res@coef[1]*(1+res@coef[3]*log2(preExposureTiter))+(res@coef[2]*(1+res@coef[3]*log2(preExposureTiter))))) |>
  mutate(lower2=2^(res@coef[1]*(1+res@coef[3]*log2(preExposureTiter))-2*(res@coef[2]*(1+res@coef[3]*log2(preExposureTiter))))) |>
  mutate(upper2=2^(res@coef[1]*(1+res@coef[3]*log2(preExposureTiter))+2*(res@coef[2]*(1+res@coef[3]*log2(preExposureTiter)))))

ggplot(df)+
  geom_jitter(aes(x=log2(preExposureTiter),y=postExposureTiter/preExposureTiter,color=seroconverted)) +
  geom_line(data=pred,aes(x=log2(preExposureTiter),y=median)) +
  geom_line(data=pred,aes(x=log2(preExposureTiter),y=median)) +
  geom_ribbon(data=pred,aes(x=log2(preExposureTiter),ymin=lower,ymax=upper),alpha=0.1)+
  geom_ribbon(data=pred,aes(x=log2(preExposureTiter),ymin=lower2,ymax=upper2),alpha=0.1)+
  scale_x_continuous(breaks=(3*(0:5)))+
  scale_y_continuous(trans='log2',breaks=2^(2*(0:8))) 


## comparing the mu_0 for the different polio serotypes
res@coef[1] #WPV
log2(C*900*alpha/beta)

# this was sitting there the whole time in Matthew's paper!
# had he pooled inferences across serotypes
# and used a simpler one parameter model for the y-intercept
# he'd've found the same thing!
#Sabin 1
log2(C*900*alpha/14)
(5.73*2686+5.03*5077)/(2686+5077) # behrend raw pooled
(5.73*2686+5.03*5077)/(2686+5077)*log2(11.1)/log2(-1/res@coef[3]) #behrend max-titer adjusted

# Sabin 2
log2(C*900*alpha/8)
(6.64*2395+6.26*3739)/(2395+3739) # behrend raw pooled
(6.64*2395+6.26*3739)/(2395+3739)*log2(11.2)/log2(-1/res@coef[3]) #behrend max-titer adjusted

# Sabin 3
log2(C*900*alpha/18)
(5.49*2395+3.09*3738)/(2395+3738) # behrend raw pooled
(5.49*2395+3.09*3738)/(2395+3738)*log2(15.3)/log2(-1/res@coef[3]) #behrend max-titer adjusted

# is gamma or max titer constant?

# constant gamma
# I know these are too low for OPV
log2(C*900*alpha/14)/gamma
log2(C*900*alpha/8)/gamma
log2(C*900*alpha/18)/gamma

# okay, so then constant max titer
# this is also the point of the smith 1984 paper
g1=log2(C*900*alpha/14)*-res@coef[3]
g2=log2(C*900*alpha/8)*-res@coef[3]
g3=log2(C*900*alpha/18)*-res@coef[3]
gamma 

plot(0:14,p(dose=1000,NAb=2^(0:14)))
lines(0:14,p(dose=1000,NAb=2^(0:14),g=g1))
lines(0:14,p(dose=1000,NAb=2^(0:14),g=g2))
lines(0:14,p(dose=1000,NAb=2^(0:14),g=g3))

plot(0:14,p(dose=1e5,NAb=2^(0:14)))
lines(0:14,p(dose=1e5,NAb=2^(0:14),g=g1))
lines(0:14,p(dose=1e5,NAb=2^(0:14),g=g2))
lines(0:14,p(dose=1e5,NAb=2^(0:14),g=g3))




900*rbar(NAb=2^15.3,b=beta,g=gamma)

900*rbar(NAb=2^15.3,b=14,g=gamma)
900*rbar(NAb=2^15.3,b=14,g=g1)

900*rbar(NAb=2^15.3,b=8,g=gamma)
900*rbar(NAb=2^15.3,b=8,g=g2)

900*rbar(NAb=2^15.3,b=18,g=gamma)
900*rbar(NAb=2^15.3,b=18,g=g3)



## venom
delta_mu = 1/3*log(8.4e6/15e3)
delta_mu


# rhinovirus asymptomatic vs symptimatic transmission
# https://www.medrxiv.org/content/10.1101/2024.02.13.24302773v1.full-text


# model selection on who gets in
# 10% of people testing are positive
# people with sick contacts + people with symptoms
# guess 2/3 are testing because of contacts, so roughly 50-50 symp vs asymp
0.5*p(dose=0.01)/p(dose=0.01*2^3)
0.5*p(dose=1)/p(dose=1*2^3)
# minimum of rhino asymp transmission is 5% to 15%, before behavior difference. 

# pre-vax covid was similar ct ratio (3)
# https://jamanetwork.com/journals/jamapediatrics/fullarticle/2780963
# that of course lead to 50% of total transmission, indicating behavior was a 5x effect for covid 
# (which makes sense given severity and isolation guidelines!)

# add in immunity (not much difference if matched)
0.5*p(dose=0.01,NAb=100)/p(dose=0.01*2^3,NAb=100)
0.5*p(dose=1,NAb=100)/p(dose=1*2^3,NAb=100)

# could go up to 50% with immunity
0.5*p(dose=0.01,NAb=1)/p(dose=0.01*2^3,NAb=100)
0.5*p(dose=1,NAb=1)/p(dose=1*2^3,NAb=100)




