THE IS A SAMPLE MULTIOBJECTIVE PROBLEM THAT DEPENDS ON THE PARETOFRONTS FUNCTION AVAILABLE ON:
http://www.mathworks.com/matlabcentral/fileexchange/37080-pareto-fronts-according-to-dominance-relation

In this folder we have a multiobjective optimization problem.
The GA framework will use a PICEA-g (2012) algorithm to solve it

Wang, R., Purshouse, R. C., & Fleming, P. J. (2012)
Preference-inspired Co-evolutionary Algorithms for Many-objective 
    Optimisation

PICEA-g is a co-evolutinary algorithm. A second auxiliar population of
vectors is needed to solve the main multiobjective problem.

This second population is kept and updated as part of the problem structure
while the main population is the one returned by the algorithm.

The fitness assignment depends on both objective function values so you
can't use the simple fitness scaling methods for monoobjective optimization
because the fitness assigment method is what makes the PICEA-g special.

Apart from that, in PICEA-g, all the children and parents compete for
survival together with a 100% elitism. So that also has to be changed in the
settings of the GA.