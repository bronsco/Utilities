function [ableitung] = x_dotLQR(t,x)
global A b R
ableitung = (A-b*R)*x;