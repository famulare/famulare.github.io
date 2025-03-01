# RDT_brightness_timeseries.R
# studying my nasal viral load

library(tidyverse)

d = read.csv('RDT_brightness_timeseries.csv')
names(d)

# drop low quality probably negative binax now sample
d = d |> filter(brand != 'BinaxNow')

d = d |> 
  group_by(days_since_symptom_onset, sample,subject) |>
  mutate(intensity_relative_to_background = (100-percent_lightness)/(100-percent_lightness[assay=='background'])-1) |>
  ungroup() |> 
  mutate(assay = factor(assay,levels=c('covid','background','control'))) |>
  mutate(sample = factor(sample, levels=c('nose_throat','mask_center','mask_top_left_of_nose'))) |>
  mutate(days_since_symptom_onset_label=paste0('day ',days_since_symptom_onset,sep='')) |>
  mutate(subject=factor(subject,levels=c('Mike','Marisa')))



ggplot(d |> filter(sample == 'nose_throat')) +
  geom_line(aes(x=days_since_symptom_onset,y=100-percent_lightness, group=assay, color=assay)) +
  geom_point(aes(x=days_since_symptom_onset,y=100-percent_lightness, group=assay, color=assay)) +
  geom_vline(data=filter(d,subject=='Mike'),aes(xintercept=3),linetype='dotted') +
  geom_text(
    data = data.frame(subject = factor("Mike",levels=c('Mike','Marisa')), x = 3.1, y = 10, label = "started\npaxlovid"),
    aes(x = x, y = y, label = label),
    hjust = 0,
    inherit.aes = FALSE
  ) +
  facet_wrap('subject') +
  scale_x_continuous(breaks=seq(1,14,by=2)) +
  theme_bw() +
  ylab('100 - brightness (%)') +
  xlab('days since symptom onset') +
  scale_y_continuous(limits=c(0,100))
ggsave('absolute_darkness.png',units='in',width=6,height=3)


ggplot(d |> filter(assay !='background' & sample == 'nose_throat')) +
  geom_line(aes(x=days_since_symptom_onset,y=intensity_relative_to_background, group=assay, color=assay)) +
  geom_point(aes(x=days_since_symptom_onset,y=intensity_relative_to_background, group=assay, color=assay)) +
  facet_wrap('subject') +
  theme_bw() +
  scale_y_continuous(trans='log10',breaks=c(0.03,0.06,0.1,0.3,0.6,1.0,3.0),
                     minor_breaks = c(seq(0.01,0.09,by=0.01),seq(0.1,0.9,by=0.1),2))  +
  ylab('darkness relative to background') +
  xlab('days since symptom onset') +
  scale_x_continuous(breaks=seq(1,14,by=2)) +
  geom_vline(data=filter(d,subject=='Mike'),aes(xintercept=3),linetype='dotted') +
  geom_text(
    data = data.frame(subject = factor("Mike",levels=c('Mike','Marisa')), x = 3.1, y = 0.1, label = "started\npaxlovid"),
    aes(x = x, y = y, label = label),
    hjust = 0,
    inherit.aes = FALSE
  ) 
ggsave('relative_darkness.png',units='in',width=6,height=3)


d = d |> filter(assay !='background') |>
  group_by(days_since_symptom_onset, sample,subject) |>
  mutate(intensity_relative_to_control = intensity_relative_to_background/intensity_relative_to_background[assay=='control']) |>
  ungroup()

ggplot(d |> filter(assay != 'control'  & sample == 'nose_throat')) +
  geom_line(aes(x=days_since_symptom_onset,y=intensity_relative_to_control, group=assay, color=assay)) +
  geom_point(aes(x=days_since_symptom_onset,y=intensity_relative_to_control, group=assay, color=assay)) +
  theme_bw() +
  scale_y_continuous(trans='log10',breaks=c(0.02,0.04,0.06,0.08,0.1,0.2,0.4,0.6,0.8,1.0,2),
                     minor_breaks = c(seq(0.01,0.09,by=0.01),seq(0.1,0.9,by=0.1),seq(2,9,by=1)),
                     limits=c(0.1,2.0)) +
  ylab('background-adjusted darkness\nrelative to control') +
  xlab('days since symptom onset') +
  facet_wrap('subject') +
  scale_x_continuous(breaks=seq(1,14,by=2)) +
  geom_vline(data=filter(d,subject=='Mike'),aes(xintercept=3),linetype='dotted') +
  geom_text(
    data = data.frame(subject = factor("Mike",levels=c('Mike','Marisa')), x = 3.1, y = 0.15, label = "started\npaxlovid"),
    aes(x = x, y = y, label = label),
    hjust = 0,
    inherit.aes = FALSE
  ) 
ggsave('background-adjusted-darkness-relative-to-control.png',units='in',width=6,height=3)


d = d |> filter(assay !='control') |>
  mutate(intensity_relative_to_peak = intensity_relative_to_control/intensity_relative_to_control[days_since_symptom_onset==2 & sample=='nose_throat' & subject=='Mike'])

ggplot(d |> filter(assay != 'control'& sample == 'nose_throat')) +
  geom_line(aes(x=days_since_symptom_onset,y=intensity_relative_to_peak, group=subject, color=subject)) +
  geom_point(aes(x=days_since_symptom_onset,y=intensity_relative_to_peak, group=subject, color=subject)) +
  theme_bw() +
  scale_x_continuous(breaks=seq(1,14,by=2)) +
  scale_y_continuous(trans='log10',breaks=c(0.02,0.04,0.06,0.08,0.1,0.2,0.4,0.6,0.8,1.0,2),
                     minor_breaks = c(seq(0.01,0.09,by=0.01),seq(0.1,0.9,by=0.1),seq(2,9,by=1)),
                     limits=c(0.05,1.0))+
  ylab('adjusted darkness relative to peak') +
  xlab('days since symptom onset') 
  # geom_vline(aes(xintercept=3),linetype='dotted') +
  # annotate('text',x=3.1,y=0.08,label='started\npaxlovid',hjust=0)
ggsave('log10-darkness-relative-to-peak.png',units='in',width=5,height=3)


# model viral load
# intensity is proportional to viral load?

#https://pmc.ncbi.nlm.nih.gov/articles/PMC11237673/pdf/spectrum.00073-24.pdf
# log10(intensity) = 3.85 - 0.126*CT

# https://doi.org/10.1038/s41598-021-02128-y
d2 = read.csv('RDT-intensity-vs-ct.csv')
names(d2)

ggplot(d2) +
  geom_point(aes(x=ct,y=intensity.10.5.))

summary(mod<-lm(log10(intensity.10.5.)~ct, data=d2 ))
# log10(intensity) ~ 2.16 - 0.098*CT

d2$predict=10^predict(mod,newdata=d2)
ggplot(d2) +
  geom_point(aes(x=ct,y=intensity.10.5.)) +
  geom_line(aes(x=ct,y=predict))


d3 = read.csv('RDT-intensity-vs-ct-benchmark.csv')
names(d3)

ggplot(d3) +
  geom_point(aes(x=copies,y=intensity))

d3=d3 |> mutate(ct = - log2(copies))

summary(mod<-lm(log10(intensity)~ct, data=d3 ))
# log10(intensity) ~ - 0.21*CT

d3$predict=10^predict(mod,newdata=d3)
ggplot(d3) +
  geom_point(aes(x=ct,y=intensity)) +
  geom_line(aes(x=ct,y=predict))



summary(mod<-lm(log10(intensity)~log10(copies), data=d3 ))
# intensity ~ copies*0.7

d3$predict=10^predict(mod,newdata=d3)
ggplot(d3) +
  geom_point(aes(x=copies,y=intensity)) +
  geom_line(aes(x=copies,y=predict))


summary(mod<-lm((intensity)~(copies), data=d3 ))

# I'm willing to believe intensity is linear with copies at low copy number
summary(mod<-lm((intensity)~(copies), data=d3 |> filter(copies<1)))

d3$predict=predict(mod,newdata=d3)
ggplot(d3) +
  geom_point(aes(x=copies,y=intensity)) +
  geom_line(aes(x=copies,y=predict))

# ct ~ - log10(Genomes)/log10(2) = - 3.32*log10(genomes)

# log10(intensity) ~ (0.1 to 0.13)/log10(2) * log10(genomes)

# intensity ~ genomes*(0.33 ~ 0.43 ~ 0.7)

# genomes ~ intensity^(1.4 ~ 2.3 ~ 3)

# so anyway, the intensity isn't linear with copies across the whole range,
# presumably because diffusion and absorption rates depend strongly on concentration
# but, as a gist, genomes ~ intensity^2.3 seems like a good middle ground



d = d |>
  mutate(estimated_genomes_relative_to_peak_mid = intensity_relative_to_peak^2.3) |>
  mutate(estimated_genomes_relative_to_peak_high = intensity_relative_to_peak^1.4) |>
  mutate(estimated_genomes_relative_to_peak_low = intensity_relative_to_peak^3) 

ggplot(d |> filter(sample == 'nose_throat') ) +
  geom_line(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_mid,group=subject, color=subject)) +
  geom_point(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_mid,group=subject, color=subject)) +
  geom_line(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_low,group=subject, color=subject),linetype='dashed') +
  geom_point(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_low,group=subject, color=subject)) +
  geom_line(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_high,group=subject, color=subject),linetype='dashed') +
  geom_point(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_high,group=subject, color=subject)) +
  theme_bw() +
  scale_x_continuous(breaks=seq(1,14,by=2)) +
  scale_y_continuous(trans='log10',breaks=c(0.0001,0.0003,0.001,0.003,0.01,0.03,0.1,0.3,1),
                     minor_breaks = c(seq(0.0001,0.0009,by=0.0001),seq(0.001,0.009,by=0.001),seq(0.01,0.09,by=0.01),seq(0.1,0.9,by=0.1),seq(2,9,by=1)),
                     limits=c(0.0001,1.0))+
  ylab('viral load (estimated genome copies)\nrelative to peak') +
  xlab('days since symptom onset') #+
  # geom_vline(aes(xintercept=3),linetype='dotted') +
  # annotate('text',x=3.1,y=0.0008,label='started\npaxlovid',hjust=0)
ggsave('viral-load-relative-to-peak.png',units='in',width=5,height=3)

ggplot(d |> filter(sample == 'nose_throat') ) +
  geom_line(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_mid,group=subject, color=subject)) +
  geom_point(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_mid,group=subject, color=subject)) +
  geom_line(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_low,group=subject, color=subject),linetype='dashed') +
  geom_point(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_low,group=subject, color=subject)) +
  geom_line(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_high,group=subject, color=subject),linetype='dashed') +
  geom_point(aes(x=days_since_symptom_onset,y=estimated_genomes_relative_to_peak_high,group=subject, color=subject)) +
  theme_bw() +
  scale_x_continuous(breaks=seq(1,14,by=2)) +
  scale_y_continuous(breaks=seq(0,1,by=0.2),
                     minor_breaks = seq(0,1,by=0.05),
                     limits=c(0,1.0))+
  ylab('viral load (estimated genome copies)\nrelative to peak') +
  xlab('days since symptom onset')
ggsave('viral-load-relative-to-peak_linear_y.png',units='in',width=5,height=3)

ggplot(d |> filter(sample == 'nose_throat') ) +
  geom_line(aes(x=days_since_first_hh_positive,y=estimated_genomes_relative_to_peak_mid,group=subject, color=subject)) +
  geom_point(aes(x=days_since_first_hh_positive,y=estimated_genomes_relative_to_peak_mid,group=subject, color=subject)) +
  geom_line(aes(x=days_since_first_hh_positive,y=estimated_genomes_relative_to_peak_low,group=subject, color=subject),linetype='dashed') +
  geom_point(aes(x=days_since_first_hh_positive,y=estimated_genomes_relative_to_peak_low,group=subject, color=subject)) +
  geom_line(aes(x=days_since_first_hh_positive,y=estimated_genomes_relative_to_peak_high,group=subject, color=subject),linetype='dashed') +
  geom_point(aes(x=days_since_first_hh_positive,y=estimated_genomes_relative_to_peak_high,group=subject, color=subject)) +
  theme_bw() +
  scale_y_continuous(breaks=seq(0,1,by=0.2),
                     minor_breaks = seq(0,1,by=0.05),
                     limits=c(0,1.0))+
  scale_x_continuous(limits=c(-5.5,NaN),breaks=seq(-5,20,by=2),minor_breaks=seq(-5,20,by=1)) +
  geom_vline(xintercept = 0,size=0.5,color='gray') +
  geom_segment(x=-5.5, xend = -2,y=0,size=1) +
  annotate('text',x=-3.75,y=0.15,label='Mike\'s\nexposure\nwindow') +
  geom_segment(x=0.5, xend = 1.5,y=0,size=1,color='darkgray') +
  annotate('text',x=1.,y=0.15,label='Marisa\nprobably\ninfected',color='darkgray') + 
  ylab('nose/throat viral load\nrelative to peak') +
  xlab('days since symptom onset')
ggsave('viral-load-relative-to-peak_linear_y_real_time.png',units='in',width=7,height=3)


# guess at ct vs intensity
# peak probably around 15 https://www.ncbi.nlm.nih.gov/core/lw/2.0/html/tileshop_pmc/tileshop_pmc_inline.html?title=Click%20on%20image%20to%20zoom&p=PMC3&id=9031584_viruses-14-00654-g001.jpg
# cutoff around 30

d = d |>
  mutate(estimated_ct = 15-5*log10(estimated_genomes_relative_to_peak_mid)) |>
  mutate(estimated_ct_high = 15-5*log10(estimated_genomes_relative_to_peak_low)) |>
  mutate(estimated_ct_low = 15-5*log10(estimated_genomes_relative_to_peak_high))



ggplot(d |> filter(sample == 'nose_throat') ) +
  geom_line(aes(x=days_since_symptom_onset,y=estimated_ct,group=subject, color=subject)) +
  geom_point(aes(x=days_since_symptom_onset,y=estimated_ct,group=subject, color=subject)) +
  geom_line(aes(x=days_since_symptom_onset,y=estimated_ct_low,group=subject, color=subject),linetype='dashed') +
  geom_point(aes(x=days_since_symptom_onset,y=estimated_ct_low,group=subject, color=subject)) +
  geom_line(aes(x=days_since_symptom_onset,y=estimated_ct_high,group=subject, color=subject),linetype='dashed') +
  geom_point(aes(x=days_since_symptom_onset,y=estimated_ct_high,group=subject, color=subject)) +
  theme_bw() +
  scale_x_continuous(breaks=seq(1,14,by=2)) +
  scale_y_continuous(breaks=c(15,20,25,30,35),
                     minor_breaks = seq(15,35,by=2.5),
                     limits=c(15,35))+
  ylab('estimated ct') +
  xlab('days since symptom onset') #+
  # geom_vline(aes(xintercept=3),linetype='dotted') +
  # annotate('text',x=3.1,y=28,label='started\npaxlovid',hjust=0)
ggsave('estimated_ct.png',units='in',width=5,height=3)



ggplot(d |> filter(days_since_symptom_onset == 2 & subject=='Mike') ) +
  geom_segment(aes(x=sample,y=estimated_genomes_relative_to_peak_low,yend=estimated_genomes_relative_to_peak_high, group=sample)) +
  geom_point(aes(x=sample,y=estimated_genomes_relative_to_peak_mid, group=sample)) +
  facet_wrap('days_since_symptom_onset_label') +
  theme_bw() +
  scale_y_continuous(trans='log10',breaks=10^seq(-6,0,1),
                     minor_breaks = 10^seq(-6,0,0.1),
                     limits=c(1e-6,1.0))+
  ylab('viral load\n(estimated genome copies per mL)\nrelative to peak nose/throat') +
  xlab('sample type') 
ggsave('mask_vs_nt_viral-load-relative-to-peak.png',units='in',width=5,height=3)

ggplot(d |> filter(days_since_symptom_onset == 2 & subject=='Mike') ) +
  geom_segment(aes(x=sample,y=estimated_ct_low,yend=estimated_ct_high, group=sample)) +
  geom_point(aes(x=sample,y=estimated_ct, group=sample)) +
  facet_wrap('days_since_symptom_onset_label') +
  theme_bw() +
  scale_y_continuous(breaks=c(15,20,25,30,35,40,45),
                     minor_breaks = seq(15,45,by=2.5),
                     limits=c(15,45))+
  ylab('estimated ct') +
  xlab('sample type') 
ggsave('mask_vs_nt_estimated_ct.png',units='in',width=5,height=3)


# day 8 vs day 2 comparisons

d2 = d |> filter((days_since_symptom_onset == 2 | days_since_symptom_onset == 8 ) & subject=='Mike')

# raw data show complete and total negative for day 8 mask sample, even after 11 hours.
# but, to get an upper limit, we can note that day 2 mask-top was just barely detectable (brightness 3 below background)
# so, an upper limit on day 8 mask center after 11 hours is roughly 1/6 of the values for the day 2 mask top left of nose
# thus, the sampling duration upper limit adjusted censored values are roughly these
d2$estimated_genomes_relative_to_peak_high[d2$days_since_symptom_onset==8 & d2$sample=='mask_center'] =
 1/6*1/11*d2$estimated_genomes_relative_to_peak_high[d2$days_since_symptom_onset==2 & d2$sample=='mask_top_left_of_nose']

d2$estimated_genomes_relative_to_peak_mid[d2$days_since_symptom_onset==8 & d2$sample=='mask_center'] =
  1/6*1/11*d2$estimated_genomes_relative_to_peak_mid[d2$days_since_symptom_onset==2 & d2$sample=='mask_top_left_of_nose']

d2$estimated_genomes_relative_to_peak_low[d2$days_since_symptom_onset==8 & d2$sample=='mask_center'] =
  1/6*1/11*d2$estimated_genomes_relative_to_peak_low[d2$days_since_symptom_onset==2 & d2$sample=='mask_top_left_of_nose']

ggplot(d2 ) +
  geom_segment(aes(x=sample,y=estimated_genomes_relative_to_peak_low,yend=estimated_genomes_relative_to_peak_high, group=sample)) +
  geom_point(aes(x=sample,y=estimated_genomes_relative_to_peak_mid, group=sample)) +
  facet_wrap('days_since_symptom_onset_label') +
  theme_bw() +
  scale_y_continuous(trans='log10',breaks=10^seq(-8,0,1),
                     minor_breaks = 10^seq(-8,0,0.1),
                     limits=c(2e-8,1.0))+
  ylab('viral load\n(estimated genome copies per mL)\nrelative to peak nose/throat') +
  xlab('sample type') +
  theme(axis.text.x = element_text(angle = 15, vjust = 1., hjust=1))
ggsave('mask_vs_nt_viral-load-relative-to-peak_day8_upper_limit.png',units='in',width=6,height=3)



# relative infectiousness nose and mask center


d3 = d2 |> filter(sample !='mask_top_left_of_nose') |>
  group_by(sample) |>
  mutate(relative_infectiousness_mid = estimated_genomes_relative_to_peak_mid/max(estimated_genomes_relative_to_peak_mid)) |>
  mutate(relative_infectiousness_low = estimated_genomes_relative_to_peak_low/max(estimated_genomes_relative_to_peak_low)) |>
  mutate(relative_infectiousness_high = estimated_genomes_relative_to_peak_high/max(estimated_genomes_relative_to_peak_high)) |>
  select(sample,days_since_symptom_onset_label,relative_infectiousness_mid,relative_infectiousness_low,relative_infectiousness_high)
d3

ggplot(d3 |> filter(days_since_symptom_onset_label=='day 8')) + 
  geom_segment(aes(x=sample,y=relative_infectiousness_low,yend=relative_infectiousness_high, group=sample)) +
  geom_point(aes(x=sample,y=relative_infectiousness_mid, group=sample)) +
  theme_bw() +
  scale_y_continuous(trans='log10',breaks=10^seq(-8,0,1),
                     minor_breaks = 10^seq(-8,0,0.1),
                     limits=c(2e-6,1.0))+
  ylab('viral load day 8 relative to day 2') +
  xlab('sample type')  +
  theme(axis.text.x = element_text(angle = 5, vjust = 1., hjust=1))
ggsave('relative_viral_load_day8_vs_day2.png',units='in',width=3,height=3)


