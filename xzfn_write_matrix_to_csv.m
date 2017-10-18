function xzfn_write_matrix_to_csv(filename, header, indata)
%WRITE_MATRIX_TO_CSV Write data in a matrix to a csv file on disk.
%	XZFN_WRITE_MATRIX_TO_CSV(filename, header, indata) writes data in indata
%	to a csv file specified by filename with header. The header is a cell
%	array containing the header in order, without separator.
%	Note the number of columns in indata should equals to the length of header.
    fcsv = fopen(filename, 'w');
    for i = 1:length(header)-1
        fprintf(fcsv, [header{i}, ',']);
    end
    fprintf(fcsv, [header{end}, '\n']); % header{i+1},only one column also works
    
    rowcnt = size(indata, 1);
    colcnt = size(indata, 2);
    if length(header) ~= colcnt
        warning(['header cnt unequal to indata column cnt.', filename]);
    end
    for irow = 1:rowcnt
        for icol = 1:colcnt-1
            fprintf(fcsv, [num2str(indata(irow, icol)), ',']);
        end
        fprintf(fcsv, [num2str(indata(irow, end)), '\n']);
    end
    fclose(fcsv);
end