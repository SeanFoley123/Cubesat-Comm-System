%%%%Modem Receiver
function decode
carrier = 600;                      %Hz
Fs = 16384;                          %Samples/second
lTx = .0625;                          %Length of each transmission in seconds
params = [carrier, Fs, lTx];
signal = RecordSound(5, params);
plot(signal)
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

%Cosine Function
doublecosine = cosfunction(transmission, params);

%Low Pass to find Original Signal
originalsignal = low_pass(doublecosine, carrier, params);

%Now to convert back to binary bits
binary = CT2DT(originalsignal, Fs);

%Decoding back to words
message = '';
for a=1:8:length(binary)
    message = strcat(message, BitsToStrings(binary(a:a+8)));
end    
disp(message);

%Plotting
f1 = linspace(1, length(signal), length(signal));
f2 = linspace(1, length(bandpassed), length(bandpassed));

subplot(2,1,1)
% plot(f1, abs(fftshift(fft(signal))))
plot(f1, signal);

% axis([-.9, .9, 0, inf])
subplot(2,1,2)
% plot(f2, abs(fftshift(fft(bandpassed))))
plot(f2, bandpassed);

% axis([-.9, .9, 0, inf])
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
    cutoff = .003;                         %Amplitude where we decide it's a new signal! Woohoo!
    for i = 1:length(signal)
        if signal(i) > cutoff && i > 500
            t0 = i;
            break
        end

    end
end


function tend = find_end(signal, ~)    %Finds the time when the cos wave is first heard.
    cutoff = .003;                         %Amplitude where we decide it's a new signal! Woohoo!
    for k = length(signal):-1:1
        if signal(k) > cutoff && k < 50000
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


function res = CT2DT(signal, Fs)
    signallength = length(signal);
    DT = zeros([1 (signallength/(Fs/16))]);
    for j=1:(Fs/16):length(signal)
        if signal(j) == 1
            DT(j) = 0;
        else
            DT(j) = 1;
        end
    end
    
    res = DT;
end


function res = BitsToStrings(binary)
    character = num2str(binary); %turns the binary number into a string
    string = char(bin2dec(character)); %turns it back into ascii
    res = string;
end
            