%% FPGA project phase 3
clear;
clc;

portHandle = serial('COM8', 'baudrate', 115200);
fopen(portHandle);
fprintf(portHandle, '1');