function [y_centered, dc_offset] = offset_removal(y)
    %   Subtract the Mean so the Signal is Zero-Mean

    %   Input
    %   y:	system output (vector of size N x 1)

    %   Output
    %   y_centered:	zero-mean output (vector of size N x 1)
    %   dc_offset:	removed DC offset

    dc_offset = mean(y);
    y_centered = y - dc_offset;
end
