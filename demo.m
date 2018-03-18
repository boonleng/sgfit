% This is a demo script to illustrate the advantage of GSFIT over the
% conventional Gaussian fitting method.

% Some default parameters
set(groot, 'defaultLineLineWidth', 1.5)
set(0, 'DefaultAxesLineWidth', 1.0)

% Number of samples
N = 40;

% Aliasing velocity
va = 15;

% Spectral ampiltude
A = 0.5;

% Mean
% mu = round(4 * va * (rand(1) - 0.5)) / 2;
mu = 5;

% Width
sig = 3;

% Noise ampiltude
An = 1e-1 * A;

fprintf('True Val: mu = %.4f   sig = %.4f   A = %.4f\n', mu, sig, A);

% Noise amplitude
% n = An * (rand(1, N) - 0.5);
n = 0;

% x-axis with actual velocity
v = (0: N - 1) / N * 2 * va - va;
x = v;

% Our Gaussian function
y = A * exp(-(x - mu) .^ 2 / (2 * sig ^ 2)) + ...
    A * exp(-(x - mu - 2 * va) .^ 2 / (2 * sig ^ 2)) + ...
    A * exp(-(x - mu + 2 * va) .^ 2 / (2 * sig ^ 2)) + ...
    0.5 * An;

% Single modal Gaussian function (easy case)
% y = A * exp(-(x - mu) .^ 2 / (2 * sig ^ 2)) + n;

% Store a copy of the original
xo = x;
yo = y;

% Add noise
y = y + n;

% Some threshold to select what data samples to use
% th = 0.2 * A;
th = 0.5 * sqrt(mean(y .^ 2));

%% Method 1

% Mask of good samples
mask = y > th;

% Let's say we have a good estimate of noise
y1 = y - 0.5 * An;

% Original method: Estimate everything as if the function has infinite
% x-axis in both directions
[A1, sig1, mu1] = sgfit(x(mask), y1(mask));
fprintf('Method 1: mu = %.4f   sig = %.4f   A = %.4f\n', mu1, sig1, A1);

% Synthetic curve from parameters estimated by method 1
y1s = A1 * exp(-(v - mu1) .^2 / (2 * sig1 ^ 2)) + 0.5 * An;


%% Method 2

% Normalized angle in [-pi, pi):
omega = v / va * pi;

% ReLU amplitude
a = max(0, y1);

% Complex-plane representation
cp = (a + 0.1 * A) .* exp(1i * omega);

% Demodulated x-axis (which mean now is zero-mean Gaussian)
dp = (a + 0.1 * A) .* exp(1i * omega) * exp(-1i * mu / va * pi);

% Modified method: Zero mean assumed
[A2, sig2, mu2] = sgfit(x(mask), y1(mask), va);
fprintf('Method 2: mu = %.4f   sig = %.4f   A = %.4f\n', mu2, sig2, A2);

% Internal representation (zero mean)
y2i = A2 * exp(-v .^2 / (2 * sig2 ^ 2)) + 0.25 * An;

% Synthetic curve based on estimates
y2s = A2 * exp(-(v - mu2) .^2 / (2 * sig2 ^ 2)) + ...
      A2 * exp(-(v - mu2 + 2 * va) .^2 / (2 * sig2 ^ 2)) + ...
      A2 * exp(-(v - mu2 - 2 * va) .^2 / (2 * sig2 ^ 2)) + ...
      0.5 * An;

% Cosmetics
if mask(1) == true
    s = find(mask == false, 1, 'last') + 1;
    e = find(mask == false, 1, 'first') - 1;
    ind = [s:N, 1:e];
else
    s = find(mask, 1, 'first');
    e = s + sum(mask) - 1;
    ind = s:e;
end

%% Plots

highlight = [0.85 0.96 0];

figure(1)
clf

subplot(2, 2, 1:2)
if mask(1) == true
    dx = x(2) - x(1);
    hl = plot([x(s:N), x(N) + 0.5 * dx,     nan, x(1) - 0.5 * dx,     x(1:e)], ...
              [y(s:N), 0.5 * (y(N) + y(1)), nan, 0.5 * (y(N) + y(1)), y(1:e)]);
else
    hl = plot(x(ind), y(ind));
end
set(hl, 'LineStyle', '-', 'Marker', '.', 'MarkerSize', 45, 'Color', highlight,  'LineWidth', 15)
hold on
hl = plot(xo, y, '.', xo, yo, '-', v, y1s, '--', v, y2s, '-.');
set(hl(1), 'MarkerSize', 15)
hold off
grid on
M = 2 * va / N;
axis([-va - M, va, 0, 1.8 * A])
xlabel('Velocity (m/s)')
ylabel('Amplitude')
title('Conventional Gaussian Fitting vs SGFIT')
tstr = sprintf('mu = %.4f   sig = %.4f   A = %.4f (ground truth)\n', mu, sig, A);
m1str = sprintf('mu = %.4f   sig = %.4f   A = %.4f (conventional)\n', mu1, sig1, A1);
m2str = sprintf('mu = %.4f   sig = %.4f   A = %.4f (SGFIT)\n', mu2, sig2, A2);
if mu < 0
    loc = 'northeast';
else
    loc = 'northwest';
end
legend('Used Samples', 'Original Dataset', tstr, m1str, m2str, 'Location', loc)

subplot(2, 2, 3)
plot(cp(ind), 'Color', highlight,  'LineWidth', 10)
hold on
plot(cp)
plot(cp(1), 'ob')
% plot([0, A * exp(1i * mu / va * pi)], 'o-')
quiver(0, 0, A * cos(mu / va * pi), A * sin(mu / va * pi), 1, 'LineWidth', 5, 'MaxHeadSize', 0.5)
hold off
grid on
xlabel('In-Phase')
ylabel('Quadrature')
title('Complex Plane Representation')
legend('Used', 'All Data', 'First Pt.', 'True Dir.', 'Location', 'Best')
set(gca, 'DataAspect', [1 1 1])
axis([-1 1 -1 1] * 1.5 * A)

subplot(2, 2, 4)
plot(dp(ind), 'Color', highlight, 'LineWidth', 10)
hold on
plot(dp)
plot(dp(1), 'ob')
quiver(0, 0, A, 0, 1, 'LineWidth', 5, 'MaxHeadSize', 0.5)
hold off
grid on
xlabel('In-Phase')
ylabel('Quadrature')
title('Rotate Complex Plane Representation')
legend('Used', 'All Data', 'First Pt.', 'True .Dir', 'Location', 'Best')
set(gca, 'DataAspect', [1 1 1])
axis([-1 1 -1 1] * 1.5 * A)

pos = get(gcf, 'Position');
set(gcf, 'Position', [pos(1:2), 600, 640])
