%% FPGA project phase 3
clear;
clc;

input_image = imread('my_pic.jpg');


r = input_image(:,:,1);
g = input_image(:,:,2);
b = input_image(:,:,3);
file_id = fopen ('rgb1color.txt', 'w'); 


for i=1:200 
   for j=1:160
       rv = r(i,j) > 127;
       gv = g(i,j) > 127;
       bv = b(i,j) > 127;
       numToWrite = [rv, gv, bv, 0];
       packet = crc_encoder(numToWrite);
       t = 7:-1:0;
       x = sum(packet .* (2.^t));
       formatSpec = '%c%c ';
       fprintf(file_id, formatSpec, dec2hex(x,2)); %or * 16
   end
       fprintf(file_id ,'\n');

end




