function encoded_data = crc_encoder(raw_data)
    raw_data = double(raw_data);
    len = length(raw_data);
    
    encoded_data = zeros(1, 2 * len);
    for i = 1:len / 4
        packet = raw_data(4*i - 3: 4*i);
        crc = crc_calculator(packet);
        encoded_data(8*i - 7: 8*i) = [packet, crc];
    end
end