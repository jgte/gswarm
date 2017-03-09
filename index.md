# Swarm as a gravity field mission

## Important facts

- Issued by the Swarm DISC consortium on behalf of ESA within the reference frame of ESA contract 4000109587/13/I-NB
- Point of contact: Swarm_DISC_ITT@space.dtu.dk, TELEFAX number: +45 4525 9701
- Closing Date: 20 Apr 2017 at 12:00 GMT

## Important documents

- [Swarm DISC Invitations To Tender](http://www.space.dtu.dk/english/research/projects/project-descriptions/swarm/swarm_disc_itts)
- [Cover Letter](http://www.space.dtu.dk/english/-/media/Institutter/Space/forskning/projekter/swarm/SwarmDISC/SD-ITT-1_1/SW-CL-DTU-GS-111_Cover_letter_ITT_1_1_rev2.ashx?la=da)
- [Statement of Work](http://www.space.dtu.dk/english/-/media/Institutter/Space/forskning/projekter/swarm/SwarmDISC/SD-ITT-1_1/SW-SW-DTU-GS-111_ITT1-1_SoW.ashx?la=da)
- [ Special Conditions of Tender](http://www.space.dtu.dk/english/-/media/Institutter/Space/forskning/projekter/swarm/SwarmDISC/SD-ITT-1_1/SW-TC-DTU-GS-111_ITT1-1_Special_Conditions_of_Tender.ashx?la=da)
- [Procurement Procedure](http://www.space.dtu.dk/english/-/media/Institutter/Space/forskning/projekter/swarm/SwarmDISC/SW-RS-DTU-GS-003_1B_Procurement_Procedure.ashx?la=da)

## People

- [TU Delft](http://www.lr.tudelft.nl/en/organisation/departments/space-engineering/astrodynamics-and-space-missions/people/):
  - Pieter Visser
  - Jose van den IJssel
  - Eelco Doornbos
  - João Encarnação (dual affiliation with CSR, UT Austin)
  - Xinyuan Mao
- [AIUB](http://www.aiub.unibe.ch/about_us/team/index_eng.html):
  - Adrian Jaggi
  - Daniel Arnold
  - Christoph Dahle (dual affiliation with GFZ, Germany)
- [ASU](http://galaxy.asu.cas.cz/planets/index.php?page=people):
  - Aleš Bezdek
  - Jaroslav Klokočník
- [IfG](https://www.tugraz.at/institute/ifg/institute/team/):
  - Torsten Mayer-Gürr
  - Norbert Zehentner
  - Matthias Ellmer
- [OSU](https://earthsciences.osu.edu/directory):
  - C.K. Shum
  - Kin Shang
  - Junyi Guo
  - Yu Zhang
  - Chaoyang Zhang

### G-Swarm researchers not involved in the answer to the Swarm ITT

- ASU
  - Josef Seabra


## Tasks

Task 1:
- Define the Swarm Gravity Field Processor
- Deliverable: TN-01, describing the gravity field processing methodology, standard and background models
- End by KO+4 months

Task 2: Swarm data pre-processing
- Define (and implement, if relevant) the GPS data pre-processing algorithms
- TN-02.1: trade-off between Swarm accelerometer data and non-gravitational models
  - TN-02.1.1: modelled non-gravitational accelerations (model name needed)
  - TN-02.1.2: modelled non-gravitational accelerations (NRTDM)
  - TN-02.1.3: measured non-gravitational accelerations (CalVal activities/Accelerometer Data Quality Working group/distributed by ESA)
- TN-02.2: added value of scalar ll-SST data derived from Swarm GPS data
- Deliverable: TN-02, detailing the results of the TN-02.1 and TN-02.2 studies
- End by KO+4 months

Task 3:
- Validate the produced models
- Deliverable: TN-03, demonstrating that Swarm's gravity fields are in agreement with those produced from GRACE data (up to a certain spherical harmonic degree)
- End by KO+6 months

Task 4:
- Process and deliver all Swarm gravity field models up to the end date of the Swarm ITT-funded activities (minus one month)
- Deliverables:
  - DL-01: monthly gravity field models
  - TN-04: product description
  - DL-04: respond by email to questions from the wider community regarding the modes
- End by KO+10 months

Task 5:
- Final presentation
- Deliverables:
  - DL-02: peer-review publication
  - DL-03: present the main achievements during a Swarm data quality workshop
- End by KO+12 months


## Work Breakdown Structure (in refinement)

- AIUB:
  - DL-01.1.1: produce kinematic orbits with covariance information using the Bernese software
  - DL-01.2.1: produce gravity fields with covariance information from kinematic orbits (and possibly from ll-SST data as well), using the Variational Equations approach
  - DL-01.3: perform combination of all models (using the automated facilities of EGSIEM, only after Jan 2018)
  - TN-02.2.1.1: produce ll-SST data with covariance information for selected months
  - TN-02.2.2.1: produce gravity fields with ll-SST data, considering (at least one of) TN-02.2.1.1 or TN-02.2.1.2
  - contribute to TN-01, TN-02, DL-02 and DL-03
- ASU:
  - DL-01.2.3: produce gravity fields with covariance information from kinematic orbits, using the Acceleration Approach
  - TN-02.1.1: produce modelled non-gravitational accelerations
  - TN-02.1: conduct and document the trade-off between Swarm accelerometer data and non-gravitational models, considering (all of) TN-02.1.1, TN-02.1.2 and TN-02.1.3
  - contribute to TN-01, TN-02, DL-02 and DL-03
- IfG:
  - DL-01.1.2: produce kinematic orbits with covariance information using the GROOPS software
  - DL-01.2.2: produce gravity fields with covariance information from kinematic orbits (and possibly from ll-SST data as well), using the Short-arc Approach
  - TN-02.2.2.2: produce gravity fields with ll-SST data, considering (at least one of) TN-02.2.1.1, TN-02.2.1.2
  - contribute to TN-01, TN-02, DL-02 and DL-03
- OSU:
  - DL-01.2.4: produce gravity fields with covariance information from kinematic orbits (and possibly from ll-SST data as well), using the Energy Balance Approach
  - TN-02.2.2.3: produce gravity fields with ll-SST data, considering (at least one of) TN-02.2.1.1 or TN-02.2.1.2
  - contribute to TN-01, TN-02, DL-02 and DL-03
- TU Delft: 
  - project management
  - DL-01.1.3: produce kinematic orbits with covariance information using the GHOST software
  - DL-01.4: data dissemination to ESA
  - TN-01: compile final document
  - TN-02.1.1: produce modelled non-gravitational accelerations
  - TN-02.2.1.2: produce ll-SST data with covariance information for selected months
  - TN-02.2: conduct and document the study of the added value of ll-SST data derived from Swarm GPS data, considering (all of) TN-02.2.2.1, TN-02.2.2.2 and TN-02.2.2.3
  - TN-02: compile final document, considering (all of) TN-02.1 and TN-02.2
  - TN-03: compile final document
  - TN-04: compile final document
  - DL-04: coordinate email responses (e.g. by directing questions to the relevant partner, if needed)





