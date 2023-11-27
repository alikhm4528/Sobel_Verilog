function viterbi = viterbi_calculator(packet)
    viterbi = zeros(1, 8);
    s0 = 0;
    s1 = 0;
    for i = 1:4
        bit = xor(packet(i), s1);
        viterbi(2*i-1:2*i) = [xor(bit, s0), bit];
        s1 = s0;
        s0 = packet(i);
    end
end