function z=vad(data,fs, vadThres,flen_factor, fsh_factor )

% finwav: The input WAVE file path and name.
%
% fs: sampling frequency 
%
% vadThres: The threshold for VAD. The default value is 0.4. Increasing vadThres (e.g. to 0.5) makes the VAD more aggressive, i.e. the number of frames to be detected as speech will be reduced.
%
% flen_factor: frame length factor---> length = floor(fs/flen_factor)
%
% fsh_factor: frame shift factor---> shift = floor(fs/fsh_factor)
%
% Refs:
%  [1] Z.-H. Tan, A.k. Sarkara and N. Dehak, "rVAD: an unsupervised segment-based robust voice activity detection method," Computer Speech and Language, 2019. 
%  [2] Z.-H. Tan and B. Lindberg, "Low-complexity variable frame rate analysis for speech recognition and voice activity detection,â€? IEEE Journal of Selected Topics in Signal Processing, vol. 4, no. 5, pp. 798-807, 2010.


if nargin < 2; error('Usage: vad(finwav, fs)'); end

% Parameter setting
ENERGYFLOOR = exp(-50);
flen=floor(fs/flen_factor);  
fsh=floor(fs/fsh_factor); 
nfr=floor((length(data)-(flen-fsh))/fsh);

b=[0.9770   -0.9770]; a=[ 1.0000   -0.9540];
fdata=filter(b,a,data);

% using flatness 
ftThres = 0.5;  % Default threshold. It can range from 0 to 1. Increasing ftThres increases the number of frames being detected as speech.
[ft]= sflux(data,flen,fsh);
pv01 = (ft <= ftThres);  % <= threshold would give  1( meaning a speech frame)
pitch=ft;

pvblk=pitchblockdetect(pv01, nfr, pitch, 1);

[noise_samp, n_noise_samp, noise_seg]=snre_highenergy(fdata, nfr, flen, fsh, ENERGYFLOOR, pv01);

%% Set high energy segments to zero 
for i=1:n_noise_samp
    fdata(noise_samp(i,1):noise_samp(i,2)) = 0;
end

[dfdatarm]=specsub(fdata,fs);
% [dfdatarm]=specsub(fdata,fs,noise_seg,pv01);

[vad_seg]=snre_vad(dfdatarm, nfr, flen, fsh, ENERGYFLOOR, pv01, pvblk, vadThres);

%% Output VAD results in 0-1 format (1 for speech frames and 0 for non-speech ones) 
if isempty(vad_seg) ==1
   z=zeros(nfr,1);
else
   y=[];
   for i=1:size(vad_seg,1)
       y=[ y ; [ vad_seg(i,1):vad_seg(i,2)]' ];
   end
   z=zeros(nfr,1);
   z([y],1)=1;

   if sum(z) ~= size(y,1) % checking
      error('The number of labeled speech frames does not matched the results of detected speech segments!');
   end
end

