---
layout: post
title: Two fun inferences about neutralizing antibodies and viral infection
tags: polio biophysics night-science immunity-theory-series
---

> **Edit March 7, 2024**: In hindsight, this is the first of what I hope will be many ["Night Science"](https://night-science.org/) posts on the fuzzy, playfully creative side of science. Many thanks to [Itan Yanai](https://twitter.com/ItaiYanai) and [Martin Lercher](https://twitter.com/MartinJLercher) for celebrating this kind of thing in the biosciences.

____

I find myself thinking a lot about immunity these days. What is the immune system doing? I've acquired a lot of biological knowledge over the last decade and change, but I'm not so much interested at the moment in *how* it does what it does, but why it does it and what are its constraints. 

Two that end, here's two fun inferences about poliovirus neutralization, viral infectiousness, and antibody biophysics, in people. Briefly, we can figure out a lot about how viruses and neutralizating antibodies interact in the body just from looking at statistics of infection probability vs dose.

## Intro to dose response modeling

Polio is a very useful model system because we have a ubiquitous and ethical human challenge model---the live-attenuated vaccine completely replicates the natural history of wild poliovirus infection while being much less virulent. Using a bunch of data about oral vaccine challenge and transmission-acquired infections for people with all sorts of immunization histories, in our [paper on how susceptibility to poliovirus infection and poliovirus shedding depend on individual-level immunity, and what that means for transmission and eradication](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.2002468), we developed a dose response model for the probability of infection given an oral dose of poliovirus.

Dose response models capture the probability of infection as a function of dose. While we often model infection probability based on being exposed or not, it is not that simple. Viruses and people are noisy systems, and so the probability that a virus infects a person depends on how many tries the virus gets. The bigger the dose, the bigger the number of tries, and the higher probability of success. Dose response models capture this biology at the scale of host-virus interaction with no detail about the mechanisms of infection. See this [tutorial by the UN FAO](https://www.fao.org/3/y4666e/y4666e0b.htm) for a more thorough introduction. 

The simplest dose response model is exponential, based on the Poisson distribution, where the probability of infection is the probability that at least one viral infectious unit sucessfully initiates infection, $1-\exp(-rD)$, where $r\in(0,1)$ is the average probability of causing an infection per infectious unit and $D$ is the number of infectious units---aka the dose. A better model which accounts for heterogeneities in response across people to a measured dose is the beta-Poisson model, which assumes that the rate $r$ is itself beta-distributed. For a detailed discussion of the meaning of the beta-Poisson model in the context of parameter inference, see [Schmidt *et al* 2013](https://pubmed.ncbi.nlm.nih.gov/23311599/).

I kept saying "infectious unit" above because there are different definitions. One intuitively might thing we count the number of viral particles and talk about infectiousness per virion, but that is rarely measured because it's hard and [not often clear that it's the right thing biologically anyway](https://www.nature.com/articles/d41586-019-01880-6). More common is to use a reference standard, like the cell culture infectious dose that causes 50% of cell culture plates using a standarized assay get infected when exposed to virus. This measure, abbreviated CCID50, is much more commonly measured in the lab and used. 

## Back to polio

Our poliovirus dose response model is the standard approxiamte beta-Poisson model for the probability of infection as a function of dose, with a novel dependency on pre-existing neutralizing antibody levels

$$ P\left(\text{infection}|\text{dose},N_{\text{Ab}}\right) = 1-\left(1+\frac{\text{dose}}{\beta}\right)^{-\alpha/\left(N_{\text{Ab}}\right)^{\gamma}}$$

where $\alpha$ and $\beta$ control the distribution of the probability an infectious dose causes a human infection, $N_{Ab}$ refers to the measured neutralizing antibody titer in a person before being dosed, and $\gamma$ controls how measured antibody titers influence infectious probability.

In the standard beta-Poisson model, there is no antibody dependence ($\gamma=0$). But that's one of the key questions for polio and we have a lot of data, so I came up with the antibody dependence term just by looking at the data, trying to find a one-parameter function that would work okay, and knowing that power laws come up in biology all the time so that was a good guess. This model has held up pretty well to new data since, and so we're happy to keep using it.

## Inference number 1: how does neutralization affect infectiousness?

If we take seriously that $\alpha$ and $\beta$ describe the distribution of infectiousness per infectious unit, we can calculate the mean infectious probability and how it changes with immunity. 

$$\bar{r}_{N_{\text{Ab}}}=\frac{\frac{\alpha}{N_{\text{Ab}}^{\gamma}}}{\frac{\alpha}{N_{\text{Ab}}^{\gamma}}+\beta}$$

For the poliovirus type 1 Sabin vaccine, where we have the best data, we found that $\alpha=0.44$, $\beta=14$, and $\gamma=0.46$ (ignoring uncertainty; see Table A in the [paper's supplement](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.2002468#sec016) for more.)  For someone with no pre-existing immunity ($N_{Ab}=1$ by definition), the mean infectiousness per infectious dose CCID50 is 

$$\bar{r}_{N_{\text{Ab}}=1}=\frac{0.44}{0.44+14} = 0.03.$$

Or equivalently, roughly 1 of every 33 infectious units on average causes an infection in people with no prior immunity.

Similarly, for a highly-immune person with an antibody titer of $2^9=512$, the mean infectiousness per dose CCID50 is 

$$\bar{r}_{N_{\text{Ab}}=512}=\frac{\frac{0.44}{2^{9*.46}}}{\frac{0.44}{2^{9*.46}}+14} = 0.0018,$$ 

or roughly every 1 of 560 infectious units gets through the immunity to cause an infection.

This gives us a nice picture of how immunity works. Even without prior adaptive immunity, most viruses don't manage to cause an infection. Too many things go wrong, both by chance and due to other antiviral defenses we have. But, even with a lot of prior immunity, it is possible for really large doses to get through and cause an infection. [In the case of polio, the infection is much milder, shorter lived, and less likely to transmit](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.2002468), but it's an infection nonetheless---immunity is leaky.  

We also can see how the idea of so-called "sterilizing" immunity works. If you're highly immunized and your living conditions and social connections are such that you will never get a dose close 560 CCID50, then the probability of getting a polio infection is very low. You are, to a good approximation, not susceptible anymore.  But if you live somewhere with much higher exposures, your immunity will not just be leaky in principle, but leaky in practice---you'll get reinfected from time to time. This shows that the concept of immunity in epidemiology depends on exposure. This example is for polio, but this is *always* true biologically.

## Inference number 2: viral neutralization in the human gut is sub-diffusive.

As I mentioned above, I just made up the functional form for the immunity dependence to fit data. But with the benefit of years of hindsight, that the choice works is far from arbitrary. The [intuition behind the beta distribution](https://stats.stackexchange.com/questions/47771/what-is-the-intuition-behind-beta-distribution) is that it's a distribution over probabilities, and the parameters represent "pseudocounts" that describe how many successful tries $\alpha$ and unsucessful tries $\beta$ result from a typical 1 CCID50 exposure. For example, if the only thing that matters is there are something like 100 virions in 1 CCID50 for poliovirus, then we might've expected $\alpha=3$ and $\beta = 97$, but the fact that the psuedocounts are smaller says there is [more variability we don't know the cause of than just counting particles](https://www.nature.com/articles/s41579-020-00449-9).  

With this intuition in mind, it makes sense that pre-existing adaptive immunity (neutralizing antibodies and everything else relevant and correlated with them), enters the formula through $\alpha$---the parameter that describes the successes in infecting an unimmunized host---and not $\beta$---the parameter describing the expected failures in the absence of adaptive immunity. Immunity can't make things fail more than failing in the first place, so there is no sensitivity there. 

Furthermore, purely mathematically, let's consider the log odds of infection for an average particle.

$$\log\left(\frac{\bar{r_{N_\text{Ab}}}}{1-\bar{r_{N_\text{Ab}}}}\right)=\log\left(\frac{\alpha}{\beta}\right)-\gamma\log(N_{\text{Ab}})$$

This logit-log dependence on antibody titer is exactly how we think about neutralization in cell culture, as [discussed here for example](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7973348/). 

In a culture system where a neutralization assay is operating in the linear regime---where virus and neutralizing sera are well-mixed (not diffusion-limited) and neither reagent fully binds (not concentration-limited)---I expect that $\gamma=1$. As in, the amount of infectious virus is proportional to the fraction of non-neutralized virus. In the parameter regime here, this corresponds to $\bar{r}\approx\frac{\alpha / \beta}{N_{Ab}}$.  

To confirm this is right, it would be nice to look at published cell culture titration curves. It's not easy to find poliovirus titration curves in the literature (vs just the CCID50 derived from them), but this paper by [Arita *et al*](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3209023/) shows a data for pseudovirus neutralization, and that the pseudovirus assay is nicely correlated with the standard infectious virus assay. I digitized Figure 2B for the percent neutralization vs antibody titer, combined the serotypes, and fitted the logistic-linear model above a few different ways (to deal with various censoring issues and unclear sample sizes). Depending on what data I include and how I do the least squares problem, I get $\gamma$ between 0.8 and 1.4, which I think is consistent enough with 1 for my purposes here. See the [Excel workbook](/assets/2024-01-12-Two-fun-inferences-about-neutralizing-antibodies-and-viral-infection/Arita2011_Fig2_dilution_traces.xlsx) for details. 

**So anyway, here's what really cool.**  In humans, we estimate $\gamma=0.46$ which is definitely less than 1 (and more importantly, definitely less than whatever we exactly see in a cell culture system).  This means that poliovirus neutralization in the human body--specifically for gut infection measured by stool sampling---is *sub-diffusive*. As in, the ability of neutralizing antibodies to find virus is less efficient than in a cell culture system, and not just proportionally so, but with decreasing efficiency as antibody levels in the blood get higher. 

This is super cool and it also should be super obvious, like so many things in hindsight. Why? Antibodies have to find the virus, but our tissues are really crowded. So diffusion is slower than in simple solution. Moreover, poliovirus replication primarily starts in the gut---on a two-dimensional(ish) surface[^1] that antibodies need to be trafficked to from serum and cellular media through crowded tissue. It's probably possible to figure out something that can be measured independently about the subdiffusive dynamics of antibody and virion mixing just from the exponents and a physical model. That might be fun to try some day. 

But until then, it's cool to see that looking at the probability a person gets a detectible infection, composed of bazillions of replicating viruses, from a small dose, can tell us non-trivial stuff about biophysics inside our tissues. Pretty cool!


____

For attribution, please cite this work as:

`Famulare (2024, Jan 12). Two fun inferences about neutralizing antibodies and viral infection. Retrieved from https://famulare.github.io/2024/01/12/Two-fun-inferences-about-neutralizing-antibodies-and-viral-infection.html.`

____

[^1]: I should write up something about the fractal dimensions of various tissue and organ systems, because it's super cool too. 
