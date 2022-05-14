---
layout: post
title: The best tools are fit for purpose
tags: disease-control situational-awareness prediction complex-interventions
---

Through research and policy work in epidemiology, we often want to learn stuff and communicate it to help make things less bad. As an infectious disease modeler, I most often focus on learning about disease transmission and its control, to try to help fewer people get infected with nasty things, so there is less death, disability, and discontent. Since the world is so complicated, it's really important that I think through how I plan to hook into the system before I pull my favorite model or analysis technique off the shelf and start playing with computers. To that end, it's worth thinking about what models can do well.

A really simplified block diagram of the flow of influence in the physical world looks like this:

![physical-world](/assets/2022-05-04-The-Best-Tools-Are-Fit-For-Purpose/physical-world.PNG)

Interventions --- things we choose that change the system, like vaccinations or wearing masks --- influence transmission dynamics --- all the interactions of pathogen, environment, and people --- to cause disease burden --- infections, deaths, disability --- that we only get a partial look at through what we measure.

Ideally, I'd like to live in a society capable of [closed-loop control](https://en.wikipedia.org/wiki/Control_theory#Open-loop_and_closed-loop_(feedback)_control) of infectious disease, where we can reactively modify narrowly-targeted interventions to maintain disease burden as close to zero as possible with tolerable (and hopefully very low because we're good at this) costs.

To do this, there are three main purposes for modeling that relate to how they plug into the control loop:

- situational awareness
- prediction and forecasting
- complex interventions

![closed-loop-control](/assets/2022-05-04-The-Best-Tools-Are-Fit-For-Purpose/closed-loop-control.PNG)

It would be awesome if we could do all of the modeling steps in one big model, but infectious disease is not nearly as simple as a fighter jet or nuclear reactor or toaster oven or adjusting the blanket when it's exactly neither hot nor cold in the bedroom. Because the world is much more complex than we can model, the models we have tend to be good at (at most) one of these three roles, and so it's important to know where you plan to plug in when you choose your model. What do I mean by the three roles?

### Situational awareness

The first, and _most underappreciated_, role is **situational awareness** modeling. Situational awareness modeling helps us understand how mechanisms we can’t see cause the things we can. The best situational awareness models take the measurements --- the many sometimes conflicting, always messy streams of data, often surveillance data in epi --- as primary.

![situational-awareness](/assets/2022-05-04-The-Best-Tools-Are-Fit-For-Purpose/situational-awareness.PNG)

From that mess of data and knowledge about the system you're working on from the scientific literature, these models help us make sense of what's coherent and what's conflicting among different data streams, what should we believe about the hidden states of the system (like how many infections are there given the cases and deaths we've seen?), what happened when the Governor "issued a lockdown"?, and how sure are we about any of this? Situational awareness modeling is the _feedback_ in the control loop that helps us understand what has happened recently, what is happening now, and how certain should we be, from which all else can follow.

### Prediction and Forecasting

**Prediction** and especially **forecasting** have gotten a ton of attention during the pandemic, both from modelers and the public. These models focus on what we know about the state and dynamics of the system and focus on what we can predict that we have not yet seen.

![prediction-forecasting](/assets/2022-05-04-The-Best-Tools-Are-Fit-For-Purpose/prediction-forecasting.PNG)

There are at least two broad classes of predictions. **Forecasts** focus on taking what we know about the state of the system and assumptions about future interventions that will happen and project them forward, to predict new data of the same kind that went into the model. Models can also make **structural predictions** that identify features of the system that we didn’t use to build the model. A good example that was possibly by mid-2021 for COVID was seeing that if antibody levels across trials of different vaccines correlate with vaccine efficacy, then vaccine efficacy should wane as antibodies wane, even though we haven't had time to see this yet.  Checking both types of predictions helps us test how well we understand the system and give us evidence for when we need to change interventions because the system is behaving in unplanned ways.

It's important to not take predictions as truth, because quality matters a ton. When accurate, prediction is useful for many things, including prioritization, resource allocation, anticipating trials, designing interventions... When imprecise, predictions tell you when you need more information. When inaccurate, predictions can lead to ineffective or harmful actions.

To that end, I think forecasting has gotten way too much attention during the pandemic, as 9 times out of 10, when someone is being given a forecast they probably need situational awareness. I much prefer modeling that doesn't take people's agency away by telling them what's gonna happen, particularly when the predictive accuracy is poor. I'd much rather see modeling that helps people understand what has happened and how their actions influenced it, so they can build their own understanding of the system dynamics and make good choices in the future. I should probably write a post dedicated to this rant, now that I've defined my terms.

### Complex interventions

Effective control strategies must make good choices from competing options amid uncertainty. Models of **complex interventions** help us predict the most effective ways to change the world and anticipate things that can go wrong.

![complex-interventions](/assets/2022-05-04-The-Best-Tools-Are-Fit-For-Purpose/complex-interventions.PNG)

These models are about choices, the evidence required to understand them, and the factors that going into making them. Complex intervention modeling is really important in epidemiology because everything is about trade-offs under constraints. No intervention is simple. And moreover, [reality has a surprising amount of detail](http://johnsalvatier.org/blog/2017/reality-has-a-surprising-amount-of-detail) and we must understand which details matter and when to reliably improve things thru our actions.

I think the majority of mathematical modeling published in epidemiology takes on this form, at many and varying levels of sophistication.  Anyone who's ever tried to model herd immunity from vaccination, as a function of vaccine efficacy, coverage, and waning has engaged in complex interventions modeling. This is bread and butter of grad school exercises in epi modeling. But the level of sophistication can get arbitrarily high, and can be done well at multiple scales in data-rich environments. Being complex, there's a lot more to say than I have the stamina for here, so I'll leave this under-developed for now.

### Comparing strengths

Situational awareness modeling differs from complex interventions modeling focused on weighing future choices. This often benefits from good situational awareness, but it doesn't always require it, both because the best interventions are beneficial no matter what exactly is going on (like vaccines) and because of fun math about absolute vs conditional uncertainty I should write a post about.

Situational awareness modeling also differs from forecasting in that the flexibility to accommodate the difference between what actually happened and what you expected to happen that is necessary in situational awareness models poorly constrains future expectations. And conversely, good forecasts can get things right because of continuity even if the underlying system is not understood in much detail at all ([great example](https://covid19-projections.com/)).

And if you are the 1 out of 10 that needs a forecast, you probably don't want a complex interventions model. Even under simple scenarios, there are often too many variables to consider, and most of them will co-vary in reality but you don't really know how, and so the real future is less uncertain than you are likely to model if you take your model honestly. A simpler structure can help with forecasting, at least until you get the next level of complexity _right_, but more on that will have to wait until a post on the modeling [uncanny valley](https://en.wikipedia.org/wiki/Uncanny_valley).

### Most models are only good at one thing

Thinking about this matters because most models are only good at one thing. So if you pick the wrong model type for your objective, you've got trouble coming. At best you'll be wrestling with the model to force it to do what you need (and so you should have a good reason to do this hard work (like, agent-based models excel for complex interventions but are rough for situational awareness (cite: [ABMs and calibration](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1007893))). At worst, you'll make some [ludicrous predictions because your model is unable to accommodate reality](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(22)00100-3/fulltext).

There is no one universal multitool in epi modeling. And while we should aspire to bring these closer together, we're still very far away. So think carefully about your objectives, and how you want to plug into the control loop of human activity, and choose wisely.
