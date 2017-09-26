function [] = SGA__suspension_skyhook_replot()
% /*M-FILE Script SGA__suspension_skyhook_replot MMM SGALAB */
% /*==================================================================================================
%  Simple Genetic Algorithm Laboratory Toolbox for Matlab 7.x
%
%  Copyright 2007 The SxLAB Family - Yi Chen - leo.chen.yi@gmail.com
% ====================================================================================================
%File description:
%       To replot the data in workspace, which from
%       SGA__suspension_skyhook_quarter.mdl
% 
%===================================================================================================
%  See Also:   SGA__suspension_skyhook_replot
%              SGA__suspension_flc_replot
%===================================================================================================
%
%===================================================================================================
%Revision -
%Date              Name    Description of Change  email                 Location
%10-Jan-2007       Yi Chen Initial version        leo.chen.yi@gmail.com Glasgow
%HISTORY$
%==================================================================================================*/

% SGA__suspension_skyhook_replot Begin

%clear
home
close('all');

%set parameters
Fs = 1000;       % Sampling frequency
% t = (0:Fs)/Fs; % One second worth of samples
nfft= 512;
window = hanning(nfft);
noverlap=256;
dflag='none';


%load data from mat file
load('SGA__suspension_skyhook_quarter.mat');

%set variables according to the order in SGA__suspension_skyhook_quarter.mdl
% mat file always have simulation time as the first line
time                             = SGA__suspension_skyhook_quarter(1,:);

semi_acc                         = SGA__suspension_skyhook_quarter(2,:);
passive_acc                      = SGA__suspension_skyhook_quarter(3,:);

semi_tyre_load                   = SGA__suspension_skyhook_quarter(4,:);
passive_tyre_load                = SGA__suspension_skyhook_quarter(5,:);

semi_suspension_distorsion       = SGA__suspension_skyhook_quarter(6,:);
passive_suspension_distorsion    = SGA__suspension_skyhook_quarter(7,:);

road_displacement                = SGA__suspension_skyhook_quarter(8,:);
% pre data handling 
array_size =size( semi_acc , 2 );
% 
% for idx = 1 : 1 : array_size
%     
%     semi_acc_std(idx)     =  std(semi_acc(1:1:idx));
%     passive_acc_std(idx) = std(passive_acc(1:1:idx));
%     
% end

% plot time domain data
% body acc
figure
hold on
% grid on
plot(time,semi_acc,'b',time,passive_acc,'k:');
xlabel('time ( sec.)');
ylabel('body acceleration ( m/sec^2)');
title('1/4 vehicle suspension system body acceleration');
legend('semi-active','passive');

[ acc_reduce_percentage , acc_ave_reduce_percentage ] = average_reduce_data( semi_acc, passive_acc);

figure
hold on
% grid on
plot(time,acc_reduce_percentage,'b',time,acc_ave_reduce_percentage,'k:');
xlabel('time ( sec.)');
ylabel('reduce % ');
title('1/4 vehicle suspension system percentage of body acceleration reduce');
legend('percentage','average percentage');

% tyre loads
figure
hold on
% grid on
plot(time,semi_tyre_load,'b',time,passive_tyre_load,'k:');
xlabel('time ( sec.)');
ylabel('tyre loads( N)');
title('1/4 vehicle suspension system tyre loads');
legend('semi-active','passive');

[ tyre_load_reduce_percentage , tyre_load_ave_reduce_percentage ] = average_reduce_data( semi_tyre_load, passive_tyre_load);

figure
hold on
% grid on
plot(time,tyre_load_reduce_percentage,'b',time,tyre_load_ave_reduce_percentage,'k:');
xlabel('time ( sec.)');
ylabel('reduce % ');
title('1/4 vehicle suspension system percentage of tyre loads reduce');
legend('percentage','average percentage');

%suspension distorsion
figure
hold on
% grid on
plot(time,semi_suspension_distorsion,'b',time,passive_suspension_distorsion,'k:');
xlabel('time ( sec.)');
ylabel('suspension distorsion(m)');
title('1/4 vehicle suspension system suspension distorsion');
legend('semi-active','passive');


[ distorsion_reduce_percentage , distorsion_ave_reduce_percentage ] = average_reduce_data( semi_suspension_distorsion, passive_suspension_distorsion);

figure
hold on
% grid on
plot(time,distorsion_reduce_percentage,'b',time,distorsion_ave_reduce_percentage,'k:');
xlabel('time ( sec.)');
ylabel('reduce % ');
title('1/4 vehicle suspension system percentage of suspension distorsion reduce');
legend('percentage','average percentage');


% plot frequency domain graphs
% figure
% hold on
% grid on
% 
% singles=ones(array_size,1);
% 
% [FFT_acc_semi,ft]=tfe(singles,semi_acc,nfft,Fs,window,noverlap,dflag);
% [FFT_acc_passive,ft]=tfe(singles,passive_acc,nfft,Fs,window,noverlap,dflag);
% loglog(ft,abs(FFT_acc_passive),':r',ft,abs(FFT_acc_semi),'b');
% xlabel('Frequency(Hz.)');
% ylabel('Amplitude(dB.) ');
% legend('passive std','semi std');
%
%Body Acceleration
figure
% [H_acc_pass,ft]=tfe(road_displacement,passive_acc_std,nfft,Fs,window,noverlap,dflag);
% [H_acc_semi,ft]=tfe(road_displacement,semi_acc_std,nfft,Fs,window,noverlap,dflag);
[H_acc_pass,ft]=tfe(road_displacement,passive_acc,nfft,Fs,window,noverlap,dflag);
[H_acc_semi,ft]=tfe(road_displacement,semi_acc,nfft,Fs,window,noverlap,dflag);
loglog(ft,abs(H_acc_pass),':r' ,ft,abs(H_acc_semi),'b');
% grid on
xlabel('frequency(Hz.)');
ylabel('|acceleration/road displacemen|(dB.)');
title('Transformation function of  ''body acceleration / road displacement''');
legend('passive acc','semi acc');

% 
% figure(3)
% loglog(ft,ANGLE(FFT_acc_passive),':r',ft,ANGLE(FFT_acc_semi),'b');
% xlabel('Frequency(Hz.)');
% ylabel('Angle(rad)');
% legend('passive','semi');
% title('Agnel of BodyAcc');
% 
% figure(4)
% loglog(ft,real(FFT_acc_passive),':r',ft,real(FFT_acc_semi),'b');
% xlabel('Frequency(Hz.)');
% ylabel('Re');
% legend('passive','semi');
% title('Re BodyAcc');
% 
% figure(5)
% loglog(ft,imag(FFT_acc_passive),':r',ft,imag(FFT_acc_semi),'b');
% xlabel('Frequency(Hz.)');
% ylabel('Im');
% legend('passive','semi');
% title('Im BodyAcc');

%Tyre load
figure
% [H_acc_pass,ft]=tfe(road_displacement,passive_acc_std,nfft,Fs,window,noverlap,dflag);
% [H_acc_semi,ft]=tfe(road_displacement,semi_acc_std,nfft,Fs,window,noverlap,dflag);
[H_tyreload_pass,ft]=tfe(road_displacement,passive_tyre_load,nfft,Fs,window,noverlap,dflag);
[H_tyreload_semi,ft]=tfe(road_displacement,semi_tyre_load,nfft,Fs,window,noverlap,dflag);
loglog(ft,abs(H_tyreload_pass),':r' ,ft,abs(H_tyreload_semi),'b');
% grid on
xlabel('frequency(Hz.)');
ylabel('|tyre load / road displacemen|(dB.)');
title('Transformation function of  ''tyre load / road displacement''');
legend('passive tyre load','semi tyre load');


semi_suspension_distorsion        = SGA__suspension_skyhook_quarter(6,:);
passive_suspension_distorsion    = SGA__suspension_skyhook_quarter(7,:);
%suspension distorsion
figure
% [H_acc_pass,ft]=tfe(road_displacement,passive_acc_std,nfft,Fs,window,noverlap,dflag);
% [H_acc_semi,ft]=tfe(road_displacement,semi_acc_std,nfft,Fs,window,noverlap,dflag);
[H_suspension_distorsion_pass,ft]=tfe(road_displacement,passive_suspension_distorsion,nfft,Fs,window,noverlap,dflag);
[H_suspension_distorsion_semi,ft]=tfe(road_displacement,semi_suspension_distorsion,nfft,Fs,window,noverlap,dflag);
loglog(ft,abs(H_suspension_distorsion_pass),':r' ,ft,abs(H_suspension_distorsion_semi),'b');
% grid on
xlabel('frequency(Hz.)');
ylabel('|suspension distorsion/road displacemen|(dB.)');
title('Transformation function of  ''suspension distorsion / road displacement''');
legend('passive suspension distorsion','semi suspension distorsion');


home
clear

% SGA__suspension_skyhook_replot End


function  [ reduce_percentage , ave_reduce_percentage ] = average_reduce_data( semi, passive)

MM = size( semi,2);

for idx = 1 : 1 : MM
    
    reduce_percentage(idx)        = (semi(idx)-passive(idx))/passive(idx);
    
    if( isnan(reduce_percentage(idx)) == 1 )
        
        reduce_percentage(idx) = 0.0;
        
    end

end

ave_reduce_percentage = mean(reduce_percentage);
