function xzfn_write_simple_csv(outfile, header, data)
    cntrow = size(data, 1);
    
    foutcsv = fopen(outfile, 'w');
    fprintf(foutcsv, [header, '\n']);
    for i = 1:cntrow
        fprintf(foutcsv, [num2str(data(i)), '\n']);
    end
    fclose(foutcsv);

end