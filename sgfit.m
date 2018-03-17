% SGFIT Shifted Gaussian Fitting with axis-wrapping.
%     [A, SIG, MU] = GAUSSFIT(X, Y, Xa) calculates the amplitude A, the
%     width SIG and the mean MU by Gaussian fitting. This function accounts
%     for the repetitive nature of X around +/-Xa, which commonly appears 
%     in spectra that are obtained by DFT.
%
%     GAUSSFIT derives the fitting using conventional method if Xa is not
%     supplied. That is, X is not assumed to wrap.
%
%     Boon Leng Cheong
%     Advanced Radar Research Center
%     University of Oklahoma
%

function [A, sig, mu] = sgfit(x, y, va)

if ~exist('va', 'var')
    sum_x = sum(x);
    sum_x2 = sum(x .^ 2);
    sum_x3 = sum(x .^ 3);
    sum_x4 = sum(x .^ 4);
    M = [numel(x) sum_x sum_x2; sum_x sum_x2 sum_x3; sum_x2 sum_x3 sum_x4];
    B = [sum(log(y)); sum(x .* log(y)); sum(x .^ 2 .* log(y))];
    d = M \ B;

    a = d(1); b = d(2); c = d(3);

    mu = -b / (2 * c);
    sig = sqrt(-1 / (2 * c));
    A = exp(a - b ^ 2 / (4 * c));
else
    % Normalized angle in [-pi, pi):
    omega = x / va * pi;

    % Complex-plane representation
    c = max(0, y) .* exp(1i * omega);
    
    % Average from the wheel
    mu = angle(sum(c));

    % Demodulate it down (which mean now is zero-mean Gaussian)
    d = c * exp(-1i * mu);

    % New x-axis
    x = angle(d) / pi * va;

    sum_x2 = sum(abs(x) .^ 2);
    sum_x4 = sum(abs(x) .^ 4);
    M = [numel(x) sum_x2; sum_x2 sum_x4];
    B = [sum(log(y)); sum(x .^ 2 .* log(y))];
    d = M \ B;
    a = d(1); c = d(2);

    mu = mu / pi * va;
    sig = sqrt(-1 / (2 * c));
    A = exp(a);
end