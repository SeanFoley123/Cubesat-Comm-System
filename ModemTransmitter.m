%%%%Modem Transmitter

function ModemTransmitter

% word = input('please enter a word\n\n','s');
word = char('hello');

binary = StringToBits(word);
disp(binary);

Fs = 16384;     %Samples per second

CTBits = DT2CT(binary, Fs);

%Cosine Function
Omega = 600*(2*pi)/Fs;                  %Convert Hz to radians/sample
n = 1:length(CTBits);                   %Cos signal lasts length of data signal, wich is #bits*16 seconds
wc = cos(Omega*n);

result = wc .* CTBits;

sound(result, Fs);

plot(result)

% x = linspace(-pi,pi, length(result));
% plot(x, fftshift(abs(fft(result))));
end

function res = StringToBits(string)        %Convert each ascii letter into an 8bit binary string, then stick them together
    res = '';
    for i = 1:length(string)
        res=strcat(res, dec2bin(string(i), 8));
    end

end





function res = DT2CT(binary, Fs)
    binarylength = length(binary);
    CT = zeros([1 (Fs/16* binarylength)]);
    binary_count = 1;
    CT_count = 1;
    for k=1:length(CT)
        if CT_count <= Fs/16
            if binary(binary_count) == '0';
                CT(k) = 1;
            else
                CT(k) = 2;
            end
            CT_count = CT_count + 1;
        else
            CT_count = 1;
            binary_count = binary_count + 1;
            %still need to add in a value because the for loop still increments in this conditional
            if binary(binary_count) == '0';  
                CT(k) = 1;
            else
                CT(k) = 2;
            end
            CT_count = CT_count + 1;
        end
    end
    
    res = CT;
end
