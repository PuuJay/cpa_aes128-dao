dbstop if error
clear all
cleanupObj = onCleanup(@cleanMeUp);

rng shuffle
%%rng(1);
%addpath(genpath('./utils'));
%addpath(genpath('./bin2hex'));
%addpath(genpath('./textprogressbar'));

format long;
if ~isempty(instrfind)
     fclose(instrfind);
      delete(instrfind);
end
% Prepare Lecroy
init_LeCroy;
no_Test = 1000
% Generate 128-bit (16 bytes) Plaintext
myComPort = serial('COM7','BaudRate',9600,'Timeout',200); %4800 %921600 460800 115200
fopen(myComPort);
fprintf('Loading Success!\n\nBegin test!\n----------------\n');
Test =0;
Key = '00112233445566778899AABBCCDDEEFF';
for n =1: no_Test
    Plaintext = dec2hex(randi([0 15],1,32)).';
    expCipher = Cipher(Key,Plaintext);
    fprintf('I=%d\n',n)
    Inputs(n) = hex2dec(Plaintext(1:2));      
    % Send PT
    for k = 1:length(Plaintext)/2
        sendbyte = Plaintext((2*k-1):(2*k));
        x=uint8(hex2dec(sendbyte));
        fwrite(myComPort,x,'uint8');
    end
        acquire_LeCroy_scope_data
        traces_Y(n,:)= Y;  % Add another traces(n,:)=Y
        traces_T(n,:)= T;
    cipher_2x16 = dec2hex(fread(myComPort,16,'uint8')).';
    cipher=lower(cipher_2x16(:)');
    if (expCipher == cipher)
        disp('OK!');
        Test= Test + 1;
    end
end
WrongTest =no_Test-Test;
fprintf('Closing the Port ...\n...\n');
fclose(myComPort);
disp('Completed!!')
disp('------------')
fprintf('Summarization:\nTotal test: 1000\nTotal correct cases: %d\nTotal wrong cases: %d\n', Test,WrongTest)

save('Input.mat', 'Inputs', 'traces_Y') 
