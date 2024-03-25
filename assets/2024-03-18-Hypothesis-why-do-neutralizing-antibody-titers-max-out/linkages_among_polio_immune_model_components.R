# scratch script for 2024-03-18-Hypothesis-why-do-neutralizing-antibody-titers-max-out.md

library(tidyverse)

# polio dose response model
alpha=0.44
beta=2.3
gamma=0.46

rbar = function(NAb=1){
  1/(1+beta/alpha*NAb^gamma)
}

p = function(NAb=1,dose=1){
  1-(1+dose/beta)^(-(alpha/NAb^gamma))
}

dens = function(x,NAb=1){
  dbeta(x,shape1=alpha/(NAb^gamma),shape2=beta)
}

rand = function(dose,NAb=1){
  rbeta(dose,shape1=alpha/(NAb^gamma),shape2=beta)
}

1*rbar(NAb=2^14 )

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


## venom
delta_mu = 1/3*log(8.4e6/15e3)
delta_mu
