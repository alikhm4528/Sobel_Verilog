function crc = crc_calculator(packet)
    key = [1 0 0 1 1];
    packet = [packet, zeros(1, 4)];
    for i = 1:4
        if packet(1) == 1
            packet(1:5) = xor(packet(1:5), key);
        end
        packet = packet(2:end);
    end
    crc = packet;
end