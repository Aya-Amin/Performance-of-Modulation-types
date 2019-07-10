clear all
%5-Generate signal
x = randi([0 1],1,1e6);                          %Vector of rand values, of size 1*e6

%6-Modulate the signal
ook = x;

prk = zeros(1,1e6);
for i = 1:length(x)
    prk(i) = 2*x(i) - 1;
end

fsk = zeros(1,1e6);
for i = 1:length(x)
    if (x(i) == 0);
        fsk(i) = 1;
    else
        fsk(i) = 0 + 1*j;
    end      
end
    %Getting phase of each symbol in modulated signal
fskPhase = angle(fsk)*180/pi; 

qam = qammod(x,16,0);

%7-Apply noise to bits
ookBER = [];
prkBER = [];
fskBER = [];
qamBER = [];
SNR = [0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
for snr = 0:2:30
    ookNoisy = awgn(ook, snr, 'measured');
    prkNoisy = awgn(prk, snr, 'measured');
    fskNoisy = awgn(fsk, snr, 'measured');
        %Add noise to phase of fsk
    fskPhaseNoisy = angle(fskNoisy)*180/pi; 
    qamNoisy = awgn(qam, snr, 'measured');
    
    %declare empty arrays
    ookReceived = zeros(1,1e6);
    prkReceived = zeros(1,1e6);
%     fskReceived = zeros(1,1e6);
    fskPhaseReceived = zeros(1,1e6);
    
    %8-compare noisy signal to threshold value to determine received signal
    for i = 1:length(x)
        
        if ookNoisy(i) > 0.5                   %OOK values are 0's & 1's, hence chosen threshold is 0.5
            ookReceived(i) = 1;
        else 
            ookReceived(i) = 0; 
        end 
        
        if prkNoisy(i) > 0                     %PRK values are -1's & 1's, hence chosen threshold is 0
            prkReceived(i) = 1;
        else 
            prkReceived(i) = -1; 
        end 
        
%         if isreal(fskNoisy(i))                   %FSK values are 1's & j's(imaginary), hence chosen indicator is whether the value is imaginary or not
%             fskReceived(i) = 1;
%         else 
%             fskReceived(i) = 0 + 1*j; 
%         end 
        if fskPhaseNoisy(i) > 45
            fskPhaseReceived(i) = 90;
        else
            fskPhaseReceived(i) = 0;
        end            
    end 
    
    qamReceived = qamdemod(qamNoisy,16,0);
    
    %9,10-compute BER for each modulation type
    [number, ratio] = biterr(ook, ookReceived, [], 'overall');
    ookBER = [ookBER ratio];
    
    errors = 0;
    for k = 1:length(prk)
        if prkReceived(k) ~=  prk(k);
            errors = errors + 1;
        end
    end
    ratio = errors/length(prk);
    prkBER = [prkBER ratio]; 
    
    errors = 0;
    for k = 1:length(fskPhase)
%         if isreal(fskReceived(k)) ~=  isreal(fsk(k));
%             errors = errors + 1;
%         end
        if fskPhaseReceived(k) ~= fskPhase(k)
            errors = errors + 1;
        end
    end
    ratio = errors/length(fskPhase);
    fskBER = [fskBER ratio]; 
    
    [number, ratio] = biterr(x,qamReceived); 
    qamBER = [qamBER ratio];
end

%11-Plot the BER curve against SNR
figure;
semilogy(SNR, ookBER);
title('BER for OOK modulation');

figure;
semilogy(SNR, prkBER);
title('BER for PRK modulation');

figure;
semilogy(SNR, fskBER);
title('BER for FSK modulation');

figure;
semilogy(SNR, qamBER);
title('BER for 16QAM modulation');

    %All on 1 plot
figure;
semilogy(SNR, ookBER, 'r');
hold on;
semilogy(SNR, prkBER, 'g');
hold on;
semilogy(SNR, fskBER, 'b');
hold on;
semilogy(SNR, qamBER, 'm');
legend('OOK', 'PRK', 'FSK', '16QAM');
hold off;

% %Compare to matlab built-in functions
% pam = pammod(x,2);                                  
% psk = pskmod(x,2);                               
% %y3 =
% 
% pamBER = [];
% pskBER = [];
% SNR = [0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
% for snr = 0:2:30
%     pamNoisy = awgn(pam, snr, 'measured');
%     pskNoisy = awgn(psk, snr, 'measured');
%     
%     pamReceived = pamdemod(pamNoisy,2);
%     pskReceived = pskdemod(pskNoisy,2);
%     
%     pamTH = (max(pam) - min(pam)) / 2;
%     pskTH = (max(psk) - min(psk)) / 2;
%     
%     pamReceived_TH = zeros(1,1e6);
%     pskReceived_TH = zeros(1,1e6);
% 
%     for i = 1:length(x)
%         
%         if pamReceived(i) > pamTH                  
%             pamReceived_TH(i) = max(pam);
%         else 
%             pamReceived_TH(i) = min(pam); 
%         end 
%         
%         if pskReceived(i) > pskTH                  
%             pskReceived_TH(i) = max(psk);
%         else 
%             pskReceived_TH(i) = min(psk); 
%         end 
%     end 
%     
%     [number, ratio] = biterr(pam, pamReceived, [], 'overall');
%     pamBER = [pamBER ratio];
%     
%     [number, ratio] = biterr(psk, pskReceived, [], 'overall');
%     pskBER = [pskBER ratio];  
% end
% 
% figure;
% semilogy(SNR, pamBER, 'r');
% hold on;
% semilogy(SNR, ookBER, 'b');
% title('Comparison between BERs of built-in & implemented PAM');
% legend('PAM','OOK');
% hold off;
% 
% figure;
% semilogy(SNR, pskBER, 'r');
% hold on;
% semilogy(SNR, prkBER, 'b');
% title('Comparison between BERs of built-in & implemented PSK');
% legend('PSK','PRK');
% hold off;
