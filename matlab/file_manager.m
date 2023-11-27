%% Create MEM Files of RGB Picture For Verilog
file_id_R = fopen ('picture_R.mem', 'w'); 
file_id_G = fopen ('picture_G.mem', 'w'); 
file_id_B = fopen ('picture_B.mem', 'w'); 

for i = 1:size(input_image, 1) 
	for j = 1:size(input_image, 2) 
        formatSpec = '%c%c ';
        fprintf(file_id_R, formatSpec, dec2hex((input_image(i,j,1)),2));
        fprintf(file_id_G, formatSpec, dec2hex((input_image(i,j,2)),2));
        fprintf(file_id_B, formatSpec, dec2hex((input_image(i,j,3)),2));
    end
    fprintf(file_id_R ,'\n');
    fprintf(file_id_G ,'\n');
    fprintf(file_id_B ,'\n');
end
fclose(file_id_R);
fclose(file_id_G);
fclose(file_id_B);


%% Write Gray File From Verilog In MEM Format
M=dlmread('output.txt');

file_id_Gray = fopen('picture_Gray.mem', 'w'); 

for i = 1:size(input_image, 1) 
	for j = 1:size(input_image, 2) 
        formatSpec = '%c%c ';
        fprintf(file_id_Gray, formatSpec, dec2hex((M(i,j)),2));
    end
    fprintf(file_id_Gray ,'\n');
end
fclose(file_id_Gray);

%% Plot Verilog Output Edges
M=dlmread('edge_result_uart.txt');
M = uint8(M);
figure, imshow(M); title('Filtered Image');

thresholdValue = 10; % varies between [0 255]
output_image_M = max(M, thresholdValue);
output_image_M(output_image_M == round(thresholdValue)) = 0;

output_image_M = im2bw(output_image_M);
figure, imshow(output_image_M); title('Edge Detected Image');