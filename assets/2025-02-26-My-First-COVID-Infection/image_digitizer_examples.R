library(imager)
library(tidyverse)

theme_set(theme_bw())

#### example negative: Mike Day 13 toilet

# Load the image
image <- load.image("IMG_1501.JPEG")

# Convert the image to a dataframe
image_df <- as.data.frame(image, wide = "c") |>
  mutate(y=max(y)-y)

# plot image
ggplot(image_df) +
  geom_point(aes(x=x,y=y,color=c.1)) +
  scale_color_distiller(type = "seq",direction = -1,palette = "Greys",guide='none') 

# test strip extraction, with approx location of the lines
image_df |> filter((x==250 | x==392) & (y>800 & y<1100)) |>
  ggplot() +
  geom_point(aes(x=y,y=c.1,color=x))


### example with multiple tests, including a positive

# Load the image
image <- load.image("IMG_1499.JPEG")

# Convert the image to a dataframe
image_df <- as.data.frame(image, wide = "c") |>
  mutate(y=max(y)-y)

# plot image
ggplot(image_df) +
  geom_point(aes(x=x,y=y,color=c.1)) +
  scale_color_distiller(type = "seq",direction = -1,palette = "Greys",guide='none') +
  scale_y_continuous(breaks = seq(0,max(image_df$y),by=100),
                     minor_breaks = seq(0,max(image_df$y),by=25))

# test line for Mike day 12.5 nose
image_df |> filter((y==1125 ) & (x>725 & x<1000)) |>
  ggplot() +
  geom_point(aes(x=x,y=c.1,color=y)) +
  geom_vline(aes(xintercept = 770)) +
  annotate('text',x=770+5,y=0,label='test',hjust=0) +
  geom_vline(aes(xintercept = 900)) +
  annotate('text',x=900+5,y=0,label='control',hjust=0) 


round(0.31*255) # control
round(0.18*255) # test
round(0.64*255) # background

# test line for Mike day 12.5 mask
image_df |> filter((y>=1535 & y<=1555 ) & (x>725 & x<1000)) |>
  ggplot() +
  # geom_point(aes(x=x,y=c.1,color=y)) +
  geom_line(aes(x=x,y=c.1,color=y)) +
  # facet_wrap('y') +
  geom_vline(aes(xintercept = 777),linetype='dotted') +
  annotate('text',x=777+5,y=0,label='test',hjust=0) +
  geom_vline(aes(xintercept = 895)) +
  annotate('text',x=895+5,y=0,label='control',hjust=0) 

image_df |> filter((y>=1535 & y<=1555 ) & (x>725 & x<1000)) |>
  group_by(x) |>
  mutate(c.1=mean(c.1)) |>
  ungroup() |>
  ggplot() +
  geom_line(aes(x=x,y=c.1,color=y)) +
  geom_smooth(aes(x=x,y=c.1),se=FALSE) + 
  # facet_wrap('y') +
  geom_vline(aes(xintercept = 777),linetype='dotted') +
  annotate('text',x=777+5,y=0,label='test',hjust=0) +
  geom_vline(aes(xintercept = 895)) +
  annotate('text',x=895+5,y=0,label='control',hjust=0) +
  ylim(c(0.70,0.75))


round(0.38*255) # control
round(0.712*255) # test
round(0.718*255) # background



# test line for Mike day 12.5 throat
image_df |> filter((y>=645 & y<=660 ) & (x>700 & x<975)) |>
  ggplot() +
  # geom_point(aes(x=x,y=c.1,color=y)) +
  geom_line(aes(x=x,y=c.1,color=y)) +
  # facet_wrap('y') +
  geom_vline(aes(xintercept = 752),linetype='dotted') +
  annotate('text',x=752+5,y=0,label='test',hjust=0) +
  geom_vline(aes(xintercept = 880)) +
  annotate('text',x=880+5,y=0,label='control',hjust=0) 

image_df |> filter((y>=645 & y<=660 ) & (x>700 & x<975)) |>
  group_by(x) |>
  mutate(c.1=mean(c.1)) |>
  ungroup() |>
  ggplot() +
  geom_line(aes(x=x,y=c.1,color=y)) +
  geom_smooth(aes(x=x,y=c.1),se=FALSE) + 
  # facet_wrap('y') +
  geom_vline(aes(xintercept = 752),linetype='dotted') +
  annotate('text',x=752+5,y=0,label='test',hjust=0) +
  geom_vline(aes(xintercept = 880)) +
  annotate('text',x=880+5,y=0,label='control',hjust=0) +
  ylim(c(0.64,0.70))


round(0.39*255) # control
round(0.667*255) # test
round(0.667*255) # background


# test line for Mike day 12.5 stool

image_df |> filter((y>=215 & y<=230 ) & (x>725 & x<1000)) |>
  ggplot() +
  # geom_point(aes(x=x,y=c.1,color=y)) +
  geom_line(aes(x=x,y=c.1,color=y)) +
  # facet_wrap('y') +
  geom_vline(aes(xintercept = 768),linetype='dotted') +
  annotate('text',x=768+5,y=0,label='test',hjust=0) +
  geom_vline(aes(xintercept = 886)) +
  annotate('text',x=886+5,y=0,label='control',hjust=0) 

image_df |> filter((y>=215 & y<=230 ) & (x>725 & x<1000)) |>
  group_by(x) |>
  mutate(c.1=mean(c.1)) |>
  ungroup() |>
  ggplot() +
  geom_line(aes(x=x,y=c.1,color=y)) +
  geom_smooth(aes(x=x,y=c.1),se=FALSE) + 
  # facet_wrap('y') +
  geom_vline(aes(xintercept = 768),linetype='dotted') +
  annotate('text',x=768+5,y=0,label='test',hjust=0) +
  geom_vline(aes(xintercept = 886)) +
  annotate('text',x=886+5,y=0,label='control',hjust=0) +
  ylim(c(0.60,0.65))


round(0.37*255) # control
round(0.622*255) # test
round(0.622*255) # background



# marisa day 14
image <- load.image("IMG_3530.JPEG")

# Convert the image to a dataframe
image_df <- as.data.frame(image, wide = "c") |>
  mutate(y=max(y)-y)

# plot image
ggplot(image_df) +
  geom_point(aes(x=x,y=y,color=c.1)) +
  scale_color_distiller(type = "seq",direction = -1,palette = "Greys",guide='none') 

# test strip extraction, with approx location of the lines
image_df |> filter((x==125) & (y>370 & y<510)) |>
  ggplot() +
  geom_point(aes(x=y,y=c.1,color=x))



round(0.525*255) # control
round(0.48*255) # test
round(0.66*255) # background




# mike day 15 nose and throat
image <- load.image("IMG_1507.JPEG")

# Convert the image to a dataframe
image_df <- as.data.frame(image, wide = "c") |>
  mutate(y=max(y)-y)

# plot image
ggplot(image_df) +
  geom_point(aes(x=x,y=y,color=c.1)) +
  scale_color_distiller(type = "seq",direction = -1,palette = "Greys",guide='none') +
  scale_y_continuous(breaks=seq(0,500,by=100),minor_breaks=seq(0,500,by=50))

# nose test strip extraction, with approx location of the lines
image_df |> filter((x %in% 77) & (y>250 & y<350)) |>
  ggplot() +
  geom_point(aes(x=y,y=c.1,color=x))

round(0.435*255) # control
round(0.51*255) # test
round(0.83*255) # background

# throat test strip extraction, with approx location of the lines
image_df |> filter((x %in% 232) & (y>210 & y<330)) |>
  ggplot() +
  geom_point(aes(x=y,y=c.1,color=x))

round(0.525*255) # control
round(0.74*255) # test
round(0.80*255) # background



# mike day 15 sputum # sample too dilute -- low sensitivity
image <- load.image("IMG_1508.JPEG")

# Convert the image to a dataframe
image_df <- as.data.frame(image, wide = "c") |>
  mutate(y=max(y)-y)

# plot image
ggplot(image_df) +
  geom_point(aes(x=x,y=y,color=c.1)) +
  scale_color_distiller(type = "seq",direction = -1,palette = "Greys",guide='none') +
  scale_y_continuous(breaks=seq(0,500,by=100),minor_breaks=seq(0,500,by=50))

# nose test strip extraction, with approx location of the lines
image_df |> filter((x %in% c(100,184)) & (y>370 & y<=500)) |>
  ggplot() +
  geom_point(aes(x=y,y=c.1,color=x))

round(0.515*255) # control
round(0.625*255) # test
round(0.625*255) # background




# marisa day 14 
image <- load.image("IMG_3545.JPEG")

# Convert the image to a dataframe
image_df <- as.data.frame(image, wide = "c") |>
  mutate(y=max(y)-y)

# plot image
ggplot(image_df) +
  geom_point(aes(x=x,y=y,color=c.1)) +
  scale_color_distiller(type = "seq",direction = -1,palette = "Greys",guide='none') +
  scale_y_continuous(breaks=seq(0,1200,by=100),minor_breaks=seq(0,1200,by=50))

# nose test strip extraction, with approx location of the lines
image_df |> filter((x %in% c(150)) & (y>500 & y<=700)) |>
  ggplot() +
  geom_point(aes(x=y,y=c.1,color=x))

round(0.52*255) # control
round(0.745*255) # test
round(0.78*255) # background



# mike day 17 
image <- load.image("IMG_1523.JPEG")

# Convert the image to a dataframe
image_df <- as.data.frame(image, wide = "c") |>
  mutate(y=max(y)-y)

# plot image
ggplot(image_df) +
  geom_point(aes(x=x,y=y,color=c.1)) +
  scale_color_distiller(type = "seq",direction = -1,palette = "Greys",guide='none') +
  scale_y_continuous(breaks=seq(0,1200,by=100),minor_breaks=seq(0,1200,by=50))

# nose test strip extraction, with approx location of the lines
image_df |> filter((x %in% c(200)) & (y>600 & y<=900)) |>
  ggplot() +
  geom_point(aes(x=y,y=c.1,color=x))

round(0.38*255) # control
round(0.485*255) # test
round(0.53*255) # background



# mike day 19
image <- load.image("IMG_1542.JPEG")

# Convert the image to a dataframe
image_df <- as.data.frame(image, wide = "c") |>
  mutate(y=max(y)-y)

# plot image
ggplot(image_df) +
  geom_point(aes(x=x,y=y,color=c.1)) +
  scale_color_distiller(type = "seq",direction = -1,palette = "Greys",guide='none') +
  scale_y_continuous(breaks=seq(0,1200,by=100),minor_breaks=seq(0,1200,by=50))

# nose test strip extraction, with approx location of the lines
image_df |> filter((x %in% c(90)) & (y>350 & y<=450)) |>
  ggplot() +
  geom_point(aes(x=y,y=c.1,color=x))

round(0.48*255) # control
round(0.79*255) # test
round(0.81*255) # background

