# Utilities

Continuously growing collection of various utility functions that might be useful. Please be aware of the individual licensing conditions.



## Table Of Contents

[Matlab](#matlab)

- [ComputerVision](#computer-vision)
- [ControlSystems](#control-systems)
- [DataHandling](#data-handling)
- [Finance](#finance)
- [General](#general)
- [ImageProcessing](#image-processing)
- [MachineLearning](#machine-learning)
- [Math](#math)
- [ParallelComputing](#parallel-computing)
- [Simulation](#mat-simulation)
- [Visualization](#visualization)

[Python](#python)

- [Simulation](#py-simulation)



## Matlab

#### ComputerVision

| Folder                       | Description                                                  | Source                                                       | Version | Updated | Note      |
| :--------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------- | ------- | --------- |
| mexopencv                    | Collection and development kit of MATLAB MEX functions for OpenCV library | [click](https://github.com/kyamagu/mexopencv)                | -       | -       | submodule |
| Point_cloud_tools_for_Matlab | This is a class for processing point clouds of any size in Matlab. It provides many functions to read, manipulate, and write point clouds. | [click](https://github.com/pglira/Point_cloud_tools_for_Matlab) | -       | -       | submodule |



#### ControlSystems

| Folder                | Description                                                  | Source                                                       | Version | Updated            | Note |
| :-------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------- | ------------------ | ---- |
| **`SystemTheory/`**   |                                                              |                                                              |         |                    |      |
| tdgui                 | GUI to find the step/impulse response of any plant by entering numerator and denominator coefficients only | [click](https://de.mathworks.com/matlabcentral/fileexchange/59000-step-and-impulse-response-without-coding) | 1.0.0.0 | September 3, 2016  | -    |
| **`KalmanFilter/`**   |                                                              |                                                              |         |                    |      |
| ekf                   | Extended Kalman Filter for nonlinear state estimation        | [click](https://de.mathworks.com/matlabcentral/fileexchange/18189-learning-the-extended-kalman-filter) | 1.0.0.0 | January 23, 2008   | -    |
| Kalman_Filter         | Kalman Filter, Extended Kalman Filter, Dual Kalman Filter and Square Root Kalman Filters | [click](https://de.mathworks.com/matlabcentral/fileexchange/24486-kalman-filter-in-matlab-tutorial) | 1.3.0.0 | October 21, 2011   | -    |
| Kalman_Filter_Package | Kalman Filter, Extended Kalman Filter, Dual Kalman Filter and Square Root Kalman Filters | [click](https://de.mathworks.com/matlabcentral/fileexchange/38302-kalman-filter-package) | 1.0.0.0 | September 24, 2012 | -    |
| LinearKalmanFilter    | A fully commented script which explains Linear Kalman Filtering in the form of a simple example | [click](https://ww2.mathworks.cn/matlabcentral/fileexchange/29127-linear-kalman-filter?s_tid=FX_rc3_behav) | 1.5.0.0 | November 24, 2010  | -    |
| ukf                   | An implementation of unscented Kalman filter for nonlinear state estimation | [click](https://de.mathworks.com/matlabcentral/fileexchange/18217-learning-the-unscented-kalman-filter) | 1.2.0.0 | December 12, 2010  | -    |
| ukfopt                | Using the unscented Kalman Filter to perform nonlinear least square optimization | [click](https://de.mathworks.com/matlabcentral/fileexchange/18356-nonlinear-least-square-optimization-through-parameter-estimation-using-the-unscented-kalman-filter) | 1.0.0.0 | February 4, 2008   | -    |



#### DataHandling

| Folder            | Description                                                  | Source                                                       | Version | Updated           | Note      |
| :---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------- | ----------------- | --------- |
| catstruct         | Concatenate/merge structures                                 | [click](https://de.mathworks.com/matlabcentral/fileexchange/7842-catstruct) | 1.3.0.0 | February 4, 2015  | -         |
| CatStruct2        | Concatenates Structures (fields each depth are merged)       | [click](https://de.mathworks.com/matlabcentral/fileexchange/34401-catstruct2) | 1.0.0.0 | December 31, 2011 | -         |
| dirPlus           | Recursively collect a list of files/folders from a folder tree | [click](https://github.com/kpeaton/dirPlus)                  | -       | -                 | submodule |
| MergeStruct       | Recursively merges fields and subfiels of two structures     | [click](https://de.mathworks.com/matlabcentral/fileexchange/34054-merge-structures) | 1.0.0.0 | December 2, 2011  | -         |
| nest_struct_merge | Merge a structure (array) to another structure (array) in a nested (recursive) way | [click](https://de.mathworks.com/matlabcentral/fileexchange/47199-recursive-structure-merge) | 1.1.0.0 | July 11, 2014     | -         |
| table2char        | Converts a table or dataset to a formatted character matrix  | [click](https://de.mathworks.com/matlabcentral/fileexchange/58951-table2char-data-varargin) | 1.7.0.0 | September 7, 2011 | -         |



#### FileIO

| Folder                    | Description                                                  | Source                                                       | Version | Updated            | Note      |
| :------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------- | ------------------ | --------- |
| csv2struct                | reads Excel's files stored in .csv or .xls file formats and stores results as a struct | [click](https://de.mathworks.com/matlabcentral/fileexchange/26106-csv2struct-filename) | 1.0.0.0 | February 22, 2016 | - |
| iniconfig | The class for working with configurations of settings and INI-files | [click](https://de.mathworks.com/matlabcentral/fileexchange/24992-ini-config) | 1.3.0.0 | March 22, 2010 | - |
| json4mat | This Matlab toolbox converts JSON formats into (json2mat) and from (mat2json) Matlab structures | [click](https://de.mathworks.com/matlabcentral/fileexchange/27169-json4mat) | 1.0.0.0 | April 05, 2010 | - |
| jsonlab | A toolbox to encode/decode JSON and UBJSON files in MATLAB/Octave | [click](https://github.com/fangq/jsonlab) | - | - | submodule |
| readObj | readObj file into Matlab structure | [click](https://de.mathworks.com/matlabcentral/fileexchange/18957-readobj) | 1.0.0.0 | February 28, 2008 | - |
| saveppt2 | Save Matlab figure(s) to a PowerPoint Slide | [click](https://de.mathworks.com/matlabcentral/fileexchange/19322-saveppt2) | 1.2.0.0 | June 3, 2010 | - |
| savezip | save/load data in a compressed zip file | [click](https://de.mathworks.com/matlabcentral/fileexchange/47698-savezip) | 1.0.0.0 | August 29, 2014 | - |
| STLRead | STLREAD imports geometry from a binary stereolithography (STL) file into MATLAB | [click](https://de.mathworks.com/matlabcentral/fileexchange/22409-stl-file-reader) | 1.2.0.0 | July 20, 2011 | - |
| struct2csv | Output a structure to a .csv file, with column headers | [click](https://de.mathworks.com/matlabcentral/fileexchange/34889-struct2csv) | 1.4.0.0 | June 18, 2013 | - |
| struct2xml | Convert a MATLAB structure into a XML file | [click](https://github.com/joe-of-all-trades/struct2xml) | - | - | submodule |
| xml_io_tools_2011_11_05 | Read XML files into MATLAB struct and writes MATLAB data types to XML | [click](https://de.mathworks.com/matlabcentral/fileexchange/12907-xml_io_tools) | 1.13.0.0 | November 5, 2010 | - |
| xml2struct | Convert an xml file into a MATLAB structure for easy access to the data | [click](https://github.com/joe-of-all-trades/xml2struct) | - | - | submodule |



#### Finance

| Folder          | Description                                                  | Source                                                       | Version | Updated         | Note |
| --------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------- | --------------- | ---- |
| hist_stock_data | Used to retrieve historical stock data for a user-specified date range | [click](https://de.mathworks.com/matlabcentral/fileexchange/18458-hist_stock_data-start_date-end_date-varargin) | 1.6.0.0 | August 10, 2017 | -    |
| indicators      | A single function that calculates 27 different technical indicators | [click](https://de.mathworks.com/matlabcentral/fileexchange/33430-technical-indicators) | 1.4.0.0 | May 24, 2013    | -    |



#### General

| Folder               | Description                                                  | Source                                                       | Version  | Updated           | Note                       |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------- | ----------------- | -------------------------- |
| bibget               | The easiest way to get BibTeX entries from IEEE Xplore       | [click](https://de.mathworks.com/matlabcentral/fileexchange/53412-bibget) | 2.4      | March 1, 2019     | -                          |
| docsgen_dot_tools    | ?                                                            | ?                                                            | ?        | ?                 | cannot find source anymore |
| fdep_21jun2010       | ?                                                            | ?                                                            | ?        | ?                 | cannot find source anymore |
| matlab-schemer       | Apply and save color schemes in MATLAB with ease             | [click](https://github.com/scottclowe/matlab-schemer)        | -        | -                 | submodule                  |
| plot_depfun_20161008 | plots a graph of the dependencies of a function              | [click](https://de.mathworks.com/matlabcentral/fileexchange/46080-plot_depfun) | 1.14.0.0 | October 8, 2016   | -                          |
| plot_subfun_20161207 | plots the subroutines in a function, and their dependencies on each other | [click](https://de.mathworks.com/matlabcentral/fileexchange/46070-plot_subfun) | 1.19.0.0 | December 7, 2016  | -                          |
| profile_history      | Display profiling data as an interactive timeline graph      | [click](https://de.mathworks.com/matlabcentral/fileexchange/46976-profile_history-display-graphical-profiling-timeline-data) | 1.7.0.0  | June 30, 2014     | -                          |
| uisignalbuilder2     | A visual tool that allows to build signals and save them to workspace variables | [click](https://de.mathworks.com/matlabcentral/fileexchange/41615-uisignalbuilder2) | 1.2.0.0  | September 7, 2016 | -                          |



#### ImageProcessing

| Folder               | Description                                                  | Source                                                       | Version | Updated            | Note      |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------- | ------------------ | --------- |
| FastGuassianBlur     | Evaluation of few methods to apply Gaussian Blur on an Image | [click](https://github.com/RoyiAvital/FastGuassianBlur)      | -       | -                  | submodule |
| gray2rgb             | Converts a gray image to color image                         | [click](https://de.mathworks.com/matlabcentral/fileexchange/8214-gray-image-to-color-image-conversion) | 1.0.0.0 | April 22, 2016     | -         |
| imgaussian_version1a | Fast Gaussian filtering of 1D, 2D greyscale / color image or 3D image volume | [click](https://de.mathworks.com/matlabcentral/fileexchange/25397-imgaussian) | 1.1.0.0 | October 1, 2009    | -         |
| imHistogram          | Histogram of 2D/3D grayscale or color images                 | [click](https://de.mathworks.com/matlabcentral/fileexchange/28681-imhistogram) | 1.0.0.0 | September 10, 2010 | -         |
| matImage             | Image Processing library for Matlab                          | [click](https://github.com/mattools/matImage)                | -       | -                  | submodule |



#### MachineLearning

| Folder                                | Description                                                  | Source                                                       | Version  | Updated            | Note      |
| ------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------- | ------------------ | --------- |
| cnn_class                             | This project provides matlab class for implementation of convolutional neural networks | [click](https://de.mathworks.com/matlabcentral/fileexchange/24291-cnn-convolutional-neural-network-class) | 1.29.0.0 | October 24, 2012   | -         |
| DeepLearnToolbox                      | Matlab/Octave toolbox for deep learning. Includes Deep Belief Nets, Stacked Autoencoders, Convolutional Neural Nets, Convolutional Autoencoders and vanilla Neural Nets. | [click](https://github.com/rasmusbergpalm/DeepLearnToolbox)  | -        | -                  | submodule |
| DeepNeuralNetwork20160805             | It provides deep learning tools of deep belief networks (DBNs) | [click](https://de.mathworks.com/matlabcentral/fileexchange/42853-deep-neural-network) | 1.19     | August 5, 2016     | -         |
| FANN                                  | Fast Artificial Neural Network Library                       | [click](https://github.com/libfann/fann)                     | -        | -                  | submodule |
| matlab2weka                           | An efficient interface to use Weka in MATLAB                 | [click](https://de.mathworks.com/matlabcentral/fileexchange/50120-using-weka-in-matlab) | 1.5      | July 22, 2015      | -         |
| MLP_NN                                | A Multilayer Perceptron (MLP) Neural Network Implementation with Backpropagation Learning | [click](https://de.mathworks.com/matlabcentral/fileexchange/54076-mlp-neural-network-with-backpropagation) | 1.0.0.0  | December 25, 2016  | -         |
| mweka                                 | Runs Machine Learning Tool Weka from MATLAB                  | [click](https://de.mathworks.com/matlabcentral/fileexchange/24839-mweka-running-machine-learning-tool-weka-from-matlab) | 1.2.0.0  | September 12, 2012 | -         |
| netlab                                | Pattern analysis toolbox                                     | [click](https://de.mathworks.com/matlabcentral/fileexchange/2654-netlab) | 1.0.0.0  | December 2, 2002   | -         |
| sklearn-matlab                        | Machine learning in Matlab using scikit-learn syntax         | [click](https://github.com/steven2358/sklearn-matlab)        | -        | -                  | submodule |
| wekalab                               | A package for calling Weka functions from within Matlab      | [click](https://github.com/NicholasMcCarthy/wekalab)         | -        | -                  | submodule |
| **`Demo/`**                           |                                                              |                                                              |          |                    |           |
| DeepLearningDemos                     | Download code and watch video series to learn and implement deep learning techniques | [click](https://de.mathworks.com/matlabcentral/fileexchange/62990-deep-learning-tutorial-series?focused=2c5403d6-8073-5943-43da-5184559d33bf&tab=function) | 1.1.0.0  | December 5, 2017   | -         |
| DeepLearningForComputerVision         | Deep learning to recognize objects using convolution neural networks(CNN's) | [click](https://de.mathworks.com/matlabcentral/fileexchange/57116-deep-learning-for-computer-vision-demo-code) | 1.1.0.1  | September 1, 2016  | -         |
| DeepLearningWebinar                   | Demos Used in "Object Recognition: Deep Learning and Machine Learning for Computer Vision" Webinar | [click](https://de.mathworks.com/matlabcentral/fileexchange/58320-demos-from-object-recognition-deep-learning-webinar) | 1.0.0.1  | May 2, 2017        | -         |
| DEMOS                                 |                                                              |                                                              |          |                    |           |
| NeuralNetPlayground                   | A MATLAB implementation of the TensorFlow Neural Networks Playground seen on [http://playground.tensorflow.org/](http://playground.tensorflow.org/) | [click](https://github.com/StackOverflowMATLABchat/NeuralNetPlayground) | -        | -                  | submodule |
| Webinar_DeepLearningForComputerVision | Example files for "Deep Learning for Computer Vision with MATLAB" Webinar | [click](https://de.mathworks.com/matlabcentral/fileexchange/58030-example-files-for-deep-learning-for-computer-vision-with-matlab-webinar) | 1.1.0.0  | April 13, 2017     | -         |



#### Math

| Folder                           | Description                                                  | Source                                                       | Version  | Updated            | Note                                                      |
| :------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------- | ------------------ | --------------------------------------------------------- |
| **`Filter/`**                    |                                                              |                                                              |          |                    |                                                           |
| filter1                          | 1D zero-phase frequency filtering using butterworth filters  | [click](https://de.mathworks.com/matlabcentral/fileexchange/53534-filter1) | 1.0.0.0  | October 14, 2015   | -                                                         |
| FilterM_20Jul2011                | A faster FILTER and FILTFILT: Speedup factor 2.5 to 25       | [click](https://de.mathworks.com/matlabcentral/fileexchange/32261-filterm) | 1.0.0.0  | July 20, 2011      | -                                                         |
| **`Integration/`**               |                                                              |                                                              |          |                    |                                                           |
| odesolver                        | - 1st-/2nd-order Euler<br />- 3rd-/4th-/5th-order Runge-Kutta | [click](https://de.mathworks.com/matlabcentral/answers/98293-is-there-a-fixed-step-ordinary-differential-equation-ode-solver-in-matlab-8-0-r2012b) | -        | -                  | from post on Matlab Answers                               |
| simps                            | The Simpson's rule uses parabolic arcs instead of the straight lines used in the trapezoidal rule | [click](https://de.mathworks.com/matlabcentral/fileexchange/25754-simpson-s-rule-for-numerical-integration) | 1.5.0.0  | May 22, 2013       | -                                                         |
| **`Interpolation/`**             |                                                              |                                                              |          |                    |                                                           |
| interpne                         | Interpolates and extrapolates using n-linear interpolation (tensor product linear) | ?                                                            | ?        | ?                  | cannot find source anymore                                |
| interpns                         | N-dimensional simplicial interpolation                       | [click](https://de.mathworks.com/matlabcentral/fileexchange/30932-interpns?focused=5184621&tab=function) | 1.0.0.0  | March 31, 2011     | -                                                         |
| lininterp                        | Much faster version of the interp functions, but ONLY for LINEAR interpolation | [click](https://de.mathworks.com/matlabcentral/fileexchange/28376-faster-linear-interpolation?focused=5157196&tab=function) | 1.3.0.0  | August 4, 2010     | -                                                         |
| qinterp                          | - Performs nearest-neighbor or linear interpolation much faster than interp1 when an evenly-spaced lib<br />- Provides a 5x-50x speedup over interp2 | [click](https://de.mathworks.com/matlabcentral/fileexchange/10286-fast-interpolation?focused=5068480&tab=function)<br />[click](https://de.mathworks.com/matlabcentral/fileexchange/10772-fast-2-dimensional-interpolation?focused=5071545&tab=function) | 1.0.0.0  | May 31, 2006       | -                                                         |
| **`Misc/`**                      |                                                              |                                                              |          |                    |                                                           |
| colornoise                       | Pink, red, blue and violet noise generation via spectral processing of a white noise | [click](https://de.mathworks.com/matlabcentral/fileexchange/42919-pink-red-blue-and-violet-noise-generation-with-matlab) | 1.8.0.0  | December 3, 2018   | -                                                         |
| DERIVESTsuite                    | Numerical derivative of an analytically supplied function, also gradient, Jacobian & Hessian | [click](https://de.mathworks.com/matlabcentral/fileexchange/13490-adaptive-robust-numerical-differentiation) | 1.6      | December 3, 2014   | -                                                         |
| distance2curve                   | Find the closest point on a (n-dimensional) curve to any given point or set of points | [click](https://de.mathworks.com/matlabcentral/fileexchange/34869-distance2curve) | 1.1.0.0  | February 27, 2013  | -                                                         |
| GSAT                             | Set of Matlab routines developed for calculating sensitivity indices of a generic user-defined model | [click](https://de.mathworks.com/matlabcentral/fileexchange/40759-global-sensitivity-analysis-toolbox) | 1.57.0.0 | February 17, 2017  | made some modifications for more generic and faster usage |
| InterX                           | Fast computation of intersections and self-intersections of curves using vectorization | [click](https://de.mathworks.com/matlabcentral/fileexchange/22441-curve-intersections?focused=5165138&tab=function) | 1.5.0.0  | September 24, 2010 | -                                                         |
| mesh2d                           | MESH2D is a MATLAB-based Delaunay mesh generator for two-dimensional geometries | [click](https://github.com/dengwirda/mesh2d)                 | -        | -                  | submodule                                                 |
| MinBoundSuite                    | Suite of tools to compute minimal bounding circles, rectangles, triangles, spheres, incircles, etc. | [click](https://de.mathworks.com/matlabcentral/fileexchange/34767-a-suite-of-minimal-bounding-objects) | 1.2.0.0  | May 23, 2014       | -                                                         |
| Movingstd1&2                     | A (fast) windowed std on a time series (or array)            | [click](https://de.mathworks.com/matlabcentral/fileexchange/9428-movingstd-movingstd2) | 1.4.0.0  | April 8, 2016      | -                                                         |
| mtimesx_20110223                 | Fast Matrix Multiply with Multi-Dimensional Support          | [click](https://de.mathworks.com/matlabcentral/fileexchange/25977-mtimesx-fast-matrix-multiply-with-multi-dimensional-support) | 1.10.0.0 | February 23, 2011  | -                                                         |
| nansuite                         | Descriptive Statistics for N-D matrices ignoring NaNs        | [click](https://de.mathworks.com/matlabcentral/fileexchange/6837-nan-suite) | 1.0.0.0  | May 5, 2008        | -                                                         |
| vec2grid-pkg                     | Reshapes vector data to a grid                               | [click](https://github.com/kakearney/vec2grid-pkg)           | -        | -                  | submodule                                                 |
| **`Optimization/`**              |                                                              |                                                              |          |                    |                                                           |
| FMINSEARCHBND                    | Bound constrained optimization using fminsearch              | [click](https://de.mathworks.com/matlabcentral/fileexchange/8277-fminsearchbnd-fminsearchcon) | 1.4.0.0  | February 6, 2012   | -                                                         |
| GA_framework                     | This is a toolbox to run a GA on any problem you want to model | [click](https://de.mathworks.com/matlabcentral/fileexchange/37998-open-genetic-algorithm-toolbox) | 1.12.0.0 | October 29, 2012   | -                                                         |
| GA-Toolbox                       | Genetic Algorithm Toolbox for MATLAB                         | [click](https://github.com/UoS-CODeM/GA-Toolbox)             | -        | -                  | submodule                                                 |
| OPTI                             | OPTimization Interface (OPTI) Toolbox is a **free** MATLAB toolbox for constructing and solving linear, nonlinear, continuous and discrete optimization problems | [click](https://github.com/jonathancurrie/OPTI)              | -        | -                  | submodule                                                 |
| psomatlab                        | Particle swarm optimization (PSO) is a derivative-free global optimum solver | [click](https://github.com/sdnchen/psomatlab)                | -        | -                  | submodule                                                 |
| ypea121-mopso                    | A structure MATLAB implementation of MOPSO for Evolutionary Multi-Objective Optimization | [click](https://de.mathworks.com/matlabcentral/fileexchange/52870-multi-objective-particle-swarm-optimization-mopso?focused=5569570&tab=function) | 1.0.0.0  | October 20, 2015   | -                                                         |
| **`Regression/`**                |                                                              |                                                              |          |                    |                                                           |
| ARESLab                          | Building piecewise-linear and piecewise-cubic regression models | [click](http://www.cs.rtu.lv/jekabsons/regression.html)      | 1.13.0   | May 15, 2016       | -                                                         |
| createCrossValidationSets        | Creates training/validation bins for cross validation        | [click](https://de.mathworks.com/matlabcentral/fileexchange/50101-cross-validation-sets) | 1.0.0.0  | March 19, 2015     | -                                                         |
| easyfit                          | EASYFIT fits the experimental data (x,y) to a model function y = fun(p,x) | [click](https://de.mathworks.com/matlabcentral/fileexchange/10625-easyfit-x-y-varargin) | 1.4.0.0  | May 30, 2018       | -                                                         |
| fitcircle                        | a simple circle fitting method                               | [click](https://de.mathworks.com/matlabcentral/fileexchange/66307-fitcircle-x-y) | 1.0.0.0  | March 4, 2018      | -                                                         |
| gapolyfitn                       | optimises the functional form of a multi-dimensional polynomial fit to model data | [click](https://de.mathworks.com/matlabcentral/fileexchange/25499-gapolyfitn?focused=3804152&tab=function) | 1.12.0.0 | December 17, 2013  | -                                                         |
| gfit2                            | Computes goodness of fit for regression model given matrix/vector of target and output values | [click](https://de.mathworks.com/matlabcentral/fileexchange/22020-goodness-of-fit-modified) | 1.8.0.0  | July 1, 2009       | -                                                         |
| gridfitdir                       | Model 2-d surfaces from scattered data                       | [click](https://de.mathworks.com/matlabcentral/fileexchange/8998-surface-fitting-using-gridfit?focused=6011424&tab=function) | 1.1.0.0  | March 4, 2016      | -                                                         |
| Inpaint_nans                     | Interpolates (& extrapolates) NaN elements in a 2d array     | [click](https://de.mathworks.com/matlabcentral/fileexchange/4551-inpaint_nans) | 1.1.0.0  | August 13, 2012    | -                                                         |
| inpaintn                         | Y = INPAINTN(X) computes the missing data in the N-D array X | [click](https://de.mathworks.com/matlabcentral/fileexchange/27994-inpaint-over-missing-data-in-1-d-2-d-3-d-nd-arrays) | 1.4.2.0  | September 21, 2017 | -                                                         |
| K-mean Clustering and RBF _V_1.0 | Radial Basis Functions (RBF) neural network with K-means clustering and Pseudo inverse method | [click](https://de.mathworks.com/matlabcentral/fileexchange/46220-radial-basis-function-with-k-mean-clustering?focused=3844933&tab=function) | 1.11     | September 21, 2019 | -                                                         |
| kNearestNeighbors                | Find the k - nearest neighbors (kNN) within a set of points  | [click](https://de.mathworks.com/matlabcentral/fileexchange/15562-k-nearest-neighbors) | 1.4.0.0  | March 26, 2009     | -                                                         |
| loess                            | Matlab mex function to perform a locally weighted robust regression | [click](https://github.com/bartverm/loess)                   | -        | -                  | submodule                                                 |
| loess-matlab                     | Robust locally weighted regression                           | [click](https://github.com/bartverm/loess-matlab)            | -        | -                  | submodule                                                 |
| LWP                              | Locally Weighted Polynomial regression                       | [click](http://www.cs.rtu.lv/jekabsons/regression.html)      | 2.2      | September 3, 2016  | -                                                         |
| M5PrimeLab                       | Building regression trees and model trees using M5' method as well as building ensembles of M5' trees | [click](http://www.cs.rtu.lv/jekabsons/regression.html)      | 1.7.0    | August 5, 2016     | -                                                         |
| nricp                            | Matlab implementation of non-rigid iterative closest point   | [click](https://github.com/charlienash/nricp)                | -        | -                  | submodule                                                 |
| PolyfitnTools                    | Polynomial modeling in 1 or n dimensions                     | [click](https://de.mathworks.com/matlabcentral/fileexchange/34765-polyfitn) | 1.3      | April 27, 2016     | -                                                         |
| PRIM                             | Patient Rule Induction Method                                | [click](http://www.cs.rtu.lv/jekabsons/regression.html)      | 1.0      | November 9, 2015   | -                                                         |
| RBF                              | Radial Basis Function interpolation with biharmonic, multiquadric, inverse multiquadric, thin plate spline, and Gaussian basis functions | [click](http://www.cs.rtu.lv/jekabsons/regression.html)      | 1.1      | August 12, 2009    | -                                                         |
| rbf_1_04                         | Simulates and trains Gaussian and polyharmonic spline radial basis function networks | [click](https://de.mathworks.com/matlabcentral/fileexchange/22173-radial-basis-function-network?focused=3856563&tab=function) | 1.3.0.0  | December 2, 2014   | -                                                         |
| rbfinterp_v1.2                   | Scattered Data Interpolation and Approximation using Radial Base Functions | [click](https://de.mathworks.com/matlabcentral/fileexchange/10056-scattered-data-interpolation-and-approximation-using-radial-base-functions) | 1.0.0.0  | October 9, 2006    | -                                                         |
| RBFNs                            | RBF Neural Networks (center and distribution of activation functions are selected using K-means) | [click](https://de.mathworks.com/matlabcentral/fileexchange/52580-radial-basis-function-neural-networks-with-parameter-selection-using-k-means) | 1.0.0.0  | September 7, 2015  | -                                                         |
| RBFNs_rnd                        | RBF Neural Networks (center and distribution of activation functions are selected randomly) | [click](https://de.mathworks.com/matlabcentral/fileexchange/52748-rbf-neural-networks-with-random-selection-of-parameters) | 1.0.0.0  | August 30, 2015    | -                                                         |
| SLMtools                         | Least squares spline modeling using shape primitives         | [click](https://de.mathworks.com/matlabcentral/fileexchange/24443-slm-shape-language-modeling) | 1.14     | April 16, 2017     | -                                                         |
| smoothn                          | SMOOTHN allows automatized and robust smoothing in arbitrary dimension w/wo missing values | [click](https://de.mathworks.com/matlabcentral/fileexchange/25634-smoothn) | 2.2.1    | September 16, 2018 | -                                                         |
| SparsifiedKMeans                 | KMeans for big data using preconditioning and sparsification, Matlab implementation | [click](https://github.com/stephenbeckr/SparsifiedKMeans)    | -        | -                  | submodule                                                 |
| spinterp                         | MATLAB library which can determine points defining a sparse grid in a multidimensional space, and given specific values at those points, can construct an interpolating function that can be evaluated anywhere. | [click](https://people.sc.fsu.edu/~jburkardt/m_src/spinterp/spinterp.html) | 5.1.1    | February 24, 2008  | -                                                         |
| splinefit                        | Fit a spline to noisy data                                   | [click](https://de.mathworks.com/matlabcentral/fileexchange/71225-splinefit) | 1.0.0    | April 16, 2019     | -                                                         |
| **`Sampling/`**                  |                                                              |                                                              |          |                    |                                                           |
| createdoe                        | This function can be used to generate either a Latin hypercube or Sobol quasi-random sets | [click](https://de.mathworks.com/matlabcentral/fileexchange/48573-sobol-and-latin-hypercube-design-of-experiments-doe-and-sensitivity-analysis-studies) | 1.0.0.1  | September 1, 2016  | -                                                         |
| LHS                              | Latin Hypercube Sampling                                     | [click](https://de.mathworks.com/matlabcentral/fileexchange/4352-latin-hypercube-sampling?focused=5050784&tab=function) | 1.0.0.0  | November 18, 2004  | -                                                         |
| randMat                          | Generate random numbers uniformally in a given range or matching a given normal distribution | [click](https://de.mathworks.com/matlabcentral/fileexchange/24712-randmat) | 1.2.0.0  | October 6, 2009    | -                                                         |
| randsphere                       | Randomly and uniformly distributes points throughout a hypersphere | [click](https://de.mathworks.com/matlabcentral/fileexchange/9443-random-points-in-an-n-dimensional-hypersphere?focused=5063757&tab=function) | 1.0.0.0  | December 28, 2005  | -                                                         |
| **`SystemIdentification/`**      |                                                              |                                                              |          |                    |                                                           |
| LMNtool_Version_1.5.2            | This object-oriented Matlab toolbox covers two algorithms for building local model networks (also called Takagi-Sugeno fuzzy systems) from data | [click](http://www.mb.uni-siegen.de/mrt/lmn-tool/index.html?lang=de) | 1.5.2    | September 6, 2017  | -                                                         |


#### ParallelComputing

| Folder               | Description                                                  | Source                                                       | Version  | Updated       | Note |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | -------- | ------------- | ---- |
| multicore 2014-07-20 | This package provides parallel processing on multiple cores/machines. | [click](https://de.mathworks.com/matlabcentral/fileexchange/13775-multicore-parallel-processing-on-multiple-cores) | 1.39.0.0 | July 20, 2014 | -    |



#### Simulation

| Folder                         | Description                                      | Source                                                       | Version | Updated            | Note      |
| ------------------------------ | ------------------------------------------------ | ------------------------------------------------------------ | ------- | ------------------ | --------- |
| 2009Sep_SGA_suspension_skyhook | Semi-active control of skyhook                   | [click](https://de.mathworks.com/matlabcentral/fileexchange/11118-semi-active-control-of-skyhook-for-1-4-suspension-system) | 1.1.0.0 | September 30, 2009 | -         |
| openvd                         | Open source simulation package for Octave/Matlab | [click](https://github.com/andresmendes/openvd)              | -       | -                  | submodule |



#### Visualization

| Folder                   | Description                                                  | Source                                                       | Version  | Updated            | Note                                          |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | -------- | ------------------ | --------------------------------------------- |
| arrow                    | Draw a line with an arrowhead                                | [click](https://de.mathworks.com/matlabcentral/fileexchange/278-arrow) | 2.1.0.0  | May 25, 2016       | -                                             |
| boundedline-pkg          | Plot line(s) with error bounds/confidence intervals/etc. in Matlab | [click](https://github.com/kakearney/boundedline-pkg)        | -        | -                  | submodule                                     |
| BrewerMap                | The complete palette of ColorBrewer colormaps                | [click](https://github.com/DrosteEffect/BrewerMap)           | -        | -                  | submodule                                     |
| colornames               | RGB to color name. Color name to RGB. Palettes: CSS, HTML, MATLAB, SVG, X11, xcolor, xkcd,... | [click](https://de.mathworks.com/matlabcentral/fileexchange/48155-convert-between-rgb-and-color-names) | 4.0.1    | July 4, 2019       | -                                             |
| contourf3                | Plots a 3D coloured contour, as contourf, on a 3D plane      | [click](https://de.mathworks.com/matlabcentral/fileexchange/61091-contourf3) | ?        | ?                  | this file has been removed from File Exchange |
| display_obj              | display wavefront object structure                           | [click](https://de.mathworks.com/matlabcentral/fileexchange/20307-display_obj) |          | June 17, 2008      | -                                             |
| dynamicDateTicks         | Create plots with date-friendly data cursors and smart date ticks that scale with zooming & panning | [click](https://de.mathworks.com/matlabcentral/fileexchange/27075-intelligent-dynamic-date-ticks) | 1.5.0.1  | September 1, 2016  | -                                             |
| ellipse                  | Adds ellipses to the current plot                            | [click](https://de.mathworks.com/matlabcentral/fileexchange/289-ellipse-m) | 1.1.0.0  | March 26, 2018     | -                                             |
| export_fig               | A MATLAB toolbox for exporting publication quality figures   | [click](https://github.com/altmany/export_fig)               | -        | -                  | submodule                                     |
| fixPSlinestyle           | Fixes line styles in postscript files created from MATLAB® (PRINT command) | [click](https://de.mathworks.com/matlabcentral/fileexchange/17928-fixpslinestyle) | 1.2.0.1  | September 1, 2016  | -                                             |
| googleearth_matlab       | Various plotting/drawing functions that can be saved as KML output, and loaded in Google Earth | [click](https://de.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox) | 1.6.0.0  | February 2, 2012   | -                                             |
| gramm                    | Gramm (...) provides an easy to use and high-level interface to produce publication-quality plots of complex data with varied statistical visualizations | [click](https://github.com/piermorel/gramm)                  | -        | -                  | submodule                                     |
| GUI Layout Toolbox 2.3.1 | Layout manager for MATLAB graphical user interfaces          | [click](https://de.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox) | 2.3.1.0  | January 30, 2017   | -                                             |
| hline_vline              | Draws 'low-impact' horizontal or vertical lines on the current axes | [click](https://de.mathworks.com/matlabcentral/fileexchange/1039-hline-and-vline) | 1.0.0.0  | November 9, 2001   | -                                             |
| linspecer                | Plot lots of lines with very distinguishable and aesthetically pleasing colors | [click](https://de.mathworks.com/matlabcentral/fileexchange/42673-beautiful-and-distinguishable-line-colors-colormap) | 1.4.0.0  | September 16, 2015 | -                                             |
| plot_array               | Easy plot of a matrix (or more than one) with many channels  | [click](https://de.mathworks.com/matlabcentral/fileexchange/56687-easy-visualization-of-rows-of-a-matrix-or-more-matrices?s_tid=FX_rc3_behav) | 1.2.0.0  | June 27, 2016      | -                                             |
| plot_google_map          | MATLAB function for plotting a Google map on the background of a figure | [click](https://github.com/zoharby/plot_google_map)          | -        | -                  | submodule                                     |
| plot2svg_20120915        | Converts 3D and 2D MATLAB plots to the scalable vector format (SVG) | [click](https://de.mathworks.com/matlabcentral/fileexchange/7401-scalable-vector-graphics-svg-export-of-figures) | 1.8.0.0  | September 17, 2012 | -                                             |
| PlotArray                | Use this function to help plot multiple data series of different size without using hold | [click](https://de.mathworks.com/matlabcentral/fileexchange/39931-plotarray) | 1.0.0.0  | January 21, 2013   | -                                             |
| PlotPub                  | Publication quality plot in MATLAB                           | [click](https://github.com/masumhabib/PlotPub)               | -        | -                  | submodule                                     |
| plotyyy                  | PLOTYYY - Extends plotyy to include a third y-axis           | [click](https://de.mathworks.com/matlabcentral/fileexchange/1017-plotyyy) | 1.0.0.0  | November 14, 2001  | -                                             |
| resize_legend            | Changes LEGEND fontsize                                      | [click](https://de.mathworks.com/matlabcentral/fileexchange/2190-resize_legend) | 1.0.0.0  | September 28, 2004 | -                                             |
| resizeLegend             | Shortens a legend                                            | [click](https://de.mathworks.com/matlabcentral/fileexchange/58914-resizelegend-varargin) | 1.2.0.0  | June 29, 2018      | -                                             |
| screen2jpeg              | Generate a JPEG file of the current figure with dimensions consistent with the figure's screen dimensions | ?                                                            | ?        | ?                  | cannot find source anymore                    |
| sliceomatic-2.3          | Volume slice visualization gui                               | [click](https://de.mathworks.com/matlabcentral/fileexchange/764-sliceomatic) | 1.1.0.1  | September 1, 2016  | -                                             |
| Slicer-2017.01.31        | GUI for exploration of 3D images (stacks)                    | [click](https://de.mathworks.com/matlabcentral/fileexchange/27983-slicer) | -        | -                  | submodule                                     |
| spaceplots_v3            | Customize spaces between subplots in a figure                | [click](https://de.mathworks.com/matlabcentral/fileexchange/35464-spaceplots) | 1.5.0.0  | June 3, 2013       | -                                             |
| subaxis                  | Use HTML jargon for multi axis layout                        | [click](https://de.mathworks.com/matlabcentral/fileexchange/3696-subaxis-subplot) | 1.1.0.0  | July 9, 2014       | -                                             |
| subplot_grid             | A subplot figure with a lot of fancy features                | [click](https://de.mathworks.com/matlabcentral/fileexchange/34191-subplot_grid) | 1.11.0.0 | January 12, 2015   | -                                             |
| subtightplot             | Asymmetric subplots with variable inner gaps and outer margins | [click](https://de.mathworks.com/matlabcentral/fileexchange/39664-subtightplot) | 1.2.0.0  | January 8, 2013    | -                                             |
| tight_subplot            | Fills the figure with axes subplots with easily adjustable margins and gaps between the axes | [click](https://de.mathworks.com/matlabcentral/fileexchange/27991-tight_subplot-nh-nw-gap-marg_h-marg_w) | 1.1.0.0  | March 3, 2016      | -                                             |
| tightfig                 | Remove excess margins from figures                           | [click](https://de.mathworks.com/matlabcentral/fileexchange/34055-tightfig-hfig) | 1.7.0.0  | February 13, 2018  | -                                             |



## Python

#### Video

| Folder | Description                                                  | Source                                     | Version | Updated | Note      |
| ------ | ------------------------------------------------------------ | ------------------------------------------ | ------- | ------- | --------- |
| pytube | A lightweight, dependency-free Python library (and command-line utility) for downloading YouTube Videos | [click](https://github.com/nficano/pytube) | -       | -       | submodule |