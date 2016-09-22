%%%%Modem Receiver
function decode
close all
% about_how_long = 15;
carrier = 600;                      %Hz
Fs = 16384;                          %Samples/second
lTx = .0625;                          %Length of each transmission in seconds
params = [carrier, Fs, lTx];
signal = RecordSound(6, params);
plot(signal)
figure
max(signal)

%Used to find start of signal, then discarded
bandpassed = band_pass(signal, carrier, params);  
max(bandpassed)

%Find the point where the actual transmission begins
t0 = find_start(bandpassed, params);  
disp(t0);

%Find the point where the actual transmission ends
tend = find_end(bandpassed, params);  
disp(tend);

%Cut off at the starting and stopping points of message
transmission = signal(t0:tend);  
plot(transmission)
%Cosine Function
doublecosine = cosfunction(transmission, params);
figure
plot(doublecosine)

%Low Pass to find Original Signal
originalsignal = low_pass(doublecosine, carrier, params);
% 
figure
plot(originalsignal)

%Now to convert back to binary bits
binary = CT2DT(originalsignal, params);

for i = 1:8:length(binary)-7
    disp(binary(i:i+7))
end
disp(length(binary))

%Decoding back to words
message = '';
for a=1:8:length(binary)-7
    message = strcat(message, BitsToStrings(binary(a:a+7)));
end    
disp(message);
end

%Functions

function res = RecordSound(time, params)
    recObj = audiorecorder(params(2), 8, 1);
    disp('Begin Recording.')
    recordblocking(recObj, time);
    disp('End of Recording.');
    play(recObj);
    res = getaudiodata(recObj);
end


function t0 = find_start(signal, ~)    %Finds the time when the cos wave is first heard.
    cutoff = .03;                         %Amplitude where we decide it's a new signal! Woohoo!
    for i = 1:length(signal)
        if signal(i) > cutoff && i > 500
            t0 = i;
            break
        end

    end
end


function tend = find_end(signal, ~)    %Finds the time when the cos wave is first heard.
    cutoff = .03;                         %Amplitude where we decide it's a new signal! Woohoo!
    for k = length(signal):-1:1
        if signal(k) > cutoff && k < 500000
            tend = k;
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
%     kroneckerDelta = @(n) n==0;                         %A function for delta
    wc = freq*2*pi/Fs;
    n = -42:41;
%     h = kroneckerDelta(n) -  wc/pi*sinc(wc*n/pi);
    h = -wc/pi*sinc(wc*n/pi);
    h(43) = h(43) + 1;
    filtered = conv(signal, h);
    
end


function filtered = band_pass(signal, freq, params)     %Returns a bandpasses signal w/passband of 40 Hz

low_passed = low_pass(signal, freq + 50, params);
filtered = high_pass(low_passed, freq - 50, params);

end


function res = cosfunction(transmission, params)
    Omega = params(1)*(2*pi)/params(2);                  %Convert Hz to radians/sample
    n = 1:length(transmission);                   %Cos signal lasts length of data signal, wich is #bits*16 seconds
    wc = cos(Omega*n);

    res = wc' .* transmission;
end


function bits = CT2DT(signal, params)
    signal_length = length(signal);
    length_bit = params(2)*params(3);
    current_samp = length_bit/2;
    bits = [];
    while current_samp < signal_length
        average = mean(signal(current_samp - length_bit/4:current_samp - length_bit/4));
        bits = [bits, average<0];
        current_samp = current_samp + length_bit;
    end
end


function res = BitsToStrings(binary)
    character = num2str(binary); %turns the binary number into a string
    string = char(bin2dec(character)); %turns it back into ascii
    res = string;
end
            