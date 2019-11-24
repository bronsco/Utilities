% LMNTool demo 1. static process with 1 input and 1 output

% LMNTool - Nonlinear System Identification Toolbox
% Institute of Mechanics & Automatic Control 
% University of Siegen, Germany 
% Copyright (c) 2012 by Prof. Dr.-Ing. Oliver Nelles et. al.


% generate input data on a grid
input  = rand(100,1);
inputG = linspace(0,1,50)';

% product of a hyperbel and a sinus function
output  = (1+sin(4*pi*input-pi/8)) .* (0.1./(0.1+input));
outputG = (1+sin(4*pi*inputG-pi/8)) .* (0.1./(0.1+inputG));

outputG = outputG + 0.01*randn(size(outputG))*(max(outputG)-min(outputG));

dataVal  = [inputG outputG];
dataTest = [inputG outputG];

% add some noise
output = output + 0.05*randn(size(output))*(max(output)-min(output));
dataTrain = [input output];

% start training
[LMNBest AllLMN] = LMNTrain(dataTrain, dataVal, dataTest);


% plot
figure
outputModelG = LMNBest.calculateModelOutput(inputG);
hold on
plot(inputG,outputG,'color',[0.9 0.9 0.9],'linestyle','-','linewidth',1.5)
plot(inputG,outputModelG,'k-')
plot(input,output,'kx','markersize',12)
hold off
box on
axis([0 1 -0.2 1])
xlabel('input')
ylabel('output')
legend('process','model','data')


