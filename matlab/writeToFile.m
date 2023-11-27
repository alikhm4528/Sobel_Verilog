function writeToFile(raw_data, file_name)
    x_bin = char(double(raw_data) + 48);
    %x_bin = upsample(x_bin, 2);
    %x_bin(x_bin == 0) = newline;
    bin_data = x_bin;
    file = fopen(file_name, 'wt');
    fwrite(file, bin_data);
    fclose(file);
end