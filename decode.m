%%%%Modem Receiver

function decode

carrier = 600;                      %Hz
Fs = 16384;                          %Samples/second
lTx = .0625;                          %Length of each transmission in seconds
params = [carrier, Fs, lTx];
signal = RecordSound(5, params);
max(signal)
bandpassed = band_pass(signal, carrier, params);   %Used to find start of signal, then discarded
t0 = find_start(bandpassed, params);  %Find the point where the actual transmission begins
subplot(211)
plot(abs(fftshift(fft(signal))))
subplot(212)
plot(abs(fftshift(fft(bandpassed))))




function res = RecordSound(time, params)
recObj = audiorecorder(params(2), 8, 1);
disp('Begin Recording.')
recordblocking(recObj, time);
disp('End of Recording.');
play(recObj);
res = getaudiodata(recObj);
end

function t0 = find_start(signal, params)    %Finds the time when the cos wave is first heard.
cutoff = .1;                         %Amplitude where we decide it's a new signal! Woohoo!
for i = 1:length(signal)
    if signal(i) > cutoff
        t0 = i;
        break
    end
end
end

function filtered = low_pass(signal, freq, params)      %Low passes signal w/cutoff of freq
Fs = params(2);
wc = freq*2*pi/Fs;
n = -42:41;
h = wc/pi*sinc(wc*n/pi);
filtered = conv(signal, h);
end

function filtered = high_pass(signal, freq, params)     %High passes signal w/cutoff of freq
Fs = params(2);
kroneckerDelta = @(n) n==0;                 %A function for delta
wc = freq*2*pi/Fs;
n = -42:41;
h = kroneckerDelta(n) -  wc/pi*sinc(wc*n/pi);
filtered = conv(signal, h);
end

function filtered = band_pass(signal, freq, params)     %Returns a bandpasses signal w/passband of 40 Hz
low_passed = low_pass(signal, freq + 20, params);
filtered = high_pass(low_passed, freq - 20, params);
end


end