%%%%Modem Transmitter

function ModemTransmitter

%setting up parameters
carrier = 600;  %Frequency in Hz of carrier wave
Fs = 16384;     %Samples per second
params = [carrier, Fs];


%Getting input word

word = input('please enter a word\n\n','s');
% word = char('hello');


%Converts from word to binary bits
binary = StringToBits(word);

for i=1:8:length(binary)-7
disp(binary(i:i+7));
end
disp(length(binary));

%Convert from binary function to a "continuous" signal
CTBits = DT2CT(binary, Fs);
plot(CTBits)

%Cosine Function
result = cosfunction(CTBits, params);


%Play sound
sound(result, Fs);


%Plotting

% plot(result)

% x = linspace(-pi,pi, length(result));
% plot(x, fftshift(abs(fft(result))));
end




function res = StringToBits(string)        %Convert each ascii letter into an 8bit binary string, then stick them together
    res = '';
    for i = 1:length(string)
        res=strcat(res, dec2bin(string(i), 8));
    end

end

function res = cosfunction(CTsignal, params)
    Omega = params(1)*(2*pi)/params(2);                  %Convert Hz to radians/sample
    n = 1:length(CTsignal);                   %Cos signal lasts length of data signal, wich is #bits*16 seconds
    wc = cos(Omega*n);

    res = wc .* CTsignal;
end


function res = DT2CT(binary, Fs)
    binarylength = length(binary);
    length_bit = Fs/16;
    CT = zeros([1 (length_bit* binarylength)]);
    binary_count = 1;
    CT_count = 1;
    for k=1:length(CT)
        if CT_count <= length_bit
            if binary(binary_count) == '0';
                CT(k) = -1;
            else
                CT(k) = 1;
            end
            CT_count = CT_count + 1;
        else
            CT_count = 1;
            binary_count = binary_count + 1;
            %still need to add in a value because the for loop still increments in this conditional
            if binary(binary_count) == '0';  
                CT(k) = -1;
            else
                CT(k) = 1;
            end
            CT_count = CT_count + 1;
        end
    end
    
    res = CT;
end
