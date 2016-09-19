%%%%Modem Transmitter

function ModemTransmitter

% word = input('please enter a word\n\n','s');
word = char('hello');

wordinbits = StringToBits(word);


[wordlength,~] = size(wordinbits);

binary = '';
for i=1:wordlength
    binary = strcat(binary, wordinbits(i,:));
end
disp(binary);
Fs = 16384;     %Samples per second


CTBits = DT2CT(binary, Fs);

%Cosine Function
Omega = 600*Fs/(2*pi);
n = 1:length(CTBits);
wc = cos(Omega*n);

result = wc .* CTBits;

sound(result, Fs);

x = linspace(-pi,pi, length(result));
plot(x, fftshift(abs(fft(result))));


function res = StringToBits(string)
    res=dec2bin(string, 8);

end


function res = DT2CT(binary, Fs)
    binarylength = length(binary);
    CT = zeros([1 (Fs/16* binarylength)]);
    binary_count = 1;
    CT_count = 1;
    for k=1:length(CT)
        if CT_count <= Fs/16
            if binary(binary_count) == '0';
                CT(k) = -1;
            else
                CT(k) = 1;
            end
            CT_count = CT_count + 1;
        else
            CT_count = 1;
            binary_count = binary_count + 1;
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


end