clc
clear all
close all

% STFT
[data,fs]=audioread('Counting-16-44p1-mono-15secs.wav') 
% data = 46797x1 double
% fs = 16000
d = seconds(16*10e-3);
stft(data,d,'Window',hamming(256),'OverlapLength',128,'FFTLength',256);
 
% Energy Detection 

clc
 clear all

afr = dsp.AudioFileReader('Counting-16-44p1-mono-15secs.wav');
fs = afr.SampleRate;

frameSize = ceil(20e-3*fs);
overlapSize = ceil(0.75*frameSize);
hopSize = frameSize - overlapSize;
afr.SamplesPerFrame = hopSize;

stft((afr),fs,'Window',kaiser(256,5),'OverlapLength',220,'FFTLength',512);

inputBuffer = dsp.AsyncBuffer('Capacity',frameSize);

VAD = voiceActivityDetector('FFTLength',1024);

scope = timescope('NumInputPorts',2, ...
    'SampleRate',fs, ...
    'TimeSpanSource','Property','TimeSpan',3, ...
    'BufferLength',3*fs, ...
    'YLimits',[-1.5,1.5], ...
    'TimeSpanOverrunAction','Scroll', ...
    'ShowLegend',true, ...
    'ChannelNames',{'Audio','Probability of speech presence'});

player = audioDeviceWriter('SampleRate',fs);

pHold = ones(hopSize,1);

while ~isDone(afr)
    x = afr();
    n = write(inputBuffer,x);

    overlappedInput = read(inputBuffer,frameSize,overlapSize);

    p = VAD(overlappedInput);

    pHold(end) = p;
    scope(x,pHold)

    player(x);

    pHold(:) = p;
end

% SNR1=snr(x)


% 

afr = dsp.AudioFileReader('Counting-16-44p1-mono-15secs.wav');
fs = afr.SampleRate;

frameSize = ceil(10e-3*fs);
overlapSize = ceil(0.25*frameSize);
hopSize = frameSize - overlapSize;
afr.SamplesPerFrame = hopSize;

inputBuffer = dsp.AsyncBuffer('Capacity',frameSize);

VAD = voiceActivityDetector('FFTLength',1024);

scope = timescope('NumInputPorts',2, ...
    'SampleRate',fs, ...
    'TimeSpanSource','Property','TimeSpan',3, ...
    'BufferLength',3*fs, ...
    'YLimits',[-1.5,1.5], ...
    'TimeSpanOverrunAction','Scroll', ...
    'ShowLegend',true, ...
    'ChannelNames',{'Audio','Probability of speech presence'});

player = audioDeviceWriter('SampleRate',fs);

pHold = ones(hopSize,1);

while ~isDone(afr)
    x = afr();
    n = write(inputBuffer,x);

    overlappedInput = read(inputBuffer,frameSize,overlapSize);

    p = VAD(overlappedInput);

    pHold(end) = p;
    scope(x,pHold)

    player(x);

    pHold(:) = p;
end

