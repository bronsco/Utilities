A SimEvents Model for Hybrid Traffic Simulation

To test and evaluate the efficiency of intelligent transportation systems, a SimEvents-based framework is introduced for hybrid traffic simulation at a microscopic level.

This framework enables users to apply different control strategies for Connected Automated Vehicles (CAVs) and carry out performance analysis of proposed algorithms by authoring customized discrete-event and hybrid systems based on MATLAB Discrete-Event System using object-oriented MATLAB.

**Reference**: Yue Zhang, Christos G. Cassandras, Wei Li, and Pieter J. Mosterman, *A SimEvents Model for Hybrid Traffic Simulation*, Winter Simulation Conference, 2017 (accepted)

***************************************************************************************************
Instructions:

* Open 'SingleIntersection.slx'
* If 'CAV' and 'INFO' entites are not preloaded, please run 'initialization' to load the CAV and INFO entities.
* Two control approaches are provided: (1) decentralized optimal control, (2) traffic light control. Use 'Switch' to select the mode.
* Run the simulation

***************************************************************************************************
Note:

* Control algorithms can be user-defined. In that case, please modify vehicle properties, dynamics and fuel consumption models accordingly.
* Visualization window needs to be re-defined if the parameters of the intersection change, for instance, the length of the control zone.

