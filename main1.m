clc
clear all
close all
addpath('support')
% Transient Detection from Audio

% 1. STFT 
[data,fs]=audioread('Counting-16-44p1-mono-15secs.wav') ;
% data = 46797x1 double
% fs = 16000
d = seconds(16*10e-3);
stft(data,d,'Window',hamming(256),'OverlapLength',128,'FFTLength',256);

PSNR=psnr(data,data*0.999)

% 2. Energy Detection 

clear all
fileReader = dsp.AudioFileReader('Counting-16-44p1-mono-15secs.wav');
fs = fileReader.SampleRate;
fileReader.SamplesPerFrame = ceil(10e-3*fs);
addpath('support')
VAD = voiceActivityDetector;

scope = timescope( ...
    'NumInputPorts',2, ...
    'SampleRate',fs, ...
    'TimeSpanSource','Property','TimeSpan',3, ...
    'BufferLength',3*fs, ...
    'YLimits',[-1.5 1.5], ...
    'TimeSpanOverrunAction','Scroll', ...
    'ShowLegend',true, ...
    'ChannelNames',{'Audio','Probability of speech presence'});
deviceWriter = audioDeviceWriter('SampleRate',fs);

while ~isDone(fileReader)
    audioIn = fileReader();
    probability = VAD(audioIn);
    scope(audioIn,probability*ones(fileReader.SamplesPerFrame,1))
    deviceWriter(audioIn);
end

%%%% 3. Features Extraction 
clc 
clear all

fileReader = dsp.AudioFileReader('Counting-16-44p1-mono-15secs.wav');
fs = fileReader.SampleRate;

samplesPerFrame = ceil(0.03*fs);
samplesPerHop = ceil(0.01*fs);
samplesPerOverlap = samplesPerFrame - samplesPerHop;

fileReader.SamplesPerFrame = samplesPerHop;
buffer = dsp.AsyncBuffer;

% voiceActivityDetector System
VAD = voiceActivityDetector('InputDomain','Frequency');
cepFeatures = cepstralFeatureExtractor('InputDomain','Frequency','SampleRate',fs,'LogEnergy','Replace');
sink = dsp.SignalSink;

% audio stream loop
threshold = 0.75;
nanVector = nan(1,13);
while ~isDone(fileReader)
    audioIn = fileReader();
    write(buffer,audioIn);
    
    overlappedAudio = read(buffer,samplesPerFrame,samplesPerOverlap);
    X = fft(overlappedAudio,2048);
    
    probabilityOfSpeech = VAD(X);
    if probabilityOfSpeech > threshold
        xFeatures = cepFeatures(X);
        sink(xFeatures')
    else
        sink(nanVector)
    end
end
figure,
% Visualize the cepstral coefficients over time.
timeVector = linspace(0,15,size(sink.Buffer,1));
plot(timeVector,sink.Buffer)
xlabel('Time (s)')
ylabel('MFCC Amplitude')
legend('Log-Energy','c1','c2','c3','c4','c5','c6','c7','c8','c9','c10','c11','c12')


% parameters calculation

[accuracy loss]=accuracy_score(probabilityOfSpeech)
