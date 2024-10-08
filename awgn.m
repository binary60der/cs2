clearvars; clc;

nSym = 10^5; 
EbN0dB = -4:2:14; 
MOD_TYPE = 'PSK'; 
arrayOfM = [2, 4, 8, 16, 32]; 
% arrayOfM=[4,16,64,256]; 
COHERENCE = 'coherent'; 

plotColor = ['b','g','r','c','m','k']; p = 1; 
legendString = cell(1, length(arrayOfM) * 2); 

for M = arrayOfM
    
    k = log2(M); EsN0dB = 10*log10(k) + EbN0dB; 
    SER_sim = zeros(1, length(EbN0dB)); 
    
    d = ceil(M .* rand(1, nSym)); 
    s = modulate(MOD_TYPE, M, d, COHERENCE); 
    
    for i = 1:length(EsN0dB)
        r = add_awgn_noise(s, EsN0dB(i)); 
        dCap = demodulate(MOD_TYPE, M, r, COHERENCE); 
        SER_sim(i) = sum(d ~= dCap) / nSym; 
    end
    
    SER_theory = ser_awgn(EbN0dB, MOD_TYPE, M, COHERENCE); 
    
    semilogy(EbN0dB, SER_sim, [plotColor(p) '*']); 
    hold on;
    semilogy(EbN0dB, SER_theory, plotColor(p));
    
    legendString{2*p-1} = ['Sim ', num2str(M), '-', MOD_TYPE];
    legendString{2*p} = ['Theory ', num2str(M), '-', MOD_TYPE]; p = p + 1;
end


xlim([min(EbN0dB) max(EbN0dB)]);
ylim([1e-6 1]); 

legend(legendString);
xlabel('Eb/N0 (dB)'); ylabel('SER (Ps)');
title(['Probability of Symbol Error for M-', MOD_TYPE, ' over AWGN']);
grid on; 
