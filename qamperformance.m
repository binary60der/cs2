clear all; clc;
N = 100000; 
EbN0dB = -4:5:24; 
M = 64; 
g = 0.9; phi = 8; dc_i = 1.9; dc_q = 1.7; 

k = log2(M); 
EsN0dB = 10 * log10(k) + EbN0dB; 
SER1 = zeros(length(EsN0dB), 1); 
SER2 = SER1; 
SER3 = SER1; 
SER4 = SER1; 

d = ceil(M .* rand(1, N)); 
[s, ref] = mqam_modulator(M, d); 

for i = 1:length(EsN0dB)
    r = add_awgn_noise(s, EsN0dB(i));
    z = receiver_impairments(r, g, phi, dc_i, dc_q); 
    v = dc_compensation(z);
    y3 = blind_iq_compensation(v); 
    [Kest, Pest] = pilot_iq_imb_est(g, phi, dc_i, dc_q); 
    y4 = iqImb_compensation(v, Kest, Pest); 


    [estTxSymbols_1, dcap_1] = iqOptDetector(z, ref); 
    [estTxSymbols_2, dcap_2] = iqOptDetector(v, ref); 
    [estTxSymbols_3, dcap_3] = iqOptDetector(y3, ref); 
    [estTxSymbols_4, dcap_4] = iqOptDetector(y4, ref); 

  
    SER1(i) = sum(d ~= dcap_1) / N; 
    SER2(i) = sum(d ~= dcap_2) / N;
    SER3(i) = sum(d ~= dcap_3) / N; 
    SER4(i) = sum(d ~= dcap_4) / N;
end

theoreticalSER = ser_awgn(EbN0dB, 'MQAM', M); 
figure(2); semilogy(EbN0dB, SER1, 'r*-'); 
hold on;
semilogy(EbN0dB, SER2, 'bO-'); semilogy(EbN0dB, SER3, 'g^-');
semilogy(EbN0dB, SER4, 'm*-'); semilogy(EbN0dB, theoreticalSER, 'k');
legend('No compensation', 'DC comp only', 'Sim- DC & blind iq comp', 'Sim- DC & pilot iq comp', 'Theoretical');
xlabel('E_b/N_0 (dB)'); ylabel('Symbol Error Rate (Ps)');
title('Probability of Symbol Error 64-QAM signals');
