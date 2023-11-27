%% FPGA project phase 4+ viterbi
clear;
clc;

len = 100;

raw_data = rand(1, len) > 0.5;
writeToFile(raw_data, 'raw_data.mem');

encoded_data = viterbi_encoder(raw_data);
writeToFile(encoded_data, 'encoded_data.mem');