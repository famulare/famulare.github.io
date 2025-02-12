# teaching hypervigilance to LLMs

library(tidyverse)
library(patchwork)

# from https://arxiv.org/pdf/2501.19393
d=read.csv('s1-simple-test-time-scaling.csv')
names(d)
d

# relative 
p1 = ggplot(d) +
  geom_point(aes(x=average_tokens,y=relative_accuracy)) +
  theme_bw() +
  xlab('average thinking time (tokens)') +
  ylab('relative accuracy (AIME24)') +
  scale_y_continuous(limits=c(0,102),expand=c(0,0),breaks=c(0,20,40,60,80,100)) +
  scale_x_continuous(limits=c(0,8800),breaks=c(0,1024,2048,4096,8192),expand=c(0,0))
p1

#annotate
d$label = c('default\neffort',
                 'think harder',
                 'think harder',
                 'think it over',
                 'think it over again',
                 'hypervigilance',
                 'hypervigilance')
d$relative_thinking_time = d$average_tokens/d$average_tokens[7] *100

p2 =ggplot() + 
  geom_rect(aes(xmin=0,xmax=1,ymin=0,ymax=d$relative_accuracy[1]),fill='burlywood',alpha=0.5) +
  geom_text(aes(x = 1/2, y = d$relative_accuracy[1]/2, label = d$label[1]),size=3) +
  geom_rect(aes(xmin=0,xmax=1,ymin=d$relative_accuracy[1],ymax=d$relative_accuracy[3]),fill='darkolivegreen1',alpha=0.5) +
  geom_text(aes(x = 1/2, y = d$relative_accuracy[1] + (d$relative_accuracy[3]-d$relative_accuracy[1])/2, label = d$label[3]),size=3) +
  geom_rect(aes(xmin=0,xmax=1,ymin=d$relative_accuracy[3],ymax=d$relative_accuracy[4]),fill='green',alpha=0.5) +
  geom_text(aes(x = 1/2, y = d$relative_accuracy[3] + (d$relative_accuracy[4]-d$relative_accuracy[3])/2, label = d$label[4]),size=3) +
  geom_rect(aes(xmin=0,xmax=1,ymin=d$relative_accuracy[4],ymax=d$relative_accuracy[5]),fill='darkorange1',alpha=0.5) +
  geom_text(aes(x = 1/2, y = d$relative_accuracy[4] + (d$relative_accuracy[5]-d$relative_accuracy[4])/2, label = d$label[5]),size=3) +
  geom_rect(aes(xmin=0,xmax=1,ymin=d$relative_accuracy[5],ymax=d$relative_accuracy[7]),fill='firebrick1',alpha=0.5) +
  geom_text(aes(x = 1/2, y = d$relative_accuracy[5] + (d$relative_accuracy[7]-d$relative_accuracy[5])/2, label = d$label[7]),size=3) +
  theme_void() +
  scale_y_continuous(limits=c(0,102),expand=c(0,0),breaks=NULL) +
  scale_x_continuous(expand=c(0,0),breaks=NULL) 

p1+p2 + plot_layout(widths = c(0.65,0.35))
ggsave('s1-simple-test-time-scaling-AIME24-relative-accuracy.png',units='in',width=6,height=3)


ggplot() + 
  geom_rect(aes(xmin=0,xmax=d$relative_thinking_time[1],ymin=0,ymax=d$relative_accuracy[1]),fill='burlywood',alpha=0.3) +
  geom_text(aes(x = d$relative_thinking_time[1]/2, y = d$relative_accuracy[1]/2, label = d$label[1]),size=3) +
  geom_rect(aes(xmin=0,xmax=d$relative_thinking_time[2],ymin=d$relative_accuracy[1],ymax=d$relative_accuracy[2]),fill='darkolivegreen1',alpha=0.3) +
  geom_rect(aes(xmin=0,xmax=d$relative_thinking_time[3],ymin=d$relative_accuracy[2],ymax=d$relative_accuracy[3]),fill='darkolivegreen1',alpha=0.3) +
  geom_text(aes(x = (d$relative_thinking_time[2])/2, y = 60, label = d$label[3]),size=3) +
  # geom_rect(aes(xmin=d$relative_thinking_time[1],xmax=d$relative_thinking_time[2],ymin=d$relative_accuracy[1],ymax=d$relative_accuracy[2]),fill='darkolivegreen1',alpha=0.3) +
  # geom_rect(aes(xmin=d$relative_thinking_time[1],xmax=d$relative_thinking_time[3],ymin=d$relative_accuracy[2],ymax=d$relative_accuracy[3]),fill='darkolivegreen1',alpha=0.3) +
  # geom_text(aes(x = (d$relative_thinking_time[3] + d$relative_thinking_time[1])/2, y = d$relative_accuracy[2] + (d$relative_accuracy[3]-d$relative_accuracy[2])/2, label = d$label[3]),size=3) +
  geom_rect(aes(xmin=0,xmax=d$relative_thinking_time[4],ymin=d$relative_accuracy[3],ymax=d$relative_accuracy[4]),fill='green',alpha=0.3) +
  geom_text(aes(x = d$relative_thinking_time[4]/2, y = d$relative_accuracy[3] + (d$relative_accuracy[4]-d$relative_accuracy[3])/2, label = d$label[4]),size=3) +
  geom_rect(aes(xmin=0,xmax=d$relative_thinking_time[5],ymin=d$relative_accuracy[4],ymax=d$relative_accuracy[5]),fill='darkorange1',alpha=0.3) +
  geom_text(aes(x = d$relative_thinking_time[5]/2, y = d$relative_accuracy[4] + (d$relative_accuracy[5]-d$relative_accuracy[4])/2, label = d$label[5]),size=3) +
  geom_rect(aes(xmin=0,xmax=d$relative_thinking_time[6],ymin=d$relative_accuracy[5],ymax=d$relative_accuracy[7]),fill='firebrick1',alpha=0.3) +
  geom_rect(aes(xmin=d$relative_thinking_time[6],xmax=d$relative_thinking_time[7],ymin=d$relative_accuracy[5],ymax=d$relative_accuracy[7]),fill='firebrick1',alpha=0.6) +
  geom_text(aes(x = d$relative_thinking_time[6]/2, y = d$relative_accuracy[5] + (d$relative_accuracy[7]-d$relative_accuracy[5])/2, label = d$label[7]),size=3) +
  geom_point(data=d,aes(x=relative_thinking_time,y=relative_accuracy)) +
  theme_bw() +
  xlab('relative thinking time') +
  ylab('relative accuracy') +
  scale_y_continuous(limits=c(0,102),expand=c(0,0),breaks=c(0,20,40,60,80,100)) +
  scale_x_continuous(limits=c(0,102),breaks=c(0,20,40,60,80,100),expand=c(0,0))

ggsave('s1-simple-test-time-scaling-AIME24-relative-accuracy.png',units='in',width=6,height=3)
