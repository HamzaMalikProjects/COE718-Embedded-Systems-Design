%% All Graphs for ELE 532 (Convolution / Spectra / Speech)
clear; close all; clc;

%% ------------------------------------------------------------
%% Code 1  Rectangular pulse and FFT (no plots)
%% ------------------------------------------------------------

N = 100;
pulsewidth = 10;
m = 0:1:(N-1);

x  = [ones(1, pulsewidth), zeros(1, N - pulsewidth)];
Xf = fft(x);
% Frequency vector (not used later here, but kept for completeness)
f  = [-(N/2):1:(N-2)-1] * (1 - N);
Zf = Xf .* Xf;   % |X(f)|^2 in frequency domain


%% ------------------------------------------------------------
%% Code 2  Magnitude & Phase Spectrum of Z(f)
%% ------------------------------------------------------------

N = 100;
pulsewidth = 10;

x  = [ones(1, pulsewidth), zeros(1, N - pulsewidth)];
Xf = fft(x);
Zf = Xf .* Xf;

f = [-(N/2):1:(N/2)-1] * (1/N);

figure;
subplot(2,1,1);
plot(f, fftshift(abs(Zf)));
grid on;
xlabel('f');
title('Magnitude Spectrum of Z(f)');

subplot(2,1,2);
plot(f, fftshift(angle(Zf)));
grid on;
xlabel('f');
title('Phase Spectrum of Z(f)');


%% ------------------------------------------------------------
%% Code 3  Time-domain convolution animation + IFFT comparison
%% ------------------------------------------------------------

% Unit step
u = @(t) 1.0.*(t >= 0);

% x(t) and h(t) are both length-10 rectangular pulses
x = @(t) 1.*(u(t) - u(t-10));
h = @(t) 1.*(u(t) - u(t-10));

dtau = 0.005;
tau  = -1:dtau:25;

ti   = 0;
tvec = -0.25:0.1:25;

y = NaN*zeros(1, length(tvec));   % convolution result y(t)

figure;
for t = tvec
    ti = ti + 1;

    % Product x(t - tau) * h(tau)
    xh  = x(t - tau) .* h(tau);
    lxh = length(xh);

    % Approximate convolution integral (sum of product * dtau)
    y(ti) = sum(xh .* dtau);

    % --- Top subplot: show h(tau), x(t - tau), and their product area ---
    subplot(2,1,1);
    plot(tau, h(tau), 'k-', tau, x(t - tau), 'k--', t, 0, 'ok');
    axis([tau(1) tau(end) -2.0 2.5]);
    hold on;

    % Shaded area for x(t - tau)*h(tau)
    patch( ...
        [tau(1:end-1); tau(1:end-1); tau(2:end); tau(2:end)], ...
        [zeros(1, lxh-1); xh(1:end-1); xh(2:end); zeros(1, lxh-1)], ...
        [0.8 0.8 0.8], ...
        'edgecolor', 'none' ...
    );
    hold off;

    xlabel('\tau');
    title('h(\tau) [solid], x(t-\tau) [dashed], h(\tau)x(t-\tau) [grey]');

    % Make sure the curves draw on top of the patch
    c = get(gca, 'children');
    set(gca, 'children', [c(2); c(3); c(4); c(1)]);

    % --- Bottom subplot: y(t) building up over time ---
    subplot(2,1,2);
    plot(tvec, y, 'k', tvec(ti), y(ti), 'ok');
    title('y(t) Time Domain (Convolution)');
    xlabel('t');
    axis([tau(1) tau(end) -1 15]);
    grid on;

    drawnow;
end

%% Frequency-domain reconstruction z(t) from Z(f) via IFFT

zf = ifft(Zf);       % inverse FFT of Z(f) from Code 2
figure;
plot(1:length(zf), zf, 'k');
axis([-5 25 -0.1 10.1]);
xlabel('t (sample index)');
title('z(t) from Frequency Domain (IFFT of Z(f))');
grid on;


%% ------------------------------------------------------------
%% Code 4  Spectra for pulsewidth = 5 and 25
%% ------------------------------------------------------------

% ----- pulsewidth = 5 -----
N = 100;
pulsewidth = 5;

x  = [ones(1, pulsewidth), zeros(1, N - pulsewidth)];
Xf = fft(x);
f  = [-(N/2):1:(N/2)-1] * (1/N);

figure;
subplot(2,1,1);
plot(f, fftshift(abs(Xf)));
grid on;
xlabel('f');
title('Mag. Spectrum, pulsewidth = 5');

subplot(2,1,2);
plot(f, fftshift(angle(Xf)));
grid on;
xlabel('f');
title('Phase Spectrum, pulsewidth = 5');

% ----- pulsewidth = 25 -----
N = 100;
pulsewidth = 25;

x  = [ones(1, pulsewidth), zeros(1, N - pulsewidth)];
Xf = fft(x);
f  = [-(N/2):1:(N/2)-1] * (1/N);

figure;
subplot(2,1,1);
plot(f, fftshift(abs(Xf)));
grid on;
xlabel('f');
title('Mag. Spectrum, pulsewidth = 25');

subplot(2,1,2);
plot(f, fftshift(angle(Xf)));
grid on;
xlabel('f');
title('Phase Spectrum, pulsewidth = 25');


%% ------------------------------------------------------------
%% Code 5  Modulated pulse: w_+(t), w_-(t), w_c(t) spectra
%% ------------------------------------------------------------

N = 100;                 % Number of points
PulseWidth = 10;         % Pulse width
t = 0:1:(N-1);           % Time vector
f = (-N/2:N/2-1) * (1/N);% Frequency vector

% Rectangular pulse
x = [ones(1, PulseWidth), zeros(1, N - PulseWidth)];  % Pulse signal

% Modulated signals
w_positive = x .* exp(1j * (pi/3) * t);   % w_+(t)
W_positive = fftshift(fft(w_positive));   % Fourier transform and shift

w_negative = x .* exp(-1j * (pi/3) * t);  % w_-(t)
W_negative = fftshift(fft(w_negative));

wc = x .* cos((pi/3) * t);                % w_c(t)
W_c = fftshift(fft(wc));

figure;
subplot(3,2,1);
plot(f, abs(W_positive));
title('Magnitude Spectrum of w_+(t)');
xlabel('Frequency');
ylabel('|W_+(f)|');
grid on;

subplot(3,2,2);
plot(f, angle(W_positive));
title('Phase Spectrum of w_+(t)');
xlabel('Frequency');
ylabel('Phase (rad)');
grid on;

subplot(3,2,3);
plot(f, abs(W_negative));
title('Magnitude Spectrum of w_-(t)');
xlabel('Frequency');
ylabel('|W_-(f)|');
grid on;

subplot(3,2,4);
plot(f, angle(W_negative));
title('Phase Spectrum of w_-(t)');
xlabel('Frequency');
ylabel('Phase (rad)');
grid on;

subplot(3,2,5);
plot(f, abs(W_c));
title('Magnitude Spectrum of w_c(t)');
xlabel('Frequency');
ylabel('|W_c(f)|');
grid on;

subplot(3,2,6);
plot(f, angle(W_c));
title('Phase Spectrum of w_c(t)');
xlabel('Frequency');
ylabel('Phase (rad)');
grid on;


%% ------------------------------------------------------------
%% Code 6  Speech signal through LPFs and channel (Lab4_Data)
%% ------------------------------------------------------------

% Assumes Lab4_Data.mat is in the current folder or MATLAB path
% and contains: xspeech, hLPF2000, hLPF2500, hChannel, Fs, and MagSpect()

load('Lab4_Data.mat');

% Analyze the magnitude spectrum of xspeech
figure;
MagSpect(xspeech); 
title('Magnitude Spectrum of xSpeech');

% Analyze the magnitude of filters and channel
figure;
MagSpect(hLPF2000);      % Low-pass filter 2000 Hz
title('Magnitude Spectrum of hLPF2000');

figure;
MagSpect(hLPF2500);      % Low-pass filter 2500 Hz
title('Magnitude Spectrum of hLPF2500');

figure;
MagSpect(hChannel);      % Communication channel
title('Magnitude Spectrum of hChannel');

% Encoder: Pass xspeech through low-pass filter and channel
filtered_signal = conv(xspeech, hLPF2000, 'same');   % Apply LPF2000
encoded_signal  = conv(filtered_signal, hChannel, 'same'); % Through channel

figure;
MagSpect(encoded_signal); 
title('Magnitude Spectrum of Encoded Signal');

% Listen to encoded signal
sound(encoded_signal, Fs);

% Decoder: Pass encoded signal through channel & decoder filter
decoded_signal   = conv(encoded_signal, hChannel, 'same');   % Channel again
recovered_signal = conv(decoded_signal, hLPF2500, 'same');   % Apply LPF2500

figure;
MagSpect(recovered_signal); 
title('Magnitude Spectrum of Recovered Signal');

% Listen to recovered speech
sound(recovered_signal, Fs);
