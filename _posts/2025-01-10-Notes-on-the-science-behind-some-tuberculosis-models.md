---
layout: post
title: Notes on the science behind some tuberculosis models
tags: tuberculosis model-building
---

Trying something new: this is a notes dump on some papers about tuberculosis models. I'm trying to learn more about where the dynamical models used in TB modeling come from. So, instead of just doing this in private, I figure I'll post it too. Why not?

# [EMOD-TB](https://docs.idmod.org/projects/emod-tuberculosis/en/2.20_a/tb-overview.html) 

Here is the paper that describes IDM's (our) original EMOD-TB parameterization. [Huynh *et al* 2015. Tuberculosis control strategies to reach the 2035 global targets in China: the role of changing demographics and reactivation disease.](https://pmc.ncbi.nlm.nih.gov/articles/PMC4424583/)

## [Vynnycky and Fine 1997 The natural history of tuberculosis: the implications of age-dependent risks of disease and the role of reinfection.](https://pubmed.ncbi.nlm.nih.gov/9363017/)
- Based on England and Wales since 1900, and restricted to white males. Incidence data the model is calibrated to spans 1953-1988.
- I'm a big fan of Paul Fine. And this is fundamental from the abstract: "We conclude that the risk of infection is the single most important factor affecting the magnitude of the tuberculous morbidity in a population, as it determines both the age pattern of initial infection (and hence the risk of developing disease) and the risk of reinfection."
- Focused on age and reinfection. They conclude lots of reinfection, under the assumption that there is a decent amount of fast (<5yr) progression.
- Data on multiple years of post-WW2 surveys of sputum-positive fraction among TB cases by age. 

    ![Sputum-positive-among-cases-by-age](/assets/2025-01-10-Notes-on-the-science-behind-some-tuberculosis-models/VynnyckyFine2c_sputum_pos_by_age.png)
- Exponential waiting with a mean time of about a year, from BCG trial in the 1950s.
    ![primary-disease-progression-rate](../assets/2025-01-10-Notes-on-the-science-behind-some-tuberculosis-models/VynnyckyFine2b_exponential_waiting_primary_disease_data.png)
    - EMOD-TB does this via latent-fast with a 0.5 year time constant and presymptomatic active of 1 year time constant, for a total fast progression to active of 1.5 years on average.
- Table 3: endogenous (slow) progressor rate in >5yo is very slow, roughly mean waiting time of 50 years. 3-8% progress in first 5 years upon reinfection; all else at that very slow rate. Seems kids (<=5) have no slow progression.
    ![VynnyckyFine Table 3](../assets/2025-01-10-Notes-on-the-science-behind-some-tuberculosis-models/VynnyckyFineTable3.png)
- Implied effect of immunity is reduce rate of active disease from reinfection by a factor of 2 or so. This is consistent with everything T-cell-mediated in infectious disease that I'm aware of. 



## [Abu-Raddad *et al* 2009](https://www.pnas.org/doi/abs/10.1073/pnas.0901720106)

___

For attribution, please cite this work as:

`Famulare (2025, Jan 10). Notes on the science behind some tuberculosis models. Retrieved from https://famulare.github.io/2025/01/10/Notes-on-the-science-behind-some-tuberculosis-models.html.`

____
