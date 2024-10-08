
M = 2; 
numBits = 1e3; 
chipRate = 10; 
snr = 10; 
fs = 1000; 

dataBits = randi([0 1], numBits, 1);

modulatedData = 2*dataBits - 1; 

pnSequence = randi([0 1], numBits*chipRate, 1);
pnSequence = 2*pnSequence - 1; 

spreadSignal = repelem(modulatedData, chipRate) .* pnSequence;

receivedSignal = awgn(spreadSignal, snr, 'measured');

despreadSignal = receivedSignal .* pnSequence;
despreadBits = sum(reshape(despreadSignal, chipRate, numBits), 1)' / chipRate;

receivedBits = despreadBits > 0;

BER_DSSS = sum(dataBits ~= receivedBits) / numBits;

n = length(spreadSignal);
frequencies = (-n/2:n/2-1)*(fs/n);

messageSpectrum = fftshift(fft(modulatedData, n));

pnSpectrum = fftshift(fft(pnSequence, n));

spreadSignalSpectrum = fftshift(fft(spreadSignal, n));

receivedSignalSpectrum = fftshift(fft(receivedSignal, n));

despreadSignalSpectrum = fftshift(fft(despreadSignal, n));

figure;

subplot(3,2,1);
plot(frequencies, abs(messageSpectrum));
title('Message Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

subplot(3,2,2);
plot(frequencies, abs(pnSpectrum));
title('PN Code Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

subplot(3,2,3);
plot(frequencies, abs(spreadSignalSpectrum));
title('Spread Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

subplot(3,2,4);
plot(frequencies, abs(receivedSignalSpectrum));
title('Received Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

subplot(3,2,5);
plot(frequencies, abs(despreadSignalSpectrum));
title('Despread Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

demodulatedSignalSpectrum = fftshift(fft(despreadBits, n));
subplot(3,2,6);
plot(frequencies, abs(demodulatedSignalSpectrum));
title('Demodulated Signal Spectrum (Before Decision Device)');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;
fprintf('DSSS BER: %e\n', BER_DSSS);
